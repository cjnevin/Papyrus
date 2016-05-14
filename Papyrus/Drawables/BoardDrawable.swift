//
//  BoardDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 24/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

struct BoardDrawable: Drawable {
    private var drawables: [Drawable]!
    private let rect: CGRect
    private let squareSize: CGFloat
    private let range: Range<Int>
    
    var shader: Shader
    
    init(board: Board, distribution: LetterDistribution, move: Solution?, rect: CGRect) {
        self.rect = rect
        squareSize = CGRectGetWidth(rect) / CGFloat(board.config.size)
        shader = BoardShader(color: .tileColor, strokeColor: .lightGrayColor(), strokeWidth: 0.5)
        range = board.config.boardRange
        var drawables = [Drawable]()
        for (y, column) in board.board.enumerate() {
            for (x, square) in column.enumerate() {
                let point = CGPoint(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                let rect = CGRect(origin: point, size: CGSize(width: squareSize, height: squareSize))
                if square == board.config.empty {
                    var acronym: String? = nil
                    switch board.config.letterMultipliers[x][y] {
                    case 2:
                        acronym = "DL"
                    case 3:
                        acronym = "TL"
                    case 4:
                        acronym = "QL"
                    default:
                        break
                    }
                    switch board.config.wordMultipliers[x][y] {
                    case 2:
                        acronym = "DW"
                    case 3:
                        acronym = "TW"
                    case 4:
                        acronym = "QW"
                    default:
                        break
                    }
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