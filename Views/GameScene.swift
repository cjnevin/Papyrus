//
//  GameScene.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import SpriteKit
import SceneKit

class GameScene: SKScene {
    typealias Square = Locution.Board.Square
    typealias Tile = Locution.Tile
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
        
        func playedWordSprites() -> [[SquareSprite]] {
            var currentSprites = mutableSquareSprites()
            var sprites = Sprites.SquareSprite.intersectingSprites(sprites: currentSprites, inSprites: immutableSquareSprites(), dimensions: game.board.dimensions)
            sprites.append(currentSprites)
            return sprites
        }
        
        func validate() -> Bool {
            // TODO: Check that if single tile, it must intersect another word
            
            // Check that word lines up correctly
            var words = playedWordSprites()
            if words.count == 0 {
                // If no words, return
                return false
            } else if words.count == 1 {
                // If single word, it must include center tile
                if words.first?.filter({$0.square?.squareType == Locution.Board.Square.SquareType.Center}).count == 0 {
                    return false
                }
            }
            // TODO: Validate each of the words, to ensure that they exist in the dictionary
            for word in words {
                
            }
            // Check that word intercepts center tile or another word
            return true
        }
        
        func wordValue(word: [SquareSprite]) -> Int {
            var wordValue = 0
            var wordMultiplier = 1
            for sprite in word {
                if let square = sprite.square {
                    wordValue += square.value()
                    wordMultiplier *= square.wordMultiplier()
                }
            }
            return wordValue * wordMultiplier
        }
        
        func submit() -> Bool {
            if validate() {
                var currentSprites = mutableSquareSprites()
                var intersectingSprites = Sprites.SquareSprite.intersectingSprites(sprites: currentSprites, inSprites: immutableSquareSprites(), dimensions: game.board.dimensions)
                //var words = playedWordSprites()
                illuminateWords(intersectingSprites, illuminated: false)
                illuminateWords([currentSprites], illuminated: true)
                var totalValue = 0
                for word in intersectingSprites {
                    var value = wordValue(word)
                    println("Word value: \(value)")
                    totalValue += value
                }
                if intersectingSprites.count == 0 || currentSprites.count > 1 {
                    // we only calculate this word's value
                    var value = wordValue(currentSprites)
                    println("Word value: \(value)")
                    totalValue += value
                }
                if currentSprites.count == 7 {
                    totalValue += 50
                }
                player.incrementScore(totalValue)
                for sprite in currentSprites {
                    sprite.makeImmutable()
                }
                return true
            }
            return false
        }
        
        // MARK: Private
        
        private func illuminateWords(words: [[SquareSprite]], illuminated: Bool) {
            // TODO: Do a nice animation if submission is successful
            for word in words {
                for square in word {
                    if let tile = square.tileSprite {
                        if illuminated {
                            tile.color = UIColor.redColor()
                        } else {
                            tile.color = tile.defaultColor
                        }
                    }
                }
            }
        }
        
        private func tileSpritesForSquareSprites(squareSprite: SquareSprite) -> TileSprite? {
            return squareSprite.tileSprite
        }
        
        private func mutableSquareSprites() -> [SquareSprite] {
            return squareSprites.filter({$0.tileSprite?.movable == true})
        }
        
        private func mutableTileSprites() -> [TileSprite?] {
            return mutableSquareSprites().map(tileSpritesForSquareSprites)
        }
        
        private func immutableSquareSprites() -> [SquareSprite] {
            return squareSprites.filter({$0.tileSprite?.movable == false})
        }
        
        private func immutableTileSprites() -> [TileSprite?] {
            return immutableSquareSprites().map(tileSpritesForSquareSprites)
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
