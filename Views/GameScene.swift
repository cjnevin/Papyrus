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
        
        class Player {
            var score = 0
            init() {
                score = 0
            }
            
            func incrementScore(value: Int) {
                score += value
                println("Add Score: \(value), new score: \(score)")
            }
        }
        
        var game: Locution
        var player: Player // Create array
        var squareSprites: [SquareSprite]
        var rackSprites: [TileSprite]
        var draggedSprite: TileSprite?
        var originalPoint: CGPoint?
        
        init(view: SKView, node: SKNode) {
            self.game = Locution()
            self.player = Player()
            self.squareSprites = SquareSprite.createSprites(forGame: game, frame: view.frame)
            self.rackSprites = TileSprite.createRackSprites(forGame: game, frame: view.frame)
            self.setup(inView: view, node: node)
        }
        
        private func setup(inView view: SKView, node: SKNode) {
            for sprite in self.squareSprites {
                node.addChild(sprite)
            }
            for sprite in self.rackSprites {
                node.addChild(sprite)
            }
        }
        
        func reset(inView view: SKView, node: SKNode) {
            for sprite in self.squareSprites {
                sprite.removeFromParent()
            }
            for sprite in self.rackSprites {
                sprite.removeFromParent()
            }
            self.draggedSprite = nil
            self.originalPoint = nil
            self.squareSprites.removeAll(keepCapacity: false)
            self.rackSprites.removeAll(keepCapacity: false)
            self.game = Locution()
            self.player = Player()
            self.squareSprites = SquareSprite.createSprites(forGame: game, frame: view.frame)
            self.rackSprites = TileSprite.createRackSprites(forGame: game, frame: view.frame)
            self.setup(inView: view, node: node)
        }
        
        func droppedTiles() -> [TileSprite] {
            var tiles = [TileSprite]()
            for squareSprite in filledSquares() {
                if let tileSprite = squareSprite.tileSprite {
                    tiles.append(tileSprite)
                }
            }
            return tiles
        }
        
        func filledSquares() -> [SquareSprite] {
            var tiles = [SquareSprite]()
            for squareSprite in squareSprites {
                if let movable = squareSprite.tileSprite?.movable {
                    if movable {
                        tiles.append(squareSprite)
                    }
                }
            }
            return tiles
        }
        
        func validate() -> Bool {
            // Check that word lines up correctly
            return true
        }
        
        func submit() -> Bool {
            if validate() {
                var score = 0
                var multiplier = 1
                for squareSprite in filledSquares() {
                    if let square = squareSprite.square {
                        multiplier *= square.wordMultiplier()
                        score += square.value()
                    }
                    if let tileSprite = squareSprite.tileSprite {
                        tileSprite.movable = false
                    }
                }
                println("Score pre-multiply: \(score)")
                score *= multiplier
                player.incrementScore(score)
                return true
            }
            return false
        }
    }
    
    var gameState: GameState?
    
    func newGame() {
        if let gameState = self.gameState {
            gameState.reset(inView: view, node: self)
        } else {
            self.gameState = GameState(view:view, node:self)
        }
    }
    
    override func didMoveToView(view: SKView) {
        self.newGame()
        
        var submit = SKLabelNode(text: "Submit")
        submit.position = view.center
        submit.position.y -= 100
        self.addChild(submit)
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
                } else if let labelNode = child as? SKLabelNode {
                    gameState?.submit()
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
