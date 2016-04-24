//
//  SquareDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

struct SquareDrawable : Drawable {
    private let rect: CGRect
    var shader: Shader
    
    init(rect: CGRect, shader: Shader) {
        self.rect = rect
        self.shader = shader
    }
    
    func draw(renderer: Renderer) {
        if shader.fillColor != nil {
            renderer.fillRect(rect, shader: shader)
        }
        if shader.strokeColor != nil {
            renderer.strokeRect(rect, shader: shader)
        }
    }
}