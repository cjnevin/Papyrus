//
//  GameView.swift
//  Papyrus
//
//  Created by Chris Nevin on 22/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

typealias Square = (x: Int, y: Int, rect: CGRect)
typealias Intersection = (x: Int, y: Int, rect: CGRect, intersection: CGRect)

class GameView: UIView {
    var tileViewDelegate: TileViewDelegate!
    @IBOutlet weak var blackoutView: UIView!
    
    var blanks: Positions {
        return tileViews?.flatMap({ $0.isPlaced && $0.isBlank ? Position(x: $0.x!, y: $0.y!) : nil }) ?? []
    }
    
    var placedTiles: LetterPositions {
        return tileViews?.flatMap({ $0.isPlaced ? LetterPosition(x: $0.x!, y: $0.y!, letter: $0.tile) : nil }) ?? []
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
            tileViews?.forEach { insertSubview($0, belowSubview: blackoutView) }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()
        boardDrawable?.draw(renderer: context)
        scoresDrawable?.draw(renderer: context)
        let blackColor = UIColor.black.cgColor
        context.setStrokeColor(blackColor)
        context.setLineWidth(0.5)
        context.strokePath()
        context.restoreGState()
    }
    
    private var emptySquares: [Square] {
        guard let board = boardDrawable?.board, let boardRect = boardDrawable?.rect else { return [] }
        let squareSize = boardRect.width / CGFloat(board.size)
        func rect(for position: Position) -> CGRect {
            return CGRect(x: boardRect.origin.x + CGFloat(position.x) * squareSize,
                           y: boardRect.origin.y + CGFloat(position.y) * squareSize,
                           width: squareSize,
                           height: squareSize)
        }
        let placed = placedTiles.map({ $0.position })
        return board.emptyPositions.filter({ !placed.contains($0) }).flatMap({ ($0.x, $0.y, rect(for: $0)) })
    }
    
    func bestIntersection(forRect rect: CGRect) -> Intersection? {
        return emptySquares.flatMap({ (x, y, squareRect) -> Intersection? in
            let intersection = squareRect.intersection(rect)
            return intersection.widthPlusHeight > 0 ? (x, y, squareRect, intersection) : nil
        }).sorted(by: { (lhs, rhs) in
            return lhs.intersection.widthPlusHeight < rhs.intersection.widthPlusHeight
        }).last
    }
}
