//
//  GameScene.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 Alive Mobile Group. All rights reserved.
//

import SpriteKit
import SceneKit

class GameScene: SKScene {
    var draggedSprite: TileSprite?
    var originalPoint: CGPoint?
    
    override func didMoveToView(view: SKView) {
        var dimensions = 15
        var rack: CGFloat = 7
        var board = Board(dimensions: dimensions)
        var squareSize = CGRectGetWidth(view.frame) / CGFloat(dimensions)
        for square in board.squares {
            var sprite = SquareSprite(square: square, edge: squareSize)
            sprite.position = CGPointMake(squareSize * CGFloat(square.point.0 - 1) + squareSize / 2, view.frame.size.height - squareSize * CGFloat(square.point.1 - 1) + squareSize / 2)
            self.addChild(sprite)
        }
        
        var index = 0
        var tileSize = squareSize * 2.0
        var spacing = (CGRectGetWidth(view.frame) - tileSize * rack) / 2
        for tile in board.rack {
            var sprite = TileSprite(tile: tile, edge: squareSize, scale: 2.0)
            sprite.position = CGPointMake(tileSize * CGFloat(index) + tileSize / 2 + spacing, tileSize / 2)
            self.addChild(sprite)
            index++
        }
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            for child in self.children {
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
                                self.addChild(pickedUpSprite)
                                self.draggedSprite = pickedUpSprite
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        if let sprite = draggedSprite {
            if let point = touches.anyObject().locationInNode?(self) {
                sprite.position = point
            }
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        if let sprite = draggedSprite {
            if let point = touches.anyObject().locationInNode?(self) {
                var found = false
                for child in self.children {
                    if let squareSprite = child as? SquareSprite {
                        // TODO: Get largest intersecting square
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
                    if let point = self.originalPoint {
                        sprite.position = point
                    }
                }
                originalPoint = nil
                draggedSprite = nil
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if let sprite = draggedSprite {
            if let point = self.originalPoint {
                sprite.position = point
            }
            originalPoint = nil
            draggedSprite = nil
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
