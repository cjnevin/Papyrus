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
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()
        drawable?.draw(context)
        let blackColor = UIColor.black().cgColor
        context.setStrokeColor(blackColor)
        context.setLineWidth(0.5)
        context.strokePath()
        context.restoreGState()
    }
    
}
