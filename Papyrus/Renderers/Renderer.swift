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
    func move(to position: CGPoint)
    
    /// Draws a line from the pen's current position to `position`, updating
    /// the pen position.
    func line(to position: CGPoint, color: UIColor, width: CGFloat)
    
    /// Fills a rectangle with a given `color`.
    func fill(rect: CGRect, color: UIColor)
    
    /// Strokes a rectangle with a given `color` and `width`.
    func stroke(rect: CGRect, color: UIColor, width: CGFloat)
    
    /// Draws `text` in a given rectangle.
    func draw(text: AttributedString, rect: CGRect)
    
    /// Draw path in a given rectangle.
    func draw(path: CGPath, color: UIColor, lineColor: UIColor, lineWidth: CGFloat, rect: CGRect)
}


extension Renderer {
    /// Fills a rectangle using a `shader` to provide `fillColor`.
    func fill(rect: CGRect, shader: Shader) {
        fill(rect: rect, color: shader.fillColor!)
    }
    
    /// Strokes a rectangle using `shader` to provide `strokeColor` and `strokeWidth`.
    func stroke(rect: CGRect, shader: Shader) {
        stroke(rect: rect, color: shader.strokeColor!, width: shader.strokeWidth!)
    }
    
    /// Adds line to point using `shader` to provide `strokeColor` and `strokeWidth`.
    func line(to position: CGPoint, shader: Shader) {
        line(to: position, color: shader.strokeColor!, width: shader.strokeWidth!)
    }
    
    /// Draws text using the `textColor` defined by the `shader`.
    func draw(text: AttributedString, rect: CGRect, shader: Shader) {
        let mutable = NSMutableAttributedString(attributedString: text)
        mutable.addAttributes([NSForegroundColorAttributeName: shader.textColor!], range: NSMakeRange(0, mutable.length))
        draw(text: mutable, rect: rect)
    }
}
