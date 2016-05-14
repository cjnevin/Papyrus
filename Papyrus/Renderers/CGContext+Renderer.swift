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
    
    func lineTo(position: CGPoint, color: UIColor) {
        var r = CGFloat(0), g = CGFloat(0), b = CGFloat(0), a = CGFloat(0)
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 0.5)
        CGContextSetRGBStrokeColor(context, r, g, b, a)
        CGContextAddLineToPoint(self, position.x, position.y)
        CGContextStrokePath(context)
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
}