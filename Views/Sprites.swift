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
		
        init(square: Square, edge: CGFloat) {
            self.square = square
            let color = SquareSprite.colorForSquare(square)
            let size = CGSizeMake(edge, edge)
			super.init(texture: nil, color: color, size: size)
            if let tile = self.square?.tile {
                // For Testing
                let newTileSprite = TileSprite(tile: tile, edge: edge, scale: 0.5)
                self.dropTileSprite(newTileSprite, originalPoint:CGPointZero)
                newTileSprite.movable = false
            }
        }

        required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
        }
        
        func isEmpty() -> Bool {
            return self.tileSprite == nil
        }
        
        func makeImmutable() {
			tileSprite?.movable = false
			square?.immutable = true
        }
        
        func dropTileSprite(sprite: TileSprite, originalPoint point: CGPoint) {
            if self.tileSprite == nil {
				self.originalPoint = point
				sprite.removeAllActions()
				sprite.removeFromParent()
				self.addChild(sprite)
				sprite.animateShrink()
                self.tileSprite = sprite
                if let square = self.square {
                    square.tile = sprite.tile
                }
            }
        }
        
        func pickupTileSprite() -> TileSprite? {
            if let sprite = self.tileSprite {
				if sprite.movable {
					sprite.removeAllActions()
                    sprite.removeFromParent()
					sprite.position = self.position
					if let square = self.square {
                        square.tile = nil
                    }
					self.tileSprite = nil
					return sprite
                }
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
		
        let defaultColor = UIColor(red: 1, green: 1, blue: 200/255, alpha: 1)
        var movable: Bool = true
        var tile: Tile?
        
        init(tile: Tile, edge: CGFloat, scale: CGFloat) {
            self.tile = tile;
            var color = defaultColor
            let size = CGSizeMake(edge, edge)
            let label = SKLabelNode(text: tile.letter)
            label.fontColor = UIColor.blackColor()
            label.fontSize = 27
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
            label.fontName = "AppleSDGothicNeo-Light"
            label.position = CGPointMake(0, -8)
            let points = SKLabelNode(text: String(tile.value))
            points.fontColor = UIColor.blackColor()
            points.fontSize = 12
            points.fontName = "AppleSDGothicNeo-Light"
            points.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            points.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
            points.position = CGPointMake(8, -7)
            super.init(texture: nil, color: color, size: size)
            self.addChild(label)
            self.addChild(points)
			self.setScale(scale)
        }
		
		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
		}
		
		func animateShrink() {
			self.position = CGPointZero
			self.zPosition = 1
			var drop = SKAction.sequence([
				SKAction.scaleTo(0.5, duration: 0.25),
				SKAction.scaleTo(0.45, duration: 0.1),
				SKAction.scaleTo(0.5, duration: 0.1),
				SKAction.runBlock({
					self.zPosition = 0
				})
			])
			self.runAction(drop)
		}
		
		func animateGrow() {
			self.zPosition = 1.0
			var pickup = SKAction.sequence([
				SKAction.scaleTo(1.0, duration: 0.2),
				SKAction.scaleTo(1.1, duration: 0.05),
				SKAction.scaleTo(1.0, duration: 0.05),
			])
			self.runAction(pickup)
		}
    }
}
    