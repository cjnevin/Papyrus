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
        defer {
            textColor = fillColor?.multiplyChannels()
        }
        if board.isCenterAt(x, y) {
            fillColor = Color.Square.Center
            return
        }
        fillColor = Color.Square.color(
            forLetterMultiplier: board.letterMultipliers[y][x],
            wordMultiplier: board.wordMultipliers[y][x])
    }
}