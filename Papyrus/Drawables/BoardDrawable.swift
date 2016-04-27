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
    
    init(board: Board, rect: CGRect) {
        self.rect = rect
        squareSize = CGRectGetWidth(rect) / CGFloat(board.boardSize)
        shader = FillShader(color: .Papyrus_Tile)
        range = 0..<board.boardSize
        var drawables = [Drawable]()
        for (y, column) in board.board.enumerate() {
            for (x, square) in column.enumerate() {
                let point = CGPoint(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                let rect = CGRect(origin: point, size: CGSize(width: squareSize, height: squareSize))
                if square == board.empty {
                    drawables.append(SquareDrawable(rect: rect, shader: SquareShader(x: x, y: y, board: board)))
                } else {
                    // TODO: Not handling '?'
                    drawables.append(TileDrawable(tile: square, points: board.letterPoints[square] ?? 0, rect: rect, onBoard: true))
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
            renderer.lineTo(CGPoint(x: offset, y: rect.size.height))
            renderer.moveTo(CGPoint(x: 0, y: offset))
            renderer.lineTo(CGPoint(x: rect.size.width, y: offset))
        }
    }
}