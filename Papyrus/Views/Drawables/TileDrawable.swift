//
//  TileDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 24/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

struct TileDrawable : Drawable {
    private let squareDrawable: SquareDrawable
    private let rect: CGRect
    private let strokeColor: UIColor
    private let tile: Tile
    private var letter: String {
        return String(tile.letter).uppercaseString
    }
    private var points: String {
        return String(tile.value)
    }
    
    private let letterFont = UIFont.systemFontOfSize(20)
    private let pointsFont = UIFont.systemFontOfSize(8)
    
    init(tile: Tile, rect: CGRect, fillColor: UIColor, textColor: UIColor, strokeColor: UIColor) {
        self.squareDrawable = SquareDrawable(rect: rect, fillColor: fillColor, strokeColor: strokeColor, strokeWidth: 1.0)
        self.tile = tile
        self.rect = rect
        self.strokeColor = strokeColor
    }
    
    func draw(renderer: Renderer) {
        squareDrawable.draw(renderer)
        
        let letterText = NSAttributedString(string: letter, attributes: [NSFontAttributeName: letterFont,
            NSForegroundColorAttributeName: strokeColor])
        renderer.drawText(letterText, rect: rect.centeredRectForSize(letterText.size()))
        
        let pointsText = NSAttributedString(string: points, attributes: [NSFontAttributeName: pointsFont,
            NSForegroundColorAttributeName: strokeColor])
        let pointsRect = CGRectInset(rect, 2, 1).innerRectForSize(pointsText.size(), verticalAlignment: .Bottom, horizontalAlignment: .Right)
        renderer.drawText(pointsText, rect: pointsRect)
    }
}