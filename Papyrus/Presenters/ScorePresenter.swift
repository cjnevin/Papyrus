//
//  ScorePresenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 4/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

private let defaultEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
struct ScoreLayout {
    let insets: UIEdgeInsets = defaultEdgeInsets
    let rect: CGRect
    var insetRect: CGRect {
        return CGRect(x: insets.left,
                      y: insets.top,
                      width: rect.width - insets.left - insets.right,
                      height: rect.height - insets.bottom - insets.top)
    }
}

struct ScorePresenter: Presenter {
    private let layout: ScoreLayout
    init(layout: ScoreLayout) {
        self.layout = layout
    }
    
    func refresh(in view: GameView, with game: Game) {
        func name(of player: Player) -> String? {
            return player is Human ? "👤" : "🤖"
        }
        let players = game.players.map({ (name: name(of: $0)!, score: $0.score, myTurn: game.ended == false && $0.id == game.player.id) })
        view.scoresDrawable = ScoresDrawable(for: players, rect: layout.insetRect)
    }
}
