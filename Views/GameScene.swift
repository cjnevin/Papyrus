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
    typealias SquareSprite = Sprites.SquareSprite
    typealias TileSprite = Sprites.TileSprite
    
    class GameState {
        var squareSprites: [SquareSprite]
        var rackSprites: [TileSprite]
        let game: Locution
        
        var draggedSprite: TileSprite?
        var originalPoint: CGPoint?
        
        init(view: SKView, node: SKNode) {
            self.game = Locution()
            self.squareSprites = SquareSprite.createSprites(forGame: game, size: view.frame.size)
            self.rackSprites = TileSprite.createRackSprites(forGame: game, size: view.frame.size)
            for sprite in self.squareSprites {
                node.addChild(sprite)
            }
            for sprite in self.rackSprites {
                node.addChild(sprite)
            }
        }
    }
    
    var gameState: GameState?
    
    func newGame() {
        self.gameState = GameState(view:view, node:self)
    }
    
    override func didMoveToView(view: SKView) {
        self.newGame()
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            for child in self.children {
                if let sprite = child as? TileSprite {
                    if sprite.containsPoint(point) {
                        gameState?.originalPoint = sprite.position
                        gameState?.draggedSprite = sprite
                        sprite.position = point
                        break
                    }
                } else if let squareSprite = child as? SquareSprite {
                    if let tileSprite = squareSprite.tileSprite {
                        if squareSprite.containsPoint(point) {
                            if let pickedUpSprite = squareSprite.pickupTileSprite() {
                                gameState?.originalPoint = squareSprite.originalPoint
                                gameState?.draggedSprite = pickedUpSprite
                                self.addChild(pickedUpSprite)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            if let sprite = gameState?.draggedSprite {
                sprite.position = point
            }
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            if let sprite = gameState?.draggedSprite {
                var found = false
                var fallback: SquareSprite?     // Closest square to drop tile if hovered square is filled
                var fallbackOverlap: CGFloat = 0
                for child in self.children {
                    if let squareSprite = child as? SquareSprite {
                        if squareSprite.intersectsNode(sprite) {
                            if squareSprite.isEmpty() {
                                if squareSprite.frame.contains(point) {
                                    if let originalPoint = gameState?.originalPoint {
                                        squareSprite.dropTileSprite(sprite, originalPoint: originalPoint)
                                        found = true
                                        break
                                    }
                                }
                                var intersection = CGRectIntersection(squareSprite.frame, sprite.frame)
                                var overlap = CGRectGetWidth(intersection) + CGRectGetHeight(intersection)
                                if overlap > fallbackOverlap {
                                    fallback = squareSprite
                                    fallbackOverlap = overlap
                                }
                            }
                        }
                    }
                }
                if !found {
                    if let originalPoint = gameState?.originalPoint {
                        if let squareSprite = fallback {
                            squareSprite.dropTileSprite(sprite, originalPoint: originalPoint)
                        } else {
                            sprite.position = originalPoint
                        }
                    }
                }
                gameState?.originalPoint = nil
                gameState?.draggedSprite = nil
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            if let sprite = gameState?.draggedSprite {
                if let origPoint = gameState?.originalPoint {
                    sprite.position = origPoint
                } else {
                    sprite.position = point
                }
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
