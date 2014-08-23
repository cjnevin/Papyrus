//
//  SquareSprite.swift
//  Locution
//
//  Created by Chris Nevin on 23/08/2014.
//  Copyright (c) 2014 Alive Mobile Group. All rights reserved.
//

import SpriteKit

class SquareSprite: SKSpriteNode {
    let square: Board.Square?
    var originalPoint: CGPoint?
    var tileSprite: TileSprite?
    init(square: Board.Square, edge: CGFloat) {
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

