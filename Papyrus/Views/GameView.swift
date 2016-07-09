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
    var tileViewDelegate: TileViewDelegate!
    
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
                let view = TileView(frame: tile.rect, tile: tile.tile, points: tile.points, onBoard: false, delegate: tile.movable ? tileViewDelegate : nil)
                view.draggable = tile.movable
                return view
            }
            tileViews = rackedTiles?.map(tileView)
        }
    }
    
    var tileViews: [TileView]? {
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
