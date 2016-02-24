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
    private let colorMap: [Modifier: UIColor] = [
        .Center: .Papyrus_Center,
        .Letterx2: .Papyrus_Letterx2,
        .Letterx3: .Papyrus_Letterx3,
        .Wordx2: .Papyrus_Wordx2,
        .Wordx3: .Papyrus_Wordx3,
        .None: .Papyrus_Tile
    ]
    private var drawables: [Drawable]!
    private let rect: CGRect
    private let squareSize: CGFloat
    private let range: Range<Int>
    
    init(squares: [Square], rect: CGRect) {
        self.rect = rect
        self.range = (0...Int(sqrt(Double(squares.count))))
        self.squareSize = CGRectGetWidth(rect) / CGFloat(PapyrusDimensions)
        drawables = squares.flatMap{ (square) -> Drawable? in
            if let tile = square.tile {
                return TileDrawable(tile: tile,
                    rect: square.rectWithEdge(squareSize),
                    fillColor: UIColor.whiteColor(),
                    textColor: UIColor.redColor(),
                    strokeColor: UIColor.blueColor())
            } else if square.type != .None {
                return SquareDrawable(square: square,
                    edge: squareSize,
                    fillColor: colorMap[square.type]!)
            }
            return nil
        }
        drawables.insert(SquareDrawable(rect: rect, fillColor: colorMap[.None]!), atIndex: 0)
    }
    
    func draw(renderer: Renderer) {
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