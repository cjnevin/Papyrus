//
//  PapyrusSquareSprite.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit
import PapyrusCore

class SquareSprite: SKSpriteNode {
    let row: Int
    let col: Int
    /// `Square` on board this sprite is representing.
    let square: Square
    /// Background sprite inset by 1pt to account for border.
    //let background: SKSpriteNode
    /// Original point of `TileSprite` we dropped on this `Square`.
    var origin: CGPoint?
    /// Sprite for `Tile` contained within this `Square`.
    var tileSprite: TileSprite?
    /// Returns true if `tileSprite` is unset.
    var isEmpty: Bool {
        return tileSprite == nil
    }
    
    init(row: Int, col: Int, square: Square, edge: CGFloat) {
        self.row = row
        self.col = col
        self.square = square
        //self.background = SKSpriteNode(texture: nil, color: Papyrus.colorForSquare(square), size: CGSizeMake(edge-1, edge-1))
        super.init(texture: nil, color: Papyrus.colorForSquare(square), size: CGSizeMake(edge, edge))
        //self.addChild(self.background)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BoardSquare {
    let row: Int
    let col: Int
    let edge: CGFloat
    let square: Square
    
    init(row: Int, col: Int, edge: CGFloat, square: Square) {
        self.row = row
        self.col = col
        self.edge = edge
        self.square = square
    }
    
    class func createBoard(forGame game: Papyrus, frame: CGRect) -> [BoardSquare] {
        let range = 0..<PapyrusDimensions
        let squareSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions)
        var buffer = [BoardSquare]()
        for row in range {
            for col in range {
                buffer.append(BoardSquare(
                    row: row,
                    col: col,
                    edge: squareSize,
                    square: game.squares[row][col]))
            }
        }
        return buffer
    }
}


extension Papyrus {
    private static let colorMap: [Modifier: UIColor] = [
        .Center: .Papyrus_Center,
        .Letterx2: .Papyrus_Letterx2,
        .Letterx3: .Papyrus_Letterx3,
        .Wordx2: .Papyrus_Wordx2,
        .Wordx3: .Papyrus_Wordx3,
        .None: .Papyrus_Tile
    ]
    
    /// - returns: UIColor matching square modifier.
    class func colorForSquare(square: Square) -> UIColor {
        guard let color = colorMap[square.type] else { return colorMap[.None]! }
        return color
    }
    
    /// - returns: Array of `SquareSprite` instances for each `Square`.
    class func createSquareSprites(forGame game: Papyrus, frame: CGRect) -> [SquareSprite] {
        var sprites = [SquareSprite]()
        let squareSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions)
        for row in 0..<PapyrusDimensions {
            for col in 0..<PapyrusDimensions {
                let sprite = SquareSprite(row: row, col: col, square: game.squares[row][col], edge: squareSize)
                sprite.position = CGPointMake(
                    squareSize * CGFloat(col) + squareSize / 2,
                    CGRectGetHeight(frame) - squareSize * CGFloat(row + 1) + squareSize / 2)
                sprites.append(sprite)
            }
        }
        return sprites
    }
}
    