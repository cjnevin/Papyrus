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
                sprite.position = CGPointMake(squareSize * CGFloat(square.point.0 - 1) + squareSize / 2, CGRectGetHeight(frame) - squareSize * CGFloat(square.point.1) + squareSize / 2)
                sprites.append(sprite)
            }
            return sprites
        }
        
        let square: Square?
        var originalPoint: CGPoint?
        var tileSprite: TileSprite?
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        init(square: Square, edge: CGFloat) {
            var color: UIColor
            switch (square.squareType) {
            case .Center:
                color = UIColor.purpleColor()
            case .DoubleLetter:
                color = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1)
            case .DoubleWord:
                color = UIColor(red: 1, green: 182/255, blue: 193/255, alpha: 1)
            case .TripleLetter:
                color = UIColor(red: 65/255, green: 105/255, blue: 225/255, alpha: 1)
            case .TripleWord:
                color = UIColor(red: 205/255, green: 92/255, blue: 92/255, alpha: 1)
            default:
                color = UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1)
            }
            self.square = square
            var size = CGSizeMake(edge, edge)
            super.init(texture: nil, color: color, size: size)
            if let tile = self.square?.tile {
                // For Testing
                var newTileSprite = TileSprite(tile: tile, edge: edge, scale: 1.0)
                self.dropTileSprite(newTileSprite, originalPoint:CGPointZero)
                newTileSprite.movable = false
            }
        }
        
        func isEmpty() -> Bool {
            return self.tileSprite == nil
        }
        
        func dropTileSprite(sprite: TileSprite, originalPoint point: CGPoint) {
            if self.tileSprite == nil {
                self.originalPoint = point
                sprite.removeFromParent()
                sprite.xScale = 1.0
                sprite.yScale = 1.0
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
                    tileSprite.xScale = 2.0
                    tileSprite.yScale = 2.0
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
            var spacing = (CGRectGetWidth(frame) - tileSize * CGFloat(game.rack.amount)) / 2
            for tile in game.rack.tiles {
                var sprite = TileSprite(tile: tile, edge: squareSize, scale: 2.0)
                sprite.position = CGPointMake(tileSize * CGFloat(index) + tileSize / 2 + spacing, tileSize / 2)
                sprites.append(sprite)
                index++
            }
            return sprites
        }
        
        var movable: Bool = true
        let tile: Tile?
        
        init(tile: Tile, edge: CGFloat, scale: CGFloat) {
            self.tile = tile;
            var color = UIColor(red: 1, green: 1, blue: 200/255, alpha: 1)
            var size = CGSizeMake(edge, edge)
            var label = SKLabelNode(text: tile.letter)
            label.fontColor = UIColor.blackColor()
            label.fontSize = 13
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
            label.fontName = "AppleSDGothicNeo-Light"
            label.position = CGPointMake(0, -5)
            var points = SKLabelNode(text: String(tile.value))
            points.fontColor = UIColor.blackColor()
            points.fontSize = 6
            points.fontName = "AppleSDGothicNeo-Light"
            points.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
            points.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
            points.position = CGPointMake(4, -3)
            super.init(texture: nil, color: color, size: size)
            self.addChild(label)
            self.addChild(points)
            self.yScale = scale
            self.xScale = scale
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
}
    