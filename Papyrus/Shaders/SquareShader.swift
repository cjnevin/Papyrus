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
    var fillColor: UIColor?
    var textColor: UIColor?
    var strokeColor: UIColor?
    var strokeWidth: CGFloat?
    init(x: Int, y: Int, board: Board) {
        if x == board.center && y == board.center {
            fillColor = .Papyrus_Center
            return
        }
        switch board.letterMultipliers[y][x] {
        case 2:
            fillColor = .Papyrus_Letterx2
        case 3:
            fillColor = .Papyrus_Letterx3
        default:
            switch board.wordMultipliers[y][x] {
            case 2:
                fillColor = .Papyrus_Wordx2
            case 3:
                fillColor = .Papyrus_Wordx3
            default:
                fillColor = .Papyrus_Tile
            }
        }
    }
}