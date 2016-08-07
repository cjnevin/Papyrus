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
    init(x: Int, y: Int, board: BoardType) {
        defer {
            textColor = fillColor?.multiplyChannels()
        }
        let position = Position(x: x, y: y)
        if board.isCenter(at: position) {
            fillColor = Color.Square.Center
            return
        }
        fillColor = Color.Square.color(
            forLetterMultiplier: board.letterMultiplier(at: position),
            wordMultiplier: board.wordMultipliers[y][x])
    }
}
