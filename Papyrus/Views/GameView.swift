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
    
    /// - returns: Tuples containing square and rect for empty squares.
    private var suitableSquareFrames: [(Square, CGRect)] {
        guard let dimensions = game?.dimensions, squares = game?.flattenedSquares where dimensions > 0 else {
            return []
        }
        let edge = CGRectGetWidth(boardRect) / CGFloat(dimensions)
        return squares.filter{ $0.tile == nil }.map{ ($0, $0.rectWithEdge(edge)) }
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
        guard let squares = game?.flattenedSquares, context = UIGraphicsGetCurrentContext() else {
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
        tileViews = game?.rackTiles?.enumerate().map{ (index, tile) in
            let tileX = tileSpacing + ((tileSpacing + tileEdge) * CGFloat(index))
            let tileRect = CGRect(x: tileX, y: tileY, width: tileEdge, height: tileEdge)
            return TileView(frame: tileRect, tile: tile, delegate: self)
        }
        tileViews?.forEach { addSubview($0) }
    }
    
    // MARK: - TileViewDelegate
    
    func bestIntersection(forRect: CGRect) -> (square: Square, rect: CGRect, intersection: CGRect)? {
        return suitableSquareFrames.flatMap({ (square, squareRect) -> (square: Square, rect: CGRect, intersection: CGRect)? in
            let intersection = CGRectIntersection(squareRect, forRect)
            return intersection.widthPlusHeight > 0 ? (square, squareRect, intersection) : nil
        }).sort({ (lhs, rhs) in
            return lhs.intersection.widthPlusHeight < rhs.intersection.widthPlusHeight
        }).last
    }
    
    func frameForDropping(tileView: TileView) -> CGRect {
        if CGRectIntersectsRect(tileView.frame, boardRect) {
            if let intersection = bestIntersection(tileView.frame) {
                assert(intersection.square.tile == nil)
                intersection.square.tile = tileView.tile
                tileView.tile.placement = .Board
                return intersection.rect
            }
        }
        // Fallback, return current frame
        return tileView.initialFrame
    }
    
    func pickedUp(tileView: TileView) {
        game?.flattenedSquares?
            .filter{ $0.tile == tileView.tile }
            .forEach{ $0.tile = nil }
        tileView.tile.placement = .Held
    }
}