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
    
    init(squares: [Square], rect: CGRect) {
        self.rect = rect
        range = (0...Int(sqrt(Double(squares.count))))
        squareSize = CGRectGetWidth(rect) / CGFloat(PapyrusDimensions)
        shader = FillShader(color: .Papyrus_Tile)
        drawables = squares.flatMap{ (square) -> Drawable? in
            if let tile = square.tile {
                return TileDrawable(tile: tile, rect: square.rectWithEdge(squareSize))
            } else if square.type != .None {
                return SquareDrawable(square: square, edge: squareSize)
            }
            return nil
        }
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