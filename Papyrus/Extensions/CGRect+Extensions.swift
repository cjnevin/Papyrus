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
    
    /// Sum of width plus height.
    var widthPlusHeight : CGFloat {
        return width + height
    }
    
    func innerRectForSize(size: CGSize,
        verticalAlignment: VerticalAlignment,
        horizontalAlignment: HorizontalAlignment) -> CGRect {
            return CGRect(
                origin: CGPoint(
                    x: origin.x + (self.size.width - size.width) * horizontalAlignment.rawValue,
                    y: origin.y + (self.size.height - size.height) * verticalAlignment.rawValue),
                size: size)
    }
    
    func centeredRectForSize(size: CGSize) -> CGRect {
        return innerRectForSize(size, verticalAlignment: .Center,
            horizontalAlignment: .Center)
    }
    
    func center() -> CGPoint {
        return CGPoint(
            x: CGRectGetWidth(self) / 2 + origin.x,
            y: CGRectGetHeight(self) / 2 + origin.y)
    }
    
    func scaleX(width: CGFloat) -> CGFloat {
        let scale = width / CGRectGetWidth(self)
        return scale
    }
    
    func scaleY(height: CGFloat) -> CGFloat {
        let scale = height / CGRectGetHeight(self)
        return scale
    }
}
