//
//  SquareShader.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

struct SquareShader: Shader {
    private let colorMap: [Modifier: UIColor] = [
        .Center: .Papyrus_Center,
        .Letterx2: .Papyrus_Letterx2,
        .Letterx3: .Papyrus_Letterx3,
        .Wordx2: .Papyrus_Wordx2,
        .Wordx3: .Papyrus_Wordx3,
        .None: .Papyrus_Tile
    ]
    var fillColor: UIColor?
    var textColor: UIColor?
    var strokeColor: UIColor?
    var strokeWidth: CGFloat?
    init(square: Square) {
        fillColor = colorMap[square.type]!
    }
}