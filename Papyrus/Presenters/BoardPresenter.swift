//
//  BoardPresenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 4/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

class BoardPresenter: Presenter {
    private let rect: CGRect
    
    init(rect: CGRect) {
        self.rect = rect
    }
    
    func refresh(in view: GameView, with game: Game) {
        view.boardDrawable = BoardDrawable(board: game.board, letterPoints: game.bag.letterPoints, move: game.lastMove, rect: rect)
    }
    
    func refresh(in view: BoardView, with board: Board) {
        view.drawable = BoardDrawable(board: board, rect: rect)
    }
}
