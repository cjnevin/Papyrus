//
//  BoardPresenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 4/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

typealias BlankSquares = [(x: Int, y: Int)]
typealias PlacedTiles = [(x: Int, y: Int, letter: Character)]
typealias Square = (x: Int, y: Int, rect: CGRect)

class BoardPresenter: Presenter {
    private func boardPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: rect.origin.x + x, y: rect.origin.y + y)
    }
    
    var blanks: BlankSquares {
        return gameView?.tileViews?.flatMap({ $0.isPlaced && $0.isBlank ? ($0.x!, $0.y!) : nil }) ?? []
    }
    
    var tiles: PlacedTiles {
        return gameView?.tileViews?.flatMap({ $0.isPlaced ? ($0.x!, $0.y!, $0.tile) : nil }) ?? []
    }
    
    private var board: Board?
    private var gameView: GameView?
    private let rect: CGRect
    private let onBlank: ((tileView: TileView) -> ())?
    private let onPlacement: (() -> ())?
    
    init(rect: CGRect, onPlacement: (() -> ())? = nil, onBlank: ((tileView: TileView) -> ())? = nil) {
        self.rect = rect
        self.onBlank = onBlank
        self.onPlacement = onPlacement
    }
    
    func refresh(in view: GameView, with game: Game) {
        // Store these for calculations later
        self.board = game.board
        self.gameView = view
        
        view.drawable = BoardDrawable(board: game.board, letterPoints: game.bag.dynamicType.letterPoints, move: game.lastMove, rect: rect)
    }
    
    func refresh(in view: BoardView, with board: Board) {
        self.board = board
        view.drawable = BoardDrawable(board: board, rect: rect)
    }

    /// - returns: Tuples containing square and rect for empty squares.
    private var suitableSquares: [Square] {
        guard let board = board else { return [] }
        let squareSize = rect.width / CGFloat(board.size)
        let placed = tiles
        var suitable = [Square]()
        for (y, column) in board.layout.enumerated() {
            for (x, square) in column.enumerated() {
                let point = boardPoint(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                let rect = CGRect(origin: point, size: CGSize(width: squareSize, height: squareSize))
                if square == board.empty && placed.filter({ $0.x == x && $0.y == y }).count == 0 {
                    suitable.append((x, y, rect))
                }
            }
        }
        return suitable
    }
    
    private typealias Intersection = (x: Int, y: Int, rect: CGRect, intersection: CGRect)
    private func bestIntersection(forRect rect: CGRect) -> Intersection? {
        return suitableSquares.flatMap({ (x, y, squareRect) -> Intersection? in
            let intersection = squareRect.intersection(rect)
            return intersection.widthPlusHeight > 0 ? (x, y, squareRect, intersection) : nil
        }).sorted(isOrderedBefore: { (lhs, rhs) in
            return lhs.intersection.widthPlusHeight < rhs.intersection.widthPlusHeight
        }).last
    }
}

extension BoardPresenter: TileViewDelegate {
    func tapped(_ tileView: TileView) { }
    
    func pickedUp(_ tileView: TileView) {
        tileView.x = nil
        tileView.y = nil
        tileView.onBoard = false
        onPlacement?()
    }
    
    func frameForDropping(_ tileView: TileView) -> CGRect {
        if tileView.frame.intersects(rect) {
            if let intersection = bestIntersection(forRect: tileView.frame) {
                tileView.onBoard = true
                tileView.x = intersection.x
                tileView.y = intersection.y
                return intersection.rect
            }
        }
        // Fallback, return current frame
        return tileView.initialFrame
    }
    
    func dropped(_ tileView: TileView) {
        onPlacement?()
        if tileView.tile == Game.blankLetter && tileView.onBoard {
            onBlank?(tileView: tileView)
        } else if tileView.isBlank && !tileView.onBoard {
            tileView.tile = Game.blankLetter
        }
    }
}
