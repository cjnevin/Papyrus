//
//  GameLogicController.swift
//  Locution
//
//  Created by Chris Nevin on 23/08/2014.
//  Copyright (c) 2014 Alive Mobile Group. All rights reserved.
//

import Foundation
import SpriteKit

class GameLogicController {
    
    let rack: CGFloat = 7
    let dimensions = 15
    let board: Board
    let view: SKView
    let node: SKNode
    
    var draggedSprite: TileSprite?
    var originalPoint: CGPoint?
    
    // MARK: - Lifecycle
    
    init(view: SKView, node: SKNode) {
        self.board = Board(dimensions: dimensions)
        self.view = view
        self.node = node
        self.createSquareSprites()
        self.createRackTiles()
    }
    
    // MARK: - Public
    
    func touchStarted(atPoint point: CGPoint) {
        for child in node.children {
            if let sprite = child as? TileSprite {
                if sprite.containsPoint(point) {
                    self.originalPoint = sprite.position
                    self.draggedSprite = sprite
                    sprite.position = point
                    break
                }
            } else if let squareSprite = child as? SquareSprite {
                if let tileSprite = squareSprite.tileSprite {
                    if squareSprite.containsPoint(point) {
                        if let pickedUpSprite = squareSprite.pickupTileSprite() {
                            self.originalPoint = squareSprite.originalPoint
                            self.draggedSprite = pickedUpSprite
                            node.addChild(pickedUpSprite)
                            break
                        }
                    }
                }
            }
        }
    }
    
    func touchMoved(toPoint point: CGPoint) {
        if let sprite = draggedSprite {
            sprite.position = point
        }
    }
    
    func touchEnded(atPoint point: CGPoint, successful: Bool) {
        if let sprite = draggedSprite {
            if !successful {
                if let origPoint = self.originalPoint {
                    sprite.position = origPoint
                } else {
                    sprite.position = point
                }
            } else {
                var found = false
                for child in node.children {
                    if let squareSprite = child as? SquareSprite {
                        if squareSprite.intersectsNode(sprite) && squareSprite.frame.contains(point) {
                            if squareSprite.isEmpty() {
                                if let originalPoint = self.originalPoint {
                                    squareSprite.dropTileSprite(sprite, originalPoint: originalPoint)
                                    found = true
                                    break
                                }
                            }
                        }
                    }
                }
                if !found {
                    if let origPoint = self.originalPoint {
                        sprite.position = origPoint
                    }
                }
            }
            originalPoint = nil
            draggedSprite = nil
        }
    }
    
    // MARK: - Private
    
    private func createRackTiles() {
        var index = 0
        var squareSize = CGRectGetWidth(view.frame) / CGFloat(dimensions)
        var tileSize = squareSize * 2.0
        var spacing = (CGRectGetWidth(view.frame) - tileSize * rack) / 2
        for tile in board.rack {
            var sprite = TileSprite(tile: tile, edge: squareSize, scale: 2.0)
            sprite.position = CGPointMake(tileSize * CGFloat(index) + tileSize / 2 + spacing,
                tileSize / 2)
            node.addChild(sprite)
            index++
        }
    }
    
    private func createSquareSprites() {
        var squareSize = CGRectGetWidth(view.frame) / CGFloat(dimensions)
        for square in board.squares {
            var sprite = SquareSprite(square: square, edge: squareSize)
            sprite.position = CGPointMake(squareSize * CGFloat(square.point.0 - 1) + squareSize / 2,
                view.frame.size.height - squareSize * CGFloat(square.point.1 - 1) + squareSize / 2)
            node.addChild(sprite)
        }
    }
    
}