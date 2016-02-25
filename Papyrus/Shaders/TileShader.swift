//
//  TileShader.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

struct TileShader : Shader {
    var fillColor: UIColor?
    var textColor: UIColor?
    var strokeColor: UIColor?
    var strokeWidth: CGFloat?
    init(tile: Tile) {
        // Based on state of tile, render differently.
        fillColor = .Papyrus_Tile
        textColor = .blackColor()
        strokeColor = .Papyrus_TileBorder
        strokeWidth = 1.0
    }
}