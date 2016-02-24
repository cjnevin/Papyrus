//
//  SquareRenderer.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

extension CGContext : Renderer {
    func moveTo(position: CGPoint) {
        CGContextMoveToPoint(self, position.x, position.y)
    }
    
    func lineTo(position: CGPoint) {
        CGContextAddLineToPoint(self, position.x, position.y)
    }
    
    func fillRect(rect: CGRect, color: UIColor) {
        color.set()
        UIBezierPath(rect: rect).fill()
    }
    
    func strokeRect(rect: CGRect, color: UIColor, width: CGFloat = 1.0) {
        color.setStroke()
        let path = UIBezierPath(rect: rect)
        path.lineWidth = width
        path.stroke()
    }
    
    func drawText(text: NSAttributedString, rect: CGRect) {
        text.drawInRect(rect)
    }
    
    func drawText(text: String, font: UIFont, color: UIColor, rect: CGRect) {
        let style = NSMutableParagraphStyle()
        style.alignment = .Center
        let textAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: style
        ]
        drawText(NSAttributedString(string: text, attributes: textAttributes), rect: rect)
    }
}