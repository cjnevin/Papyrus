//
//  BoardView.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class BoardView: UIView {
    private static let colorMap: [Modifier: UIColor] = [
        .Center: .Papyrus_Center,
        .Letterx2: .Papyrus_Letterx2,
        .Letterx3: .Papyrus_Letterx3,
        .Wordx2: .Papyrus_Wordx2,
        .Wordx3: .Papyrus_Wordx3,
        .None: .Papyrus_Tile
    ]
    
    var game: Papyrus?
    var frames: [CGRect]?
    var squares: [Square]? {
        return game?.squares.flatMap({$0})
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.Papyrus_Square
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let size = CGRectGetWidth(rect) / CGFloat(PapyrusDimensions)
        squares?.filter({ $0.type != .None }).forEach({ (square) -> () in
            BoardView.colorMap[square.type]?.set()
            UIBezierPath(rect: CGRect(
                x: size * CGFloat(square.column),
                y: size * CGFloat(square.row),
                width: size, height: size)).fill()
        })
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0)
        CGContextSetLineWidth(context, 0.5)
        (0...PapyrusDimensions).forEach { (i) -> () in
            let offset = CGFloat(i) * size
            CGContextMoveToPoint(context, offset, 0)
            CGContextAddLineToPoint(context, offset, rect.size.height)
            CGContextMoveToPoint(context, 0, offset)
            CGContextAddLineToPoint(context, rect.size.width, offset)
        }
        CGContextStrokePath(context)
    }
    
    /*
    func calculateFrames() -> [CGRect] {
        let size = squareSize
        return range.flatMap { (row) -> [CGRect] in
            self.range.map { (col) -> CGRect in
                CGRect(x: CGFloat(row) * size,
                    y: CGFloat(col) * size,
                    width: size, height: size)
            }
        }
    }
    */
}