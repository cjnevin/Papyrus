//
//  BoardShader.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

struct BoardShader : Shader {
    var fillColor: UIColor?
    var textColor: UIColor?
    var strokeColor: UIColor?
    var strokeWidth: CGFloat?
    init(color: UIColor, strokeColor: UIColor, strokeWidth: CGFloat) {
        fillColor = color
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }
}