//
//  GamePresenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

class GamePresenter: Presenter {
    private let presenters: [Presenter]
    let board: BoardPresenter
    let rack: RackPresenter
    let score: ScorePresenter
    
    init(board: BoardPresenter, rack: RackPresenter, score: ScorePresenter) {
        self.board = board
        self.rack = rack
        self.score = score
        presenters = [board, rack, score]
    }
    
    func refresh(in view: GameView, with game: Game) {
        presenters.forEach({ $0.refresh(in: view, with: game) })
    }
}
