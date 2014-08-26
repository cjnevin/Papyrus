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
        
        func validate() -> Bool {
            // Check that word lines up correctly
            var mutableSquares = mutableSquareSprites().map({$0.square})
            if mutableSquares.count == 0 {
                return false
            } else if mutableSquares.count > 1 {
                var interceptedWords = interceptedWordsSquares(forMutableSquares: mutableSquares);
                if interceptedWords.count == 0 {
                    return false
                }
            }
            // Check that word intercepts center tile or another word
            return true
        }
        
        func submit() -> Bool {
            if validate() {
                var sprites = mutableSquareSprites()
                var score = 0
                var multiplier = 1
                for squareSprite in sprites {
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
                if (sprites.count == 7) {
                    score += 50;
                }
                player.incrementScore(score)
                return true
            }
            return false
        }
        
        // MARK: Private
        
        private func illuminateTileSprites(sprites: [TileSprite]) {
            // TODO: Do a nice animation if submission is successful
            // TODO: Get intersecting words that formed part of the submission and illuminate those as well with a time offset
        }
        
        //{(parameterTypes) -> (returnType) in statements}
        
        
        private func interceptedWordsSquares(forMutableSquares mutableSquares: [Square?]) -> [[Square]] {
            var interceptedWords: [[Square]]
            if areSquaresHorizontal(mutableSquares) {
                interceptedWords = interceptedWordsSquares(inMutableSquares: mutableSquares, horizontal: true)
            } else if areSquaresVertical(mutableSquares) {
                // Need to go left/right to determine the intercepting words on the X axis
                interceptedWords = interceptedWordsSquares(inMutableSquares: mutableSquares, horizontal: false)
            } else {
                interceptedWords = [[Square]]()
            }
            return interceptedWords
        }
        
        private func interceptedWordsSquares(inMutableSquares mutableSquares: [Square?], horizontal: Bool) -> [[Square]] {
            var validWords = [[Square]]()
            var immutableSquares = immutableSquareSprites().map({$0.square})
            for mutableSquare in mutableSquares {
                if let square = mutableSquare {
                    var x = square.point.x
                    var y = square.point.y
                    // Compare perpendicular words
                    var z = 0
                    var compare: (Square? -> Bool)
                    if horizontal {
                        compare = { $0?.point.x == x }
                        z = y
                    } else {
                        compare = { $0?.point.y == y }
                        z = x
                    }
                    var perpendicularSquares = immutableSquares.filter(compare)
                    // Ensure there are no gaps
                    var validSquares = [Square]()
                    for var i = z - 1; i > 0; i-- {
                        if horizontal {
                            compare = { $0?.point.y == i }
                        } else {
                            compare = { $0?.point.x == i }
                        }
                        var matchingSquares = perpendicularSquares.filter(compare)
                        if let matchingSquare = matchingSquares.first? {
                            validSquares.append(matchingSquare)
                        } else {
                            break
                        }
                    }
                    validSquares.append(square)
                    for var i = z + 1; i < game.board.dimensions; i++ {
                        if horizontal {
                            compare = { $0?.point.y == i }
                        } else {
                            compare = { $0?.point.x == i }
                        }
                        var matchingSquares = perpendicularSquares.filter(compare)
                        if let matchingSquare = matchingSquares.first? {
                            validSquares.append(matchingSquare)
                        } else {
                            break
                        }
                    }
                    // Intercepted vertical word
                    if validSquares.count > 1 {
                        // Calculation of these words must ignore immutable squares (i.e. only ySquare would apply any calculation that affects the whole word)
                        validWords.append(validSquares)
                        println("Intercepted Word: \(validSquares.map({$0.tile?.letter}))")
                    }
                }
            }
            return validWords
        }
        
        private func mutableSquareSprites() -> [SquareSprite] {
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
        
        private func mutableTileSprites() -> [TileSprite] {
            var tiles = [TileSprite]()
            for squareSprite in mutableSquareSprites() {
                if let tileSprite = squareSprite.tileSprite {
                    tiles.append(tileSprite)
                }
            }
            return tiles
        }
        
        private func immutableSquareSprites() -> [SquareSprite] {
            var tiles = [SquareSprite]()
            for squareSprite in squareSprites {
                if let movable = squareSprite.tileSprite?.movable {
                    if !movable {
                        tiles.append(squareSprite)
                    }
                }
            }
            return tiles
        }
        
        private func immutableTileSprites() -> [TileSprite] {
            var tiles = [TileSprite]()
            for squareSprite in immutableSquareSprites() {
                if let tileSprite = squareSprite.tileSprite {
                    tiles.append(tileSprite)
                }
            }
            return tiles
        }
        
        private func areSquaresHorizontal(squares: [Square?]) -> Bool {
            // y axis is the same
            var firstValue = squares[0]?.point.y
            var values = squares.map({$0?.point.y})
            var inline = squares.count == values.filter({$0 == firstValue}).count
            return inline
        }
        
        private func areSquaresVertical(squares: [Square?]) -> Bool {
            // x axis is the same
            var firstValue = squares[0]?.point.x
            var values = squares.map({$0?.point.x})
            var inline = squares.count == values.filter({$0 == firstValue}).count
            return inline
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
