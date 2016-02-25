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
    var shader: Shader
    
    private let rect: CGRect
    private let tile: Tile
    private var letter: String {
        return String(tile.letter).uppercaseString
    }
    private var points: String {
        return String(tile.value)
    }
    
    private let letterFont = UIFont.systemFontOfSize(20)
    private let pointsFont = UIFont.systemFontOfSize(8)
    
    init(tile: Tile, rect: CGRect, shader: Shader? = nil) {
        self.shader = shader ?? TileShader(tile: tile)
        self.tile = tile
        self.rect = rect
    }
    
    func draw(renderer: Renderer) {
        renderer.fillRect(rect, shader: shader)
        
        let letterText = NSAttributedString(string: letter, font: letterFont)
        let letterRect = rect.centeredRectForSize(letterText.size())
        renderer.drawText(letterText, rect: letterRect, shader: shader)
        
        let pointsText = NSAttributedString(string: points, font: pointsFont)
        let pointsRect = CGRectInset(rect, 2, 1).innerRectForSize(pointsText.size(),
            verticalAlignment: .Bottom, horizontalAlignment: .Right)
        renderer.drawText(pointsText, rect: pointsRect, shader: shader)
        
        renderer.strokeRect(rect, shader: shader)
    }
}