//
//  GameScene.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import SpriteKit
import SceneKit

protocol GameSceneProtocol {
	func pickLetter(completion: (String) -> ())
}

class GameScene: SKScene {
	typealias Player = Game.Player
    typealias Square = Game.Board.Square
	typealias Word = Game.Board.Word
    typealias Tile = Game.Tile
    typealias SquareSprite = Sprites.SquareSprite
    typealias TileSprite = Sprites.TileSprite
    
    class GameState {
		var game: Game
        var squareSprites: [SquareSprite]
        var rackSprites: [TileSprite]
        var draggedSprite: TileSprite?
        var originalPoint: CGPoint?
        var view: SKView
		var node: SKNode
		private var mutableSquareSprites: [SquareSprite] {
			get {
				return squareSprites.filter({$0.tileSprite?.movable == true})
			}
		}
		private var immutableSquareSprites: [SquareSprite] {
			get {
				return squareSprites.filter({$0.tileSprite?.movable == false})
			}
		}
		
        init(view: SKView, node: SKNode) {
			self.game = Game()
            self.view = view
            self.node = node
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
            self.game = Game()
            self.squareSprites = SquareSprite.createSprites(forGame: game, frame: view.frame)
            self.rackSprites = TileSprite.createRackSprites(forGame: game, frame: view.frame)
            self.view = view
            self.node = node
            self.setup(inView: view, node: node)
        }
		
		func submit() -> (success: Bool, errors: [String]) {
			var words = [Word]()
			let squares = mutableSquareSprites.map({$0.square!})
			let (success, errors) = self.game.validate(squares, outWords: &words)
			if !success {
				return (success, errors)
			}
			var sprites = [SquareSprite]()
			for word in words {
				sprites.extend(getSquareSprites(forSquares:word.squares))
			}
			
			// Add words to board
			game.board.words.extend(words)
			
			var sum = words.map{$0.points}.reduce(0, combine: +)
			// Player used all tiles, reward them
			if mutableSquareSprites.count == 7 {
				sum += 50
			}
			game.currentPlayer?.incrementScore(sum)
			
			// Illuminate the wordss we changed
			illuminateWords([immutableSquareSprites], illuminated: false)
			illuminateWords([sprites], illuminated: true)
			
			// Remove the sprites from the rack
			for sprite in sprites {
				sprite.tileSprite?.movable = false
				if let spriteTile = sprite.tileSprite?.tile {
					rackSprites = rackSprites.filter({$0.tile != spriteTile})
					if let rack = game.rack {
						rack.tiles = rack.tiles.filter({$0 != spriteTile})
					}
				}
				if let square = sprite.square {
					square.immutable = true
				}
			}
			for sprite in rackSprites {
				sprite.removeFromParent()
			}
			if let rack = game.rack {
				rack.replenish(fromBag: game.bag)
			}
			rackSprites = TileSprite.createRackSprites(forGame: game, frame: view.frame)
			for sprite in rackSprites {
				node.addChild(sprite)
			}
			return (true, errors)
        }
        
        // MARK: Private
        
        private func illuminateWords(words: [[SquareSprite]], illuminated: Bool) {
            // TODO: Do a nice animation if submission is successful
            for word in words {
                for square in word {
                    if let tile = square.tileSprite {
                        if illuminated {
                            tile.color = UIColor.whiteColor()
                        } else {
                            tile.color = tile.defaultColor
                        }
                    }
                }
            }
        }
		
		private func getSquareSprites(forSquares squares: [Square]) -> [SquareSprite] {
			var sprites = [SquareSprite]()
			for sprite in squareSprites {
				if let square = sprite.square where contains(squares, square) {
					sprites.append(sprite)
				}
			}
			return sprites
		}
    }
    
    var gameState: GameState?
	var actionDelegate: GameSceneProtocol?
	
    func newGame() {
        if let gameState = self.gameState {
            gameState.reset(inView: view!, node: self)
        } else {
            self.gameState = GameState(view:view!, node:self)
        }
    }
	
    override func didMoveToView(view: SKView) {
        self.newGame()
    }
	
	
	// MARK:- Touches
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if let point = (touches.first as? UITouch)?.locationInNode(self) {
            for child in self.children {
                if let sprite = child as? TileSprite where sprite.containsPoint(point) && !sprite.hasActions() {
					gameState?.originalPoint = sprite.position
					gameState?.draggedSprite = sprite
					sprite.resetPosition(point)
					//sprite.animatePickupFromRack(point)
					break
                } else if let squareSprite = child as? SquareSprite, tileSprite = squareSprite.tileSprite where squareSprite.containsPoint(point) {
					if let sprite = squareSprite.pickupTileSprite() {
						gameState?.originalPoint = squareSprite.originalPoint
						gameState?.draggedSprite = sprite
						self.addChild(sprite)
						sprite.animateGrow()
						break
					}
                }
            }
        }
    }
	
	override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
		if let point = (touches.first as? UITouch)?.locationInNode(self), sprite = gameState?.draggedSprite {
			sprite.resetPosition(point)
        }
    }
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		if let point = (touches.first as? UITouch)?.locationInNode(self), sprite = gameState?.draggedSprite {
			var found = false
			var fallback: SquareSprite?     // Closest square to drop tile if hovered square is filled
			var fallbackOverlap: CGFloat = 0
			for child in self.children {
				if let squareSprite = child as? SquareSprite where squareSprite.intersectsNode(sprite) && squareSprite.isEmpty() {
					if squareSprite.frame.contains(point) {
						if let originalPoint = gameState?.originalPoint {
							squareSprite.animateDropTileSprite(sprite, originalPoint: originalPoint, completion: { () -> () in
								if sprite.tile?.letter == "?" {
									self.actionDelegate?.pickLetter({ (letter) -> () in
										sprite.setLetter(letter)
									})
								}
							})
 							found = true
							break
						}
					}
					let intersection = CGRectIntersection(squareSprite.frame, sprite.frame)
					let overlap = CGRectGetWidth(intersection) + CGRectGetHeight(intersection)
					if overlap > fallbackOverlap {
						fallback = squareSprite
						fallbackOverlap = overlap
					}
				}
			}
			if !found {
				if let originalPoint = gameState?.originalPoint {
					if let squareSprite = fallback {
						squareSprite.animateDropTileSprite(sprite, originalPoint: originalPoint, completion: nil)
					} else {
						sprite.resetPosition(originalPoint)
						//sprite.animateDropToRack(originalPoint)
					}
				}
			}
			gameState?.originalPoint = nil
			gameState?.draggedSprite = nil
        }
    }
	
	override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
		if let point = (touches.first as? UITouch)?.locationInNode(self), sprite = gameState?.draggedSprite {
			// Best not to animate this...
			if let originalPoint = gameState?.originalPoint {
				sprite.resetPosition(originalPoint)
			} else {
				sprite.resetPosition(point)
			}
        }
    }
	
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
