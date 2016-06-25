//
//  StarDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

struct StarDrawable : Drawable {
    private let rect: CGRect
    var shader: Shader
    
    init(rect: CGRect, shader: Shader) {
        self.rect = rect
        self.shader = shader
    }
    
    func draw(renderer: Renderer) {
        guard let fillColor = shader.fillColor, lineColor = shader.strokeColor, lineWidth = shader.strokeWidth else {
            return
        }
        renderer.drawPath(createStarPath(CGRectInset(rect, 5, 5)), color: fillColor, lineColor: lineColor, lineWidth: lineWidth, rect: rect)
    }
    
    func createStarPath(rect: CGRect) -> CGPath {
        let size = rect.size
        let numberOfPoints: CGFloat = 5
        
        let starRatio: CGFloat = 0.5
        
        let steps: CGFloat = numberOfPoints * 2
        
        let outerRadius: CGFloat = min(size.height, size.width) / 2
        let innerRadius: CGFloat = outerRadius * starRatio
        
        let stepAngle = CGFloat(2) * CGFloat(M_PI) / CGFloat(steps)
        let center = CGPoint(x: rect.origin.x + size.width / 2, y: rect.origin.y + size.height / 2)
        
        let path = CGPathCreateMutable()
        
        for i in 0..<Int(steps) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            
            let angle = CGFloat(i) * stepAngle - CGFloat(M_PI_2)
            
            let x = radius * cos(angle) + center.x
            let y = radius * sin(angle) + center.y
            
            if i == 0 {
                CGPathMoveToPoint(path, nil, x, y)
            }
            else {
                CGPathAddLineToPoint(path, nil, x, y)
            }
        }
        
        CGPathCloseSubpath(path)
        return path
    }
}

