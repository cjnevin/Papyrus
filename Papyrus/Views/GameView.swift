//
//  GameView.swift
//  Papyrus
//
//  Created by Chris Nevin on 22/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

typealias BlankSquares = [(x: Int, y: Int)]
typealias PlacedTiles = [(x: Int, y: Int, letter: Character)]
typealias Square = (x: Int, y: Int, rect: CGRect)
typealias Intersection = (x: Int, y: Int, rect: CGRect, intersection: CGRect)

class GameView: UIView {
    var onBlank: ((tileView: TileView) -> ())?
    var onPlacement: (() -> ())?
    
    var blanks: BlankSquares {
        return tileViews?.flatMap({ $0.isPlaced && $0.isBlank ? ($0.x!, $0.y!) : nil }) ?? []
    }
    
    var placedTiles: PlacedTiles {
        return tileViews?.flatMap({ $0.isPlaced ? ($0.x!, $0.y!, $0.tile) : nil }) ?? []
    }
    
    var boardDrawable: BoardDrawable? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var scoresDrawable: ScoresDrawable? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var rackedTiles: [RackedTile]? {
        didSet {
            func tileView(for tile: RackedTile) -> TileView {
                let view = TileView(frame: tile.rect, tile: tile.tile, points: tile.points, onBoard: false, delegate: tile.movable ? self : nil)
                view.draggable = tile.movable
                return view
            }
            tileViews = rackedTiles?.map(tileView)
        }
    }
    
    private var tileViews: [TileView]? {
        willSet {
            tileViews?.forEach { $0.removeFromSuperview() }
        }
        didSet {
            tileViews?.forEach { addSubview($0) }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()
        boardDrawable?.draw(renderer: context)
        scoresDrawable?.draw(renderer: context)
        let blackColor = UIColor.black().cgColor
        context.setStrokeColor(blackColor)
        context.setLineWidth(0.5)
        context.strokePath()
        context.restoreGState()
    }
    
    private var emptySquares: [Square] {
        guard let board = boardDrawable?.board, rect = boardDrawable?.rect else { return [] }
        func boardPoint(x: CGFloat, y: CGFloat) -> CGPoint {
            return CGPoint(x: rect.origin.x + x, y: rect.origin.y + y)
        }
        let squareSize = rect.width / CGFloat(board.size)
        let placed = placedTiles
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
    
    func bestIntersection(forRect rect: CGRect) -> Intersection? {
        return emptySquares.flatMap({ (x, y, squareRect) -> Intersection? in
            let intersection = squareRect.intersection(rect)
            return intersection.widthPlusHeight > 0 ? (x, y, squareRect, intersection) : nil
        }).sorted(isOrderedBefore: { (lhs, rhs) in
            return lhs.intersection.widthPlusHeight < rhs.intersection.widthPlusHeight
        }).last
    }
}

extension GameView: TileViewDelegate {
    func dropRect(for tileView: TileView) -> CGRect {
        if let rect = boardDrawable?.rect where tileView.frame.intersects(rect) {
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
    
    func dropped(tileView: TileView) {
        onPlacement?()
        if tileView.tile == Game.blankLetter && tileView.onBoard {
            onBlank?(tileView: tileView)
        } else if tileView.isBlank && !tileView.onBoard {
            tileView.tile = Game.blankLetter
        }
    }
    
    func lifted(tileView: TileView) {
        tileView.x = nil
        tileView.y = nil
        tileView.onBoard = false
        onPlacement?()
    }
    
    func tapped(tileView: TileView) {
        fatalError()
    }
}
