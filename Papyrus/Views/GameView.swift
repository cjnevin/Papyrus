//
//  GameView.swift
//  Papyrus
//
//  Created by Chris Nevin on 22/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

class GameView: UIView {
    var drawable: BoardDrawable? {
        didSet {
            setNeedsDisplay()
        }
    }
    var tileViews: [TileView]? {
        willSet {
            tileViews?.forEach { $0.removeFromSuperview() }
        }
        didSet {
            tileViews?.forEach { addSubview($0) }
        }
    }
    
    override func drawRect(rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        CGContextSaveGState(context)
        drawable?.draw(context)
        let blackColor = UIColor.blackColor().CGColor
        CGContextSetStrokeColorWithColor(context, blackColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
    
}