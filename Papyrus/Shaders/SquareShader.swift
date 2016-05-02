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
        if x == board.config.center && y == board.config.center {
            fillColor = .centerSquareColor
            return
        }
        switch board.config.letterMultipliers[y][x] {
        case 2:
            fillColor = .doubleLetterSquareColor
        case 3:
            fillColor = .tripleLetterSquareColor
        case 4:
            fillColor = .quadrupleLetterSquareColor
        default:
            switch board.config.wordMultipliers[y][x] {
            case 2:
                fillColor = .doubleWordSquareColor
            case 3:
                fillColor = .tripleWordSquareColor
            case 4:
                fillColor = .quadrupleWordSquareColor
            default:
                fillColor = .tileColor
            }
        }
    }
}