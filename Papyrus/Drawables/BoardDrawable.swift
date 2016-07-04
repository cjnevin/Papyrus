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
    private let range: CountableRange<Int>
    
    var shader: Shader
    
    private func rectPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: rect.origin.x + x, y: rect.origin.y + y)
    }
    
    init(board: Board, letterPoints: [Character: Int], move: Solution?, rect: CGRect) {
        self.rect = rect
        squareSize = rect.width / CGFloat(board.size)
        shader = BoardShader(color: Color.Tile.Default, strokeColor: Color.Tile.Border, strokeWidth: 0.5)
        range = board.boardRange
        var drawables = [Drawable]()
        for (y, column) in board.layout.enumerated() {
            for (x, square) in column.enumerated() {
                let point = rectPoint(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                let rect = CGRect(origin: point, size: CGSize(width: squareSize, height: squareSize))
                if square == board.empty {
                    let isCenter = board.isCenter(atX: x, y: y)
                    let acronym = isCenter ? "" : (
                        Acronym.get(withSuffix: "L", multiplier: board.letterMultipliers[y][x]) ??
                            Acronym.get(withSuffix: "W", multiplier: board.wordMultipliers[y][x])
                    )
                    drawables.append(SquareDrawable(rect: rect, acronym: acronym, shader: SquareShader(x: x, y: y, board: board)))
                    if isCenter {
                        drawables.append(StarDrawable(rect: rect, shader: StarShader(color: Color.Square.Star, strokeColor: Color.Tile.Border, strokeWidth: 0.5)))
                    }
                } else {
                    var points = 0
                    if board.blanks.contains({ $0.x == x && $0.y == y }) == false {
                        points = letterPoints[square] ?? 0
                    }
                    let highlighted = move?.getPositions().contains({ $0.x == x && $0.y == y }) ?? false
                    drawables.append(TileDrawable(tile: square, points: points, rect: rect, onBoard: true, highlighted: highlighted))
                }
            }
        }
        self.drawables = drawables
    }
    
    func draw(renderer: Renderer) {
        renderer.fill(rect: rect, shader: shader)
        renderer.stroke(rect: rect, shader: shader)
        drawables.forEach({ $0.draw(renderer: renderer) })
        range.forEach { (i) -> () in
            let offset = CGFloat(i) * squareSize
            renderer.move(to: rectPoint(x: offset, y: 0))
            renderer.line(to: rectPoint(x: offset, y: rect.size.height), shader: shader)
            renderer.move(to: rectPoint(x: 0, y: offset))
            renderer.line(to: rectPoint(x: rect.size.width, y: offset), shader: shader)
        }
    }
}
