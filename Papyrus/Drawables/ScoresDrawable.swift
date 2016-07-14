//
//  ScoresDrawable.swift
//  Papyrus
//
//  Created by Chris Nevin on 4/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

struct ScoresDrawable : Drawable {
    var shader: Shader
    let drawables: [Drawable]
    
    init(for players: [(name: String, score: Int, myTurn: Bool)], rect: CGRect) {
        shader = ScoreShader(highlighted: false)
        let rows = CGFloat(1)//players.count > 6 ? 4 : players.count > 4 ? 3 : 2)
        let columns = ceil(CGFloat(players.count) / rows)
        let columnWidth = rect.width / columns
        let rowHeight = rect.height / rows
        let highScore = players.map({$0.score}).max()
        drawables = players.enumerated().map { (index, element) -> ScoreDrawable in
            let column = ceil(CGFloat(index + 1) / rows) - 1
            let row = CGFloat(index % Int(rows))
            let playerRect = CGRect(x: rect.origin.x + column * columnWidth,
                                    y: rect.origin.y + row * rowHeight,
                                    width: columnWidth,
                                    height: rowHeight)
            return ScoreDrawable(text: element.name + " \(element.score)",
                                 highlighted: element.score > 0 && element.score == highScore,
                                 myTurn: element.myTurn,
                                 rect: playerRect)
        }
    }
    
    func draw(renderer: Renderer) {
        drawables.forEach({ $0.draw(renderer: renderer) })
    }
}
