//
//  Drawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Drawable {
    /// Represents color information for Drawables.
    var shader: Shader { get set }
    
    /// Issues drawing commands to `renderer` to represent `self`.
    func draw(renderer: Renderer)
}
