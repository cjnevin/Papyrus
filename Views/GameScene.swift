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
	
	//var gameState: GameState?
	var actionDelegate: GameSceneProtocol?
	
	var squareSprites = [SquareSprite]()
	var rackSprites = [TileSprite]()
	var draggedSprite: TileSprite?
	var originalPoint: CGPoint?
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
	
	// MARK:- Game Management
	
	func changedGameState(state: GameWrapperState) {
		switch (state) {
		case .Preparing:
			println("Preparing")
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
		case .Ready:
			println("Ready")
			if let game = GameWrapper.sharedInstance.game {
				self.squareSprites = SquareSprite.createSprites(forGame: game, frame: self.frame)
				self.rackSprites = TileSprite.createRackSprites(forGame: game, frame: self.frame)
				for sprite in self.squareSprites {
					self.addChild(sprite)
				}
				for sprite in self.rackSprites {
					self.addChild(sprite)
				}
			}
		default:
			println("Other")
		}
	}
	
	private func squareSprites(forSquares squares: [Square]) -> [SquareSprite] {
		var sprites = [SquareSprite]()
		for sprite in squareSprites {
			if let square = sprite.square where contains(squares, square) {
				sprites.append(sprite)
			}
		}
		return sprites
	}
	
	func submit() -> (success: Bool, errors: [String]) {
		if let game = GameWrapper.sharedInstance.game {
			// Collect words we changed
			var words = [Word]()
			let squares = mutableSquareSprites.map({$0.square!})
			let (success, errors) = game.validate(squares, outWords: &words)
			if !success {
				return (success, errors)
			}
			
			// Get new sprites for played words
			var sprites = [SquareSprite]()
			for word in words {
				sprites.extend(squareSprites(forSquares:word.squares))
			}
			
			// Add words to board
			game.board.words.extend(words)
			
			// Calculate score
			var sum = words.map{$0.points}.reduce(0, combine: +)
			// Player used all tiles, reward them
			if mutableSquareSprites.count == 7 {
				sum += 50
			}
			game.currentPlayer?.incrementScore(sum)
			
			// Illuminate the words we changed
			SquareSprite.illuminateSprites([immutableSquareSprites], illuminated: false)
			SquareSprite.illuminateSprites([sprites], illuminated: true)
			
			// Remove the sprites from the rack
			for sprite in sprites {
				// Stop movement of these tiles
				sprite.tileSprite?.movable = false
				if let spriteTile = sprite.tileSprite?.tile {
					rackSprites = rackSprites.filter({$0.tile != spriteTile})
					if let rack = game.rack {
						rack.tiles = rack.tiles.filter({$0 != spriteTile})
					}
				}
				// Set square to immutable, so score won't include multipliers in future
				sprite.square?.immutable = true
			}
			for sprite in rackSprites {
				sprite.removeFromParent()
			}
			
			// Recreate rack
			if let rack = game.rack {
				rack.replenish(fromBag: game.bag)
				println("Words for rack: " + join(", ", game.dictionary.possibleWords(forLetters: rack.tiles.map({$0.letter!}))))
			}
			rackSprites = TileSprite.createRackSprites(forGame: game, frame: self.frame)
			for sprite in rackSprites {
				self.addChild(sprite)
			}
			
			// Return success
			return (true, errors)
		} else {
			return (false, ["Game not created yet."])
		}
	}
	
	// MARK:- Touches
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if let point = (touches.first as? UITouch)?.locationInNode(self) {
			for child in children {
				if let sprite = child as? TileSprite where sprite.containsPoint(point) && !sprite.hasActions() {
					originalPoint = sprite.position
					draggedSprite = sprite
					//sprite.resetPosition(point)
					sprite.animatePickupFromRack(point)
					break
				} else if let squareSprite = child as? SquareSprite, tileSprite = squareSprite.tileSprite where squareSprite.containsPoint(point) {
					if let sprite = squareSprite.pickupTileSprite() {
						originalPoint = squareSprite.originalPoint
						draggedSprite = sprite
						addChild(sprite)
						sprite.animateGrow()
						break
					}
				}
			}
		}
	}
	
	override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
		if let point = (touches.first as? UITouch)?.locationInNode(self), sprite = draggedSprite {
			sprite.resetPosition(point)
		}
	}
	
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		if let point = (touches.first as? UITouch)?.locationInNode(self), sprite = draggedSprite {
			var found = false
			var fallback: SquareSprite?     // Closest square to drop tile if hovered square is filled
			var fallbackOverlap: CGFloat = 0
			for child in children {
				if let squareSprite = child as? SquareSprite where squareSprite.intersectsNode(sprite) && squareSprite.isEmpty() {
					if squareSprite.frame.contains(point) {
						if let originalPoint = originalPoint {
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
				if let origPoint = originalPoint {
					if let squareSprite = fallback {
						squareSprite.animateDropTileSprite(sprite, originalPoint: origPoint, completion: nil)
					} else {
						//sprite.resetPosition(originalPoint)
						sprite.animateDropToRack(origPoint)
					}
				}
			}
			originalPoint = nil
			draggedSprite = nil
		}
	}
	
	override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
		if let point = (touches.first as? UITouch)?.locationInNode(self), sprite = draggedSprite {
			// Best not to animate this...
			if let origPoint = originalPoint {
				sprite.resetPosition(origPoint)
			} else {
				sprite.resetPosition(point)
			}
		}
	}
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
	}
}
