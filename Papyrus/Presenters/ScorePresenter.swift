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

class ScorePresenter: Presenter {
    private let layout: ScoreLayout
    init(layout: ScoreLayout) {
        self.layout = layout
    }
    
    func refresh(in view: GameView, with game: Game) {
        func name(of player: Player) -> String? {
            if player is Human {
                let index = game.players.filter({ $0 is Human }).index(where: { $0.id == player.id }) ?? 0
                return "Human \(index + 1)"
            } else {
                let index = game.players.filter({ $0 is Computer }).index(where: { $0.id == player.id }) ?? 0
                return "AI \(index + 1)"
            }
        }
        let players = game.players.map({ (name: name(of: $0)!, score: $0.score, myTurn: game.ended == false && $0.id == game.player.id) })
        view.subviews.filter({ $0 is ScoresView }).forEach({ $0.removeFromSuperview() })
        let scoresView = ScoresView(frame: layout.rect)
        scoresView.backgroundColor = UIColor.white()
        view.addSubview(scoresView)
        scoresView.drawable = ScoresDrawable(for: players, rect: layout.insetRect)
    }
}
