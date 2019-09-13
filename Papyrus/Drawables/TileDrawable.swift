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
    static var tileLetterFontBig: UIFont { return .systemFont(ofSize: 20) }
    static var tileLetterFontSmall: UIFont { return .systemFont(ofSize: 11) }
    static var pointsFontBig: UIFont { return .systemFont(ofSize: 10) }
    static var pointsFontSmall: UIFont { return .systemFont(ofSize: 6) }
}

struct TileDrawable : Drawable {
    var shader: Shader
    
    private let rect: CGRect
    private let tile: Character
    private var letter: String {
        return String(tile).capitalized
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
    
    func draw(renderer: Renderer) {
        renderer.fill(rect: rect, shader: shader)
        renderer.stroke(rect: rect, shader: shader)
        
        let letterFont = onBoard ? UIFont.tileLetterFontSmall : UIFont.tileLetterFontBig
        let letterText = NSAttributedString(string: letter, attributes: [NSAttributedString.Key.font: letterFont])
        let letterRect = rect.centeredRect(forSize: letterText.size())
        renderer.draw(text: letterText, rect: letterRect, shader: shader)
        
        let pointsFont = onBoard ? UIFont.pointsFontSmall : UIFont.pointsFontBig
        let pointsText = NSAttributedString(string: points, attributes: [NSAttributedString.Key.font: pointsFont])
        let pointsRect = rect.insetBy(dx: onBoard ? 1 : 2, dy: 1).innerRect(forSize: pointsText.size(),
            verticalAlignment: .bottom, horizontalAlignment: .right)
        renderer.draw(text: pointsText, rect: pointsRect, shader: shader)
    }
}
