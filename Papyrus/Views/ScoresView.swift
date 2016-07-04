//
//  ScoresView.swift
//  Papyrus
//
//  Created by Chris Nevin on 5/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

class ScoresView: UIView {
    var drawable: ScoresDrawable? {
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
        context.restoreGState()
    }
}
