//
//  Sprites.swift
//  Locution
//
//  Created by Chris Nevin on 23/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import SpriteKit

class Sprites {
    typealias Square = Game.Board.Square
    typealias Tile = Game.Tile
	
    class SquareSprite: SKSpriteNode {
        class func createSprites(forGame game: Game, frame: CGRect) -> [SquareSprite] {
            var sprites = [SquareSprite]()
            let squareSize = CGRectGetWidth(frame) / CGFloat(game.board.dimensions)
            for square in game.board.squares {
                let sprite = SquareSprite(square: square, edge: squareSize)
                sprite.position = CGPointMake(squareSize * CGFloat(square.c.x - 1) + squareSize / 2,
					CGRectGetHeight(frame) - squareSize * CGFloat(square.c.y) + squareSize / 2)
                sprites.append(sprite)
            }
            return sprites
        }
	
		class func illuminateSprites(sprites: [[SquareSprite]], illuminated: Bool) {
			// TODO: Do a nice animation if submission is successful
			for sprite in sprites {
				for square in sprite {
					if let tile = square.tileSprite {
						if illuminated {
							tile.color = UIColor.whiteColor()
						} else {
							tile.color = UIColor.TileColor()
						}
					}
				}
			}
		}
		
        var square: Square?
        var originalPoint: CGPoint?
        var tileSprite: TileSprite?
		
		class func colorForSquare(square: Square) -> UIColor {
			var color: UIColor
			switch (square.squareType) {
			case .Center:
				color = UIColor.CenterTileColor()
			case .DoubleLetter:
				color = UIColor.DoubleLetterTileColor()
			case .DoubleWord:
				color = UIColor.DoubleWordTileColor()
			case .TripleLetter:
				color = UIColor.TripleLetterTileColor()
			case .TripleWord:
				color = UIColor.TripleWordTileColor()
			default:
				color = UIColor.BoardTileColor()
			}
			return color
		}
		
        init(square sq: Square, edge: CGFloat) {
            square = sq
            let color = SquareSprite.colorForSquare(sq)
            let size = CGSizeMake(edge, edge)
			super.init(texture: nil, color: color, size: size)
			if let tile = self.square?.tile {
                // For Testing
                let newTileSprite = TileSprite(tile: tile, edge: edge, scale: 0.5)
				placeTileSprite(newTileSprite)
                newTileSprite.movable = false
            }
        }

        required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
        }
        
        func isEmpty() -> Bool {
            return tileSprite == nil
        }
        
        func makeImmutable() {
			tileSprite?.movable = false
			square?.immutable = true
        }
		
		private func placeTileSprite(sprite: TileSprite) {
			// Initial placement, no animation
			if tileSprite == nil {
				originalPoint = CGPointZero
				sprite.removeFromParent()
				sprite.setScale(0.5)
				addChild(sprite)
				tileSprite = sprite
				if let sq = square {
					sq.tile = sprite.tile
				}
			}
		}
		
		func animateDropTileSprite(sprite: TileSprite, originalPoint point: CGPoint, completion: (() -> ())?) {
            if tileSprite == nil {
				originalPoint = point
				sprite.cancelAnimations()
				sprite.removeFromParent()
				addChild(sprite)
                if let square = self.square {
                    square.tile = sprite.tile
				}
				tileSprite = sprite
				sprite.animateShrink(completion)
            }
        }
        
