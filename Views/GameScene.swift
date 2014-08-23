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
    
    var draggedSprite: TileSprite?
    var originalPoint: CGPoint?
    var game: Locution?
    
    func newGame() {
        self.game = Locution()
        if let game = self.game {
            for node in SquareSprite.createSprites(forGame: game, size: view.frame.size) {
                self.addChild(node)
            }
            for node in TileSprite.createRackSprites(forGame: game, size: view.frame.size) {
                self.addChild(node)
            }
        }
    }
    
    override func didMoveToView(view: SKView) {
        self.newGame()
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
                                self.draggedSprite = pickedUpSprite
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
            if let sprite = draggedSprite {
                sprite.position = point
            }
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            if let sprite = draggedSprite {
                var found = false
                for child in self.children {
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
                originalPoint = nil
                draggedSprite = nil
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            if let sprite = draggedSprite {
                if let origPoint = self.originalPoint {
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
