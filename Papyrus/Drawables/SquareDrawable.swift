//
//  SquareDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

extension UIFont {
    static var acronymFontBig: UIFont { return .systemFont(ofSize: 9) }
}

struct SquareDrawable : Drawable {
    private let rect: CGRect
    var shader: Shader
    var acronym: String?
    
    init(rect: CGRect, acronym: String?, shader: Shader) {
        self.rect = rect
        self.shader = shader
        self.acronym = acronym
    }
    
    func draw(renderer: Renderer) {
        if shader.fillColor != nil {
            renderer.fill(rect: rect, shader: shader)
        }
        if shader.strokeColor != nil {
            renderer.stroke(rect: rect, shader: shader)
        }
        if shader.textColor != nil && acronym != nil {
            let letterText = AttributedString(string: acronym!, attributes: [NSFontAttributeName: UIFont.acronymFontBig])
            let letterRect = rect.centeredRectForSize(letterText.size())
            renderer.draw(text: letterText, rect: letterRect, shader: shader)
        }
    }
}
