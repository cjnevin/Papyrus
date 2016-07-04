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
        return CGRect(x: rect.origin.x + insets.left,
                      y: rect.origin.y + insets.top,
                      width: rect.width - insets.left - insets.right,
                      height: rect.height - insets.bottom - insets.top)
    }
}

class ScorePresenter: Presenter {
    private class Label: UILabel { }
    
    private let layout: ScoreLayout
    init(layout: ScoreLayout) {
        self.layout = layout
    }
    
    func refresh(in view: GameView, with game: Game) {
        func name(of player: Player) -> String? {
            guard let playerIndex = game.index(of: player) else {
                return nil
            }
            return "Player \(playerIndex + 1)"
        }
        view.removeScoreLabels()
        view.addScoreLabels(for: game.players.map({ (name(of: $0)!, $0.score) }), layout: layout)
    }
}

private extension GameView {
    func removeScoreLabels() {
        subviews.filter({ $0 is ScorePresenter.Label }).forEach({ $0.removeFromSuperview() })
    }
    
    func addScoreLabels(for players: [(name: String, score: Int)], layout: ScoreLayout) {
        let rows = CGFloat(players.count > 6 ? 4 : players.count > 4 ? 3 : 2)
        let columns = ceil(CGFloat(players.count) / rows)
        let rect = layout.insetRect
        let columnWidth = rect.width / columns
        let rowHeight = rect.height / rows
        let highScore = players.map({$0.score}).max()
        for (index, element) in players.enumerated() {
            let column = ceil(CGFloat(index + 1) / rows) - 1
            let row = CGFloat(index % Int(rows))
            let playerRect = CGRect(x: rect.origin.x + column * columnWidth,
                                    y: rect.origin.y + row * rowHeight,
                                    width: columnWidth,
                                    height: rowHeight)
            let label = ScorePresenter.Label(frame: playerRect)
            label.text = element.name + " (\(element.score))"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 13, weight: element.score > 0 && element.score == highScore ? UIFontWeightBold : UIFontWeightLight)
            addSubview(label)
        }
    }
}
