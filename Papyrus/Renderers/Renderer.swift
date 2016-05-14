//
//  Renderer.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Renderer {
    /// Moves the pen to `position` without drawing anything.
    func moveTo(position: CGPoint)
    
    /// Draws a line from the pen's current position to `position`, updating
    /// the pen position.
    func lineTo(position: CGPoint, color: UIColor, width: CGFloat)
    
    /// Fills a rectangle with a given `color`.
    func fillRect(rect: CGRect, color: UIColor)
    
    /// Strokes a rectangle with a given `color` and `width`.
    func strokeRect(rect: CGRect, color: UIColor, width: CGFloat)
    
    /// Draws `text` in a given rectangle.
    func drawText(text: NSAttributedString, rect: CGRect)
}


extension Renderer {
    /// Fills a rectangle using a `shader` to provide `fillColor`.
    func fillRect(rect: CGRect, shader: Shader) {
        fillRect(rect, color: shader.fillColor!)
    }
    
    /// Strokes a rectangle using `shader` to provide `strokeColor` and `strokeWidth`.
    func strokeRect(rect: CGRect, shader: Shader) {
        strokeRect(rect, color: shader.strokeColor!, width: shader.strokeWidth!)
    }
    
    /// Adds line to point using `shader` to provide `strokeColor` and `strokeWidth`.
    func lineTo(position: CGPoint, shader: Shader) {
        lineTo(position, color: shader.strokeColor!, width: shader.strokeWidth!)
    }
    
    /// Draws text using the `textColor` defined by the `shader`.
    func drawText(text: NSAttributedString, rect: CGRect, shader: Shader) {
        let mutable = NSMutableAttributedString(attributedString: text)
        mutable.addAttributes([NSForegroundColorAttributeName: shader.textColor!], range: NSMakeRange(0, mutable.length))
        drawText(mutable, rect: rect)
    }
}