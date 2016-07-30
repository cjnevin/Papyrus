//
//  BoardCell.swift
//  Papyrus
//
//  Created by Chris Nevin on 7/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class BoardCell : UITableViewCell, NibLoadable {
    private let gameTypes: [GameType] = [.scrabble, .superScrabble, .wordfeud, .wordsWithFriends]
    private(set) var gameTypeIndex: Int = 0
    private var boardPresenter: BoardPresenter!
    
    @IBOutlet private weak var boardView: BoardView!

    override func layoutSubviews() {
        super.layoutSubviews()
        boardView.layoutIfNeeded()
        boardPresenter = BoardPresenter(rect: boardView.bounds.insetBy(dx: 1, dy: 1))
        go(to: gameTypeIndex)
    }
    
    func configure(index: Int) {
        gameTypeIndex = index
    }
    
    private func go(to: Int) {
        guard gameTypes.indices.contains(to) else {
            return
        }
        gameTypeIndex = to
        boardPresenter.refresh(in: boardView, with: Board(with: gameTypes[gameTypeIndex].fileURL)!)
    }
    
    func nextBoard() {
        go(to: (gameTypeIndex + 1) % gameTypes.count)
    }
}
