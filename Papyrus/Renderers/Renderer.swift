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
    func lineTo(position: CGPoint)
    
    /// Fills a rectangle with a given `color`.
    func fillRect(rect: CGRect, color: UIColor)
    
    /// Strokes a rectangle with a given `color` and `width`.
    func strokeRect(rect: CGRect, color: UIColor, width: CGFloat)
    
    /// Draws `text` in a given rectangle.
    func drawText(text: NSAttributedString, rect: CGRect)
    
    /// Draws `text` in `color` and `font` in a given rectangle.
    func drawText(text: String, font: UIFont, color: UIColor, rect: CGRect)
}