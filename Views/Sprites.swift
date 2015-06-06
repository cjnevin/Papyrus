//
//  Sprites.swift
//  Locution
//
//  Created by Chris Nevin on 23/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import SpriteKit

class Sprites {
    typealias Square = Locution.Board.Square
    typealias Tile = Locution.Tile
    
    class SquareSprite: SKSpriteNode {
        class func createSprites(forGame game: Locution, frame: CGRect) -> [SquareSprite] {
            var sprites = [SquareSprite]()
            var squareSize = CGRectGetWidth(frame) / CGFloat(game.board.dimensions)
            for square in game.board.squares {
                var sprite = SquareSprite(square: square, edge: squareSize)
                sprite.position = CGPointMake(squareSize * CGFloat(square.point.0 - 1) + squareSize / 2,
					CGRectGetHeight(frame) - squareSize * CGFloat(square.point.1) + squareSize / 2)
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
            var color = SquareSprite.colorForSquare(square)
            self.square = square
            var size = CGSizeMake(edge, edge)
            super.init(texture: nil, color: color, size: size)
            if let tile = self.square?.tile {
                // For Testing
                var newTileSprite = TileSprite(tile: tile, edge: edge, scale: 0.5)
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
                sprite.removeFromParent()
                sprite.xScale = 0.5
                sprite.yScale = 0.5
                sprite.position = CGPointZero
                self.addChild(sprite)
                self.tileSprite = sprite
                if let square = self.square {
                    square.tile = sprite.tile
                }
            }
        }
        
        func pickupTileSprite() -> TileSprite? {
            if let tileSprite = self.tileSprite {
                if tileSprite.movable {
                    tileSprite.xScale = 1.0
                    tileSprite.yScale = 1.0
                    tileSprite.position = self.position
                    tileSprite.removeFromParent()
                    self.tileSprite = nil
                    if let square = self.square {
                        square.tile = nil
                    }
                    return tileSprite
                }
            }
            return nil
        }
    }
    
    
    class TileSprite: SKSpriteNode {
        class func createRackSprites(forGame game: Locution, frame: CGRect) -> [TileSprite] {
            var sprites = [TileSprite]()
            var index = 0
            var squareSize = CGRectGetWidth(frame) / CGFloat(game.board.dimensions)
            var tileSize = squareSize * 2.0
            var spacing = ceil((CGRectGetWidth(frame) - tileSize * CGFloat(game.rack.amount)) / 2)
            for tile in game.rack.tiles {
                var sprite = TileSprite(tile: tile, edge: tileSize, scale: 1.0)
                sprite.position = CGPointMake(ceil(tileSize * CGFloat(index) + tileSize / 2 + spacing), ceil(tileSize / 2))
                sprites.append(sprite)
                index++
            }
            return sprites
        }
        
        var movable: Bool = true
        let defaultColor = UIColor(red: 1, green: 1, blue: 200/255, alpha: 1)
        var tile: Tile?
        
        init(tile: Tile, edge: CGFloat, scale: CGFloat) {
            self.tile = tile;
            var color = defaultColor
            var size = CGSizeMake(edge, edge)
            var label = SKLabelNode(text: tile.letter)
            label.fontColor = UIColor.blackColor()
            label.fontSize = 27
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
            label.fontName = "AppleSDGothicNeo-Light"
            label.position = CGPointMake(0, -8)
            var points = SKLabelNode(text: String(tile.value))
            points.fontColor = UIColor.blackColor()
            points.fontSize = 12
            points.fontName = "AppleSDGothicNeo-Light"
            points.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            points.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
            points.position = CGPointMake(8, -7)
            super.init(texture: nil, color: color, size: size)
            self.addChild(label)
            self.addChild(points)
            self.yScale = scale
            self.xScale = scale
        }
		
		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
		}
		
    }
}
    