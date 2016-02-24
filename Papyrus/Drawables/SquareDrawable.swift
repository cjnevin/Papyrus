//
//  SquareDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

extension Square {
    func rectWithEdge(edge: CGFloat) -> CGRect {
        return CGRect(
            origin: CGPoint(x: edge * CGFloat(column), y: edge * CGFloat(row)),
            size: CGSize(width: edge, height: edge))
    }
}

struct SquareDrawable : Drawable {
    private let rect: CGRect
    private let fillColor: UIColor
    private let strokeColor: UIColor?
    private let strokeWidth: CGFloat?
    
    init(rect: CGRect, fillColor: UIColor, strokeColor: UIColor? = nil, strokeWidth: CGFloat? = 1.0) {
        self.rect = rect
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }
    
    init(square: Square, edge: CGFloat, fillColor: UIColor, strokeColor: UIColor? = nil, strokeWidth: CGFloat? = 1.0) {
        self.init(rect: square.rectWithEdge(edge), fillColor: fillColor, strokeColor: strokeColor, strokeWidth: strokeWidth)
    }
    
    func draw(renderer: Renderer) {
        renderer.fillRect(rect, color: fillColor)
        
        if let strokeColor = strokeColor, strokeWidth = strokeWidth {
            renderer.strokeRect(rect, color: strokeColor, width: strokeWidth)
        }
    }
}