        func pickupTileSprite() -> TileSprite? {
            if let sprite = self.tileSprite where sprite.movable {
				sprite.cancelAnimations()
				sprite.removeFromParent()
				sprite.position = position
				if let sq = square {
					sq.tile = nil
				}
				tileSprite = nil
				return sprite
            }
            return nil
        }
    }
    
    
    class TileSprite: SKSpriteNode {
        class func createRackSprites(forGame game: Game, frame: CGRect) -> [TileSprite] {
            var sprites = [TileSprite]()
            var index = 0
            let squareSize = CGRectGetWidth(frame) / CGFloat(game.board.dimensions)
            let tileSize = squareSize * 2.0
			if let rack = game.rack {
				let spacing = (CGRectGetWidth(frame) - tileSize * CGFloat(rack.amount)) / 2
				for tile in rack.tiles {
					let sprite = TileSprite(tile: tile, edge: tileSize, scale: 1.0)
					sprite.position = CGPointMake(tileSize * CGFloat(index) + tileSize / 2 + spacing, tileSize / 2)
					sprites.append(sprite)
					index++
				}
			}
			return sprites
        }
		
        var letterLabel: SKLabelNode?
        var movable: Bool = true
        var tile: Tile?
		var animationPoint: CGPoint?
		init(tile: Tile, edge: CGFloat, scale: CGFloat) {
			self.tile = tile;
			if let letter = tile.letter {
				let label = SKLabelNode(text: letter)
				label.fontColor = UIColor.blackColor()
				label.fontSize = 27
				label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
				label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
				label.fontName = "AppleSDGothicNeo-Light"
				label.position = CGPointMake(0, -8)
				letterLabel = label
			}
			let points = SKLabelNode(text: String(tile.value))
			points.fontColor = UIColor.blackColor()
			points.fontSize = 12
			points.fontName = "AppleSDGothicNeo-Light"
			points.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
			points.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
			points.position = CGPointMake(8, -7)
			
			super.init(texture: nil, color: UIColor.TileBorderColor(), size: CGSizeMake(edge, edge))
			
			let innerNode = SKSpriteNode(texture: nil, color: UIColor.TileColor(), size: CGSizeMake(edge - 2, edge - 2))
			innerNode.position = CGPointZero
			addChild(innerNode)
			if let label = letterLabel {
				addChild(label)
			}
			addChild(points)
			setScale(scale)
        }
		
		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
		}
		
		func setLetter(letter: String) {
			if let t = tile, label = letterLabel {
				t.letter = letter
				label.fontColor = UIColor.blackColor().colorWithAlphaComponent(letter == "?" ? 1.0 : 0.6)
				label.text = letter
			}
		}
		
		private func cancelAnimations() {
			if hasActions() {
				removeAllActions()
				if let point = animationPoint {
					position = point
				}
			}
		}
		
		private func animateMoveTo(point: CGPoint) {
			cancelAnimations()
			animationPoint = point
			var move = SKAction.sequence([
				SKAction.scaleTo(1.0, duration: 0.1),
				SKAction.moveTo(point, duration: 0.1),
				SKAction.runBlock({
					self.animationPoint = nil
				})
			])
			runAction(move)
		}
		
		func resetPosition(point: CGPoint) {
			cancelAnimations()
			// Reset scale
			if xScale != 1.0 {
				setScale(1.0)
			}
			position = point
		}
		
		func animatePickupFromRack(point: CGPoint) {
			zPosition = 100
			animateMoveTo(point)
		}
		
		func animateDropToRack(point: CGPoint) {
			if tile?.value == 0 {
				setLetter("?")
			}
			animateMoveTo(point)
			zPosition = 0
		}
		
		func animateShrink(completion: (() -> ())?) {
			position = CGPointZero
			zPosition = 100
			var drop = SKAction.sequence([
				SKAction.scaleTo(0.5, duration: 0.25),
				SKAction.scaleTo(0.45, duration: 0.1),
				SKAction.scaleTo(0.5, duration: 0.1),
				SKAction.runBlock({
					self.zPosition = 0
					completion?()
				})
			])
			runAction(drop)
		}
		
		func animateGrow() {
			zPosition = 100
			var pickup = SKAction.sequence([
				SKAction.scaleTo(1.0, duration: 0.1),
				SKAction.scaleTo(1.1, duration: 0.05),
				SKAction.scaleTo(1.0, duration: 0.05),
			])
			runAction(pickup)
		}
    }
}
    