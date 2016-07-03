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

class GamePresenter: TileViewDelegate {
    private var boardRect: CGRect {
        var rect = gameView.bounds
        rect.size.height = rect.size.width
        return rect
    }
    private var squareWidth: CGFloat {
        return boardRect.width / CGFloat(game.board.size)
    }
    
    private let tileSpacing = CGFloat(5)
    private var tileRackMax: CGFloat {
        return CGFloat(Game.rackAmount)
    }
    private var tileWidth: CGFloat {
        return (boardRect.width - (tileSpacing * tileRackMax) - tileSpacing) / tileRackMax
    }
    
    var gameView: GameView!
    var onBlank: ((tileView: TileView) -> ())!
    var onPlacement: (() -> ())!
    
    private(set) var game: Game!
    func updateGame(_ game: Game) {
        self.game = game
        let move = game.lastMove
        gameView.tileViews = nil
        gameView.drawable = BoardDrawable(board: game.board, letterPoints: game.bag.dynamicType.letterPoints, move: move, rect: boardRect)
        if game.player is Computer { return }
        gameView.tileViews = rackTiles()
    }
    
    func rackTiles() -> [TileView] {
        let y = boardRect.width + tileSpacing
        let width = tileWidth
        return game.player.rack.enumerated().map ({ (index, tile) in
            let x = tileSpacing + ((tileSpacing + width) * CGFloat(index))
            let tileRect = CGRect(x: x, y: y, width: width, height: width)
            let points = tile.isBlank ? 0 : game.bag.dynamicType.letterPoints[tile.letter] ?? 0
            let tileView = TileView(frame: tileRect, tile: tile.letter, points: points, onBoard: false, delegate: self)
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
        for (y, column) in game.board.layout.enumerated() {
            for (x, square) in column.enumerated() {
                let point = CGPoint(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                let rect = CGRect(origin: point, size: CGSize(width: squareSize, height: squareSize))
                if square == game.board.empty && placed.filter({ $0.x == x && $0.y == y }).count == 0 {
                    suitable.append((x, y, rect))
                }
            }
        }
        return suitable
    }
    
    typealias Intersection = (x: Int, y: Int, rect: CGRect, intersection: CGRect)
    func bestIntersection(forRect rect: CGRect) -> Intersection? {
        return suitableSquares.flatMap({ (x, y, squareRect) -> Intersection? in
            let intersection = squareRect.intersection(rect)
            return intersection.widthPlusHeight > 0 ? (x, y, squareRect, intersection) : nil
        }).sorted(isOrderedBefore: { (lhs, rhs) in
            return lhs.intersection.widthPlusHeight < rhs.intersection.widthPlusHeight
        }).last
    }
    
    func tapped(_ tileView: TileView) {
        
    }
    
    func pickedUp(_ tileView: TileView) {
        tileView.x = nil
        tileView.y = nil
        tileView.onBoard = false
        onPlacement()
    }
    
    func frameForDropping(_ tileView: TileView) -> CGRect {
        if tileView.frame.intersects(boardRect) {
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
        onPlacement()
        if tileView.tile == Game.blankLetter && tileView.onBoard {
            onBlank(tileView: tileView)
        } else if tileView.isBlank && !tileView.onBoard {
            tileView.tile = Game.blankLetter
        }
    }
}
