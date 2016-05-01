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
    init(tile: Character, points: Int, onBoard: Bool) {
        // Based on state of tile, render differently.
        if onBoard {
            fillColor = .Papyrus_TileIlluminated
        } else {
            fillColor = .Papyrus_Tile
        }
        textColor = (points == 0 ? .grayColor() : .blackColor())
        strokeColor = .Papyrus_TileBorder
        strokeWidth = 1.0
    }
}