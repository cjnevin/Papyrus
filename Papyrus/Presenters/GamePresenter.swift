//
//  GamePresenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

typealias PlacedTile = [(x: Int, y: Int, letter: Character)]

protocol GamePresenterDelegate {
    func handlePlacement(presenter: GamePresenter)
    func handleBlank(tileView: TileView, presenter: GamePresenter)
}

class GamePresenter: TileViewDelegate {
    private var boardRect: CGRect {
        var rect = gameView.bounds
        rect.size.height = rect.size.width
        return rect
    }
    private var squareWidth: CGFloat {
        return CGRectGetWidth(boardRect) / CGFloat(game.board.config.size)
    }
    
    private let tileSpacing = CGFloat(5)
    private var tileRackMax: CGFloat {
        return CGFloat(game.rackAmount)
    }
    private var tileWidth: CGFloat {
        return (CGRectGetWidth(boardRect) - (tileSpacing * tileRackMax) - tileSpacing) / tileRackMax
    }
    
    var delegate: GamePresenterDelegate!
    var gameView: GameView!
    var game: Game! {
        didSet {
            gameView.tileViews = nil
            gameView.drawable = BoardDrawable(board: game.board, distribution: game.bag.distribution, rect: boardRect)
            if game.player is Computer { return }
            gameView.tileViews = rackTiles()
        }
    }
    
    func rackTiles() -> [TileView] {
        let y = CGRectGetWidth(boardRect) + tileSpacing
        let width = tileWidth
        return game.player.rack.enumerate().map ({ (index, tile) in
            let x = tileSpacing + ((tileSpacing + width) * CGFloat(index))
            let tileRect = CGRect(x: x, y: y, width: width, height: width)
            let tileView = TileView(frame: tileRect, tile: tile.letter, points: tile.isBlank ? 0 : game.bag.distribution.letterPoints[tile.letter] ?? 0, onBoard: false, delegate: self)
            tileView.draggable = true
            return tileView
        })
    }
    
    // MARK: TileViewDelegate
    
    func placedTiles() -> PlacedTile {
        let shrunkTiles = gameView.tileViews!.filter({ $0.x != nil && $0.y != nil })
        return shrunkTiles.map({ ($0.x!, $0.y!, $0.tile) })
    }
    
    func blankTiles() -> [(x: Int, y: Int)] {
        let shrunkTiles = gameView.tileViews!.filter({ $0.x != nil && $0.y != nil && $0.isBlank })
        return shrunkTiles.map({ ($0.x!, $0.y!) })
    }
    
    typealias Square = (x: Int, y: Int, rect: CGRect)
    
    /// - returns: Tuples containing square and rect for empty squares.
    private var suitableSquares: [Square] {
        let squareSize = squareWidth
        let placed = placedTiles()
        var suitable = [Square]()
        for (y, column) in game.board.board.enumerate() {
            for (x, square) in column.enumerate() {
                let point = CGPoint(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                let rect = CGRect(origin: point, size: CGSize(width: squareSize, height: squareSize))
                if square == game.board.config.empty && placed.filter({ $0.x == x && $0.y == y }).count == 0 {
                    suitable.append((x, y, rect))
                }
            }
        }
        return suitable
    }
    
    func bestIntersection(forRect: CGRect) -> (x: Int, y: Int, rect: CGRect, intersection: CGRect)? {
        return suitableSquares.flatMap({ (x, y, squareRect) -> (x: Int, y: Int, rect: CGRect, intersection: CGRect)? in
            let intersection = CGRectIntersection(squareRect, forRect)
            return intersection.widthPlusHeight > 0 ? (x, y, squareRect, intersection) : nil
        }).sort({ (lhs, rhs) in
            return lhs.intersection.widthPlusHeight < rhs.intersection.widthPlusHeight
        }).last
    }
    
    func tapped(tileView: TileView) {
        
    }
    
    func pickedUp(tileView: TileView) {
        tileView.x = nil
        tileView.y = nil
        tileView.onBoard = false
        delegate.handlePlacement(self)
    }
    
    func frameForDropping(tileView: TileView) -> CGRect {
        if CGRectIntersectsRect(tileView.frame, boardRect) {
            if let intersection = bestIntersection(tileView.frame) {
                tileView.onBoard = true
                tileView.x = intersection.x
                tileView.y = intersection.y
                return intersection.rect
            }
        }
        // Fallback, return current frame
        return tileView.initialFrame
    }
    
    func dropped(tileView: TileView) {
        delegate.handlePlacement(self)
        if tileView.tile == Bag.blankLetter {
            delegate.handleBlank(tileView, presenter: self)
        }
    }
}