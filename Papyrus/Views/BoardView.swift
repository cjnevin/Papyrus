//
//  BoardView.swift
//  Papyrus
//
//  Created by Chris Nevin on 7/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

class BoardView: UIView {
    var drawable: BoardDrawable? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()
        drawable?.draw(renderer: context)
        let blackColor = UIColor.black().cgColor
        context.setStrokeColor(blackColor)
        context.setLineWidth(0.5)
        context.strokePath()
        context.restoreGState()
    }
}
