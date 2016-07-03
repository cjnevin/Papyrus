//
//  TileDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 24/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

extension UIFont {
    static var tileLetterFontBig: UIFont { return .systemFontOfSize(20) }
    static var tileLetterFontSmall: UIFont { return .systemFontOfSize(12) }
    static var pointsFont: UIFont { return .systemFontOfSize(8) }
}

struct TileDrawable : Drawable {
    var shader: Shader
    
    private let rect: CGRect
    private let tile: Character
    private var letter: String {
        return String(tile).uppercased()
    }
    private let points: String
    private let onBoard: Bool
    
    init(tile: Character, points: Int, rect: CGRect, onBoard: Bool, highlighted: Bool = false, shader: Shader? = nil) {
        self.shader = shader ?? TileShader(tile: tile, points: points, highlighted: highlighted)
        self.onBoard = onBoard
        self.tile = tile
        self.rect = rect
        self.points = points > 0 ? "\(points)" : ""
    }
    
    func draw(_ renderer: Renderer) {
        renderer.fillRect(rect: rect, color: shader)
        renderer.strokeRect(rect, shader: shader)
        
        let letterFont = onBoard ? UIFont.tileLetterFontSmall : UIFont.tileLetterFontBig
        let letterText = AttributedString(string: letter, attributes: [NSFontAttributeName: letterFont])
        let letterRect = rect.centeredRectForSize(letterText.size())
        renderer.drawText(letterText, rect: letterRect, shader: shader)
        
        let pointsText = AttributedString(string: points, attributes: [NSFontAttributeName: UIFont.pointsFont])
        let pointsRect = CGRectInset(rect, 2, 1).innerRectForSize(pointsText.size(),
            verticalAlignment: .Bottom, horizontalAlignment: .Right)
        renderer.drawText(pointsText, rect: pointsRect, shader: shader)
    }
}
