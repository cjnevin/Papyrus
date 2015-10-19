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
    
    let range = (0...PapyrusDimensions)
    var game: Papyrus?
    var squares: [Square]? {
        return game?.squares.flatMap({$0})
    }
    lazy var squareFrames = [Square: CGRect]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.Papyrus_Square
    }
    
    func bestSquareIntersection(rect: CGRect, point: CGPoint) -> (Square, CGRect)? {
        return squareFrames
            .filter({$0.0.tile == nil && $0.1.contains(point)}) // Filter empty squares that intersect our tile
            .map({($0.0, $0.1, CGRectIntersection(rect, $0.1))})
            .maxElement({ CGRectGetHeight($0.2) + CGRectGetWidth($0.2) <
                CGRectGetHeight($1.2) + CGRectGetWidth($1.2)})
            .map({($0.0, $0.1)})
    }
    
    func squareAtPoint(point: CGPoint) -> Square? {
        if let (square, _) = squareFrames.filter ({ (_, frame) -> Bool in
            frame.contains(point)
        }).first {
            return square
        }
        return nil
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let size = CGRectGetWidth(rect) / CGFloat(PapyrusDimensions)
        squares?.filter({ $0.type != .None }).forEach({ (square) -> () in
            BoardView.colorMap[square.type]?.set()
            let rect = CGRect(
                x: size * CGFloat(square.column),
                y: size * CGFloat(square.row),
                width: size, height: size)
            squareFrames[square] = rect
            UIBezierPath(rect: rect).fill()
        })
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0)
        CGContextSetLineWidth(context, 0.5)
        range.forEach { (i) -> () in
            let offset = CGFloat(i) * size
            CGContextMoveToPoint(context, offset, 0)
            CGContextAddLineToPoint(context, offset, rect.size.height)
            CGContextMoveToPoint(context, 0, offset)
            CGContextAddLineToPoint(context, rect.size.width, offset)
        }
        CGContextStrokePath(context)
    }
}