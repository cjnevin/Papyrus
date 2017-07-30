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
        guard let fillColor = shader.fillColor, let lineColor = shader.strokeColor, let lineWidth = shader.strokeWidth else {
            return
        }
        renderer.draw(path: createStarPath(rect.insetBy(dx: 5, dy: 5)), color: fillColor, lineColor: lineColor, lineWidth: lineWidth, rect: rect)
    }
    
    func createStarPath(_ rect: CGRect) -> CGPath {
        let size = rect.size
        let numberOfPoints: CGFloat = 5
        
        let starRatio: CGFloat = 0.5
        
        let steps: CGFloat = numberOfPoints * 2
        
        let outerRadius: CGFloat = min(size.height, size.width) / 2
        let innerRadius: CGFloat = outerRadius * starRatio
        
        let stepAngle = 2 * CGFloat.pi / steps
        let center = CGPoint(x: rect.origin.x + size.width / 2, y: rect.origin.y + size.height / 2)
        
        let path = CGMutablePath()
        
        for i in 0..<Int(steps) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            
            let angle = CGFloat(i) * stepAngle - CGFloat.pi / 2
            
            let point = CGPoint(x: radius * cos(angle) + center.x,
                                y: radius * sin(angle) + center.y)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

