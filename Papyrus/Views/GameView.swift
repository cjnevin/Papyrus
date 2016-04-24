//
//  GameView.swift
//  Papyrus
//
//  Created by Chris Nevin on 22/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class GameView : UIView, TileViewDelegate {
    // Consts
    private let tileSpacing = CGFloat(5)
    
    var rackMax: CGFloat { return CGFloat(game?.rackAmount ?? 0) }
    var game: Game? {
        didSet {
            dropped.removeAll()
            setNeedsDisplay()
        }
    }
    var dropped = Set<TileView>()
    
    /// - returns: Tuples containing square and rect for empty squares.
    typealias Square = (x: Int, y: Int, rect: CGRect)
    private var suitableSquareFrames: [Square] {
        guard let game = game else { return [] }
        let dimensions = CGFloat(game.board.boardSize)
        let squareSize = CGRectGetWidth(boardRect) / dimensions
        var suitable = [Square]()
        for (y, column) in game.board.board.enumerate() {
            for (x, square) in column.enumerate() {
                let point = CGPoint(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                let rect = CGRect(origin: point, size: CGSize(width: squareSize, height: squareSize))
                if square == game.board.empty && dropped.filter({ $0.frame == rect }).count == 0 {
                    suitable.append((x, y, rect))
                }
            }
        }
        return suitable
    }
    
    // UI
    private var tileViews: [TileView]?
    
    override func didMoveToSuperview() {
        if superview != nil {
            replaceRackTiles()
        } else {
            tileViews = nil
        }
    }
    
    private var boardRect: CGRect {
        var rect = bounds
        rect.size.height = rect.size.width
        return rect
    }
    
    override func drawRect(rect: CGRect) {
        guard let game = game, context = UIGraphicsGetCurrentContext() else {
            return
        }
        CGContextSaveGState(context)
        BoardDrawable(board: game.board, rect: boardRect).draw(context)
        let blackColor = UIColor.blackColor().CGColor
        CGContextSetStrokeColorWithColor(context, blackColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
    
    /// Replace rack sprites with newly drawn tiles.
    func replaceRackTiles() {
        guard let game = game else {
            return
        }
        tileViews?.forEach { $0.removeFromSuperview() }
        let tileY = bounds.size.width + tileSpacing
        let tileEdge = (CGRectGetWidth(bounds) - (tileSpacing * rackMax) - tileSpacing) / rackMax
        tileViews = game.player.rack.enumerate().map{ (index, tile) in
            let tileX = tileSpacing + ((tileSpacing + tileEdge) * CGFloat(index))
            let tileRect = CGRect(x: tileX, y: tileY, width: tileEdge, height: tileEdge)
            return TileView(frame: tileRect, tile: tile, points: game.board.letterPoints[tile] ?? 0, onBoard: false, delegate: self)
        }
        tileViews?.forEach { addSubview($0) }
    }
    
    // MARK: - TileViewDelegate
    
    func bestIntersection(forRect: CGRect) -> (x: Int, y: Int, rect: CGRect, intersection: CGRect)? {
        return suitableSquareFrames.flatMap({ (x, y, squareRect) -> (x: Int, y: Int, rect: CGRect, intersection: CGRect)? in
            let intersection = CGRectIntersection(squareRect, forRect)
            return intersection.widthPlusHeight > 0 ? (x, y, squareRect, intersection) : nil
        }).sort({ (lhs, rhs) in
            return lhs.intersection.widthPlusHeight < rhs.intersection.widthPlusHeight
        }).last
    }
    
    func frameForDropping(tileView: TileView) -> CGRect {
        if CGRectIntersectsRect(tileView.frame, boardRect) {
            if let intersection = bestIntersection(tileView.frame) {
                dropped.insert(tileView)
                tileView.onBoard = true
                return intersection.rect
            }
        }
        // Fallback, return current frame
        return tileView.initialFrame
    }
    
    func pickedUp(tileView: TileView) {
        if let index = dropped.indexOf(tileView) {
            dropped.removeAtIndex(index)
        }
        tileView.onBoard = false
    }
}