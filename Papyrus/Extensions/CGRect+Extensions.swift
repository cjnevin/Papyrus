//
//  CGRect+Extensions.swift
//  Papyrus
//
//  Created by Chris Nevin on 24/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

extension CGRect {
    enum HorizontalAlignment: CGFloat {
        case Left = 0.0
        case Center = 0.5
        case Right = 1.0
    }
    
    enum VerticalAlignment: CGFloat {
        case Top = 0.0
        case Center = 0.5
        case Bottom = 1.0
    }
    
    func innerRectForSize(size: CGSize,
        verticalAlignment: VerticalAlignment,
        horizontalAlignment: HorizontalAlignment) -> CGRect {
            return CGRect(
                origin: CGPoint(
                    x: (self.size.width - size.width) * horizontalAlignment.rawValue,
                    y: (self.size.height - size.height) * verticalAlignment.rawValue),
                size: size)
    }
    
    func centeredRectForSize(size: CGSize) -> CGRect {
        return innerRectForSize(size, verticalAlignment: .Center,
            horizontalAlignment: .Center)
    }
    
    func center() -> CGPoint {
        return CGPoint(
            x: CGRectGetWidth(self) / 2 + self.origin.x,
            y: CGRectGetHeight(self) / 2 + self.origin.y)
    }
    
    func scaleX(width: CGFloat) -> CGFloat {
        let scale = width / CGRectGetWidth(self)
        return scale
    }
    
    func scaleY(height: CGFloat) -> CGFloat {
        let scale = height / CGRectGetHeight(self)
        return scale
    }
    
    func transformTo(toRect: CGRect) -> CGAffineTransform {
        let fromRect = self
        let sx = toRect.size.width / fromRect.size.width
        let sy = toRect.size.height / fromRect.size.height
        
        let scale = CGAffineTransformMakeScale(sx, sy)
        
        let heightDiff = fromRect.size.height - toRect.size.height
        let widthDiff = fromRect.size.width - toRect.size.width
        
        let dx = toRect.origin.x - widthDiff / 2 - fromRect.origin.x
        let dy = toRect.origin.y - heightDiff / 2 - fromRect.origin.y
        
        let trans = CGAffineTransformMakeTranslation(dx, dy)
        return CGAffineTransformConcat(scale, trans)
    }
}
