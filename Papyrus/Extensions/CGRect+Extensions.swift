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
        case left = 0.0
        case center = 0.5
        case right = 1.0
    }
    
    enum VerticalAlignment: CGFloat {
        case top = 0.0
        case center = 0.5
        case bottom = 1.0
    }
    
    /// Sum of width plus height.
    var widthPlusHeight : CGFloat {
        return width + height
    }
    
    func innerRect(forSize size: CGSize,
                   verticalAlignment: VerticalAlignment,
                   horizontalAlignment: HorizontalAlignment) -> CGRect {
            return CGRect(
                origin: CGPoint(
                    x: origin.x + (self.size.width - size.width) * horizontalAlignment.rawValue,
                    y: origin.y + (self.size.height - size.height) * verticalAlignment.rawValue),
                size: size)
    }
    
    func centeredRect(forSize size: CGSize) -> CGRect {
        return innerRect(forSize: size,
                         verticalAlignment: .center,
                         horizontalAlignment: .center)
    }
    
    var presentationRect: CGRect {
        var rect = self.integral
        if rect.size.width.truncatingRemainder(dividingBy: 2) != 0 {
            rect.size.width -= 1
        }
        if rect.size.height.truncatingRemainder(dividingBy: 2) != 0 {
            rect.size.height -= 1
        }
        return rect
    }
}
