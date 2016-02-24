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
    private let rackMax = CGFloat(PapyrusRackAmount)
    
    var game: Papyrus?
    
    /// - returns: Dimensions of board.
    private var dimensions: Int {
        guard let squares = squares else {
            return 0
        }
        return Int(sqrt(Double(squares.count)))
    }
    /// - returns: Tuples containing square and rect for empty squares.
    private var suitableSquareFrames: [(Square, CGRect)] {
        if dimensions == 0 {
            return []
        }
        let edge = CGRectGetWidth(boardRect) / CGFloat(dimensions)
        return squares?.flatMap{ (square) in
            if square.tile == nil {
                return (square, square.rectWithEdge(edge))
            }
            return nil
        } ?? []
    }
    /// - returns: All squares, flattened.
    private var squares: [Square]? {
        return game?.squares.flatMap{ $0 }
    }
    // TODO: Change this to Human player only.
    /// - returns: All tiles for current player.
    private var rackTiles: [Tile]? {
        return Array(game?.player?.tiles ?? [])
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
        guard let squares = squares, context = UIGraphicsGetCurrentContext() else {
            return
        }
        CGContextSaveGState(context)
        BoardDrawable(squares: squares, rect: boardRect).draw(context)
        let blackColor = UIColor.blackColor().CGColor
        CGContextSetStrokeColorWithColor(context, blackColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
    
    /// Replace rack sprites with newly drawn tiles.
    func replaceRackTiles() {
        tileViews?.forEach { $0.removeFromSuperview() }
        let tileY = bounds.size.width + tileSpacing
        let tileEdge = (CGRectGetWidth(bounds) - (tileSpacing * rackMax) - tileSpacing) / rackMax
        tileViews = rackTiles?.enumerate().map{ (index, tile) in
            let tileX = tileSpacing + ((tileSpacing + tileEdge) * CGFloat(index))
            let tileRect = CGRect(x: tileX, y: tileY, width: tileEdge, height: tileEdge)
            return TileView(frame: tileRect, tile: tile, delegate: self)
        }
        tileViews?.forEach { addSubview($0) }
    }
    
    // MARK: - TileViewDelegate
    
    func frameForDropping(tileView: TileView) -> CGRect {
        if CGRectIntersectsRect(tileView.frame, boardRect) {
            if let bestSquareRect = suitableSquareFrames.flatMap({ (square, squareRect) -> (square: Square, rect: CGRect, intersection: CGRect)? in
                let intersection = CGRectIntersection(squareRect, tileView.frame)
                if intersection.width > 0 && intersection.height > 0 {
                    return (square, squareRect, intersection)
                }
                return nil
            }).sort({ (lhs, rhs) in
                return lhs.intersection.width + lhs.intersection.height <
                    rhs.intersection.width + rhs.intersection.height
            }).last {
                assert(bestSquareRect.square.tile == nil)
                bestSquareRect.square.tile = tileView.tile
                tileView.tile.placement = .Board
                return bestSquareRect.rect
            }
        }
        // Fallback, return current frame
        return tileView.frame
    }
    
    func pickedUp(tileView: TileView) {
        squares?
            .filter{ $0.tile == tileView.tile }
            .forEach{ $0.tile = nil }
        tileView.tile.placement = .Held
    }
}