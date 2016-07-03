//
//  SquareRenderer.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

extension CGContext : Renderer {
    func moveTo(_ position: CGPoint) {
        self.moveTo(x: position.x, y: position.y)
    }
    
    func lineTo(_ position: CGPoint, color: UIColor, width: CGFloat) {
        var r = CGFloat(0), g = CGFloat(0), b = CGFloat(0), a = CGFloat(0)
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(width)
        context?.setStrokeColor(red: r, green: g, blue: b, alpha: a)
        self.addLineTo(x: position.x, y: position.y)
        context?.strokePath()
    }
    
    func fillRect(_ rect: CGRect, color: UIColor) {
        color.set()
        UIBezierPath(rect: rect).fill()
    }
    
    func strokeRect(_ rect: CGRect, color: UIColor, width: CGFloat = 1.0) {
        color.setStroke()
        let path = UIBezierPath(rect: rect)
        path.lineWidth = width
        path.stroke()
    }
    
    func drawPath(_ path: CGPath, color: UIColor, lineColor: UIColor, lineWidth: CGFloat = 1.0, rect: CGRect) {
        lineColor.setStroke()
        color.setFill()
        let bezierPath = UIBezierPath(cgPath: path)
        bezierPath.fill()
        bezierPath.lineWidth = lineWidth
        bezierPath.stroke()
    }
    
    func drawText(_ text: AttributedString, rect: CGRect) {
        text.draw(in: rect)
    }
}
