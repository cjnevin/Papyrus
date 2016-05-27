//
//  BoardDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 24/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

private enum Acronym {
    static let prefixes = [2: "D", 3: "T", 4: "Q"]
    static func get(withSuffix suffix: String, multiplier: Int) -> String? {
        guard let prefix = prefixes[multiplier] else { return nil }
        return prefix + suffix
    }
}


struct BoardDrawable: Drawable {
    private var drawables: [Drawable]!
    private let rect: CGRect
    private let squareSize: CGFloat
    private let range: Range<Int>
    
    var shader: Shader
    
    init(board: Board, distribution: LetterDistribution, move: Solution?, rect: CGRect) {
        self.rect = rect
        squareSize = CGRectGetWidth(rect) / CGFloat(board.config.size)
        shader = BoardShader(color: .tileColor, strokeColor: .tileBorderColor, strokeWidth: 0.5)
        range = board.config.boardRange
        var drawables = [Drawable]()
        for (y, column) in board.board.enumerate() {
            for (x, square) in column.enumerate() {
                let point = CGPoint(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                let rect = CGRect(origin: point, size: CGSize(width: squareSize, height: squareSize))
                if square == board.config.empty {
                    let acronym = (
                        Acronym.get(withSuffix: "L", multiplier: board.config.letterMultipliers[y][x]) ??
                            Acronym.get(withSuffix: "W", multiplier: board.config.wordMultipliers[y][x])
                    )
                    drawables.append(SquareDrawable(rect: rect, acronym: acronym, shader: SquareShader(x: x, y: y, board: board)))
                } else {
                    var points = 0
                    if board.playedBlanks.contains({ $0.x == x && $0.y == y }) == false {
                        points = distribution.letterPoints[square] ?? 0
                    }
                    let highlighted = move?.getPoints().contains({ $0.x == x && $0.y == y }) ?? false
                    drawables.append(TileDrawable(tile: square, points: points, rect: rect, onBoard: true, highlighted: highlighted))
                }
            }
        }
        self.drawables = drawables
    }
    
    func draw(renderer: Renderer) {
        renderer.fillRect(rect, shader: shader)
        renderer.strokeRect(rect, shader: shader)
        drawables.forEach({ $0.draw(renderer) })
        range.forEach { (i) -> () in
            let offset = CGFloat(i) * squareSize
            renderer.moveTo(CGPoint(x: offset, y: 0))
            renderer.lineTo(CGPoint(x: offset, y: rect.size.height), shader: shader)
            renderer.moveTo(CGPoint(x: 0, y: offset))
            renderer.lineTo(CGPoint(x: rect.size.width, y: offset), shader: shader)
        }
    }
}