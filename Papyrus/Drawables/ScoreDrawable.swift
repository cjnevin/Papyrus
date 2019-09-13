//
//  ScoreDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 4/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

struct ScoreDrawable : Drawable {
    var shader: Shader
    
    private let rect: CGRect
    private let text: String
    private let font: UIFont
    
    init(text: String, highlighted: Bool, myTurn: Bool, rect: CGRect) {
        self.shader = ScoreShader(highlighted: highlighted)
        self.text = text
        self.rect = rect
        self.font = UIFont.systemFont(ofSize: 13, weight: myTurn ? UIFont.Weight.semibold : UIFont.Weight.light)
    }
    
    func draw(renderer: Renderer) {
        let attrText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        let attrRect = rect.centeredRect(forSize: attrText.size())
        renderer.draw(text: attrText, rect: attrRect, shader: shader)
    }
}
