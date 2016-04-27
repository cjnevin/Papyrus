//
//  FillShader.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

struct FillShader : Shader {
    var fillColor: UIColor?
    var textColor: UIColor?
    var strokeColor: UIColor?
    var strokeWidth: CGFloat?
    init(color: UIColor) {
        fillColor = color
    }
}