//
//  PapyrusSquareSprite.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

class SquareSprite: SKSpriteNode {
    let square: Square
    let background: SKSpriteNode
    var origin: CGPoint?
    var tileSprite: TileSprite?
    
    init(square: Square, edge: CGFloat) {
        self.square = square
        self.background = SKSpriteNode(texture: nil, color: Papyrus.colorForSquare(square), size: CGSizeMake(edge-1, edge-1))
        super.init(texture: nil, color: UIColor.Papyrus_SquareBorder, size: CGSizeMake(edge, edge))
        self.addChild(self.background)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isEmpty() -> Bool {
        return tileSprite == nil
    }
}

extension Papyrus {
    static let colorMap: [Square.Modifier: UIColor] = [
        .Center: .Papyrus_Center,
        .Letterx2: .Papyrus_Letterx2,
        .Letterx3: .Papyrus_Letterx3,
        .Wordx2: .Papyrus_Wordx2,
        .Wordx3: .Papyrus_Wordx3,
        .None: .Papyrus_Tile
    ]
    
    class func colorForSquare(square: Square) -> UIColor {
        guard let color = colorMap[square.modifier] else { return colorMap[.None]! }
        return color
    }
    
    class func createSquareSprites(forGame game: Papyrus, frame: CGRect) -> [SquareSprite] {
        var sprites = [SquareSprite]()
        let squareSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions)
        for square in game.squares.flatMap({$0}) {
            let sprite = SquareSprite(square: square, edge: squareSize)
            let o = square.offset
            sprite.position = CGPointMake(squareSize * CGFloat(o.x - 1) + squareSize / 2,
                CGRectGetHeight(frame) - squareSize * CGFloat(o.y) + squareSize / 2)
            sprites.append(sprite)
        }
        return sprites
    }
}
    