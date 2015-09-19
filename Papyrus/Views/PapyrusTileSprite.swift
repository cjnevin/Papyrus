//
//  PapyrusTileSprite.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit
import PapyrusCore

class TileSprite: SKSpriteNode {
    static var defaultTileSize: CGFloat = 0.0
    
    /// - returns: True if tile has yet to be submitted ('Fixed')
    var movable: Bool {
        return tile.placement != .Fixed
    }
    /// Point to animate move to.
    var animationPoint: CGPoint?
    /// Point where tile began.
    var origin: CGPoint?
    /// `Tile` associated with this sprite.
    var tile: Tile
    /// Label which displays textual representation of the letter.
    private let letterLabel: SKLabelNode
    /// Background sprite of tile inside of 'border' sprite.
    let background: SKSpriteNode
    
    class func sprite(withTile tile: Tile) -> TileSprite {
        return TileSprite(tile: tile, edge: defaultTileSize, scale: 1.0)
    }
    
    init(tile: Tile, edge: CGFloat, scale: CGFloat) {
        TileSprite.defaultTileSize = edge
        self.tile = tile;
        let letter = String(tile.letter)
        let label = SKLabelNode(text: letter)
        label.fontColor = UIColor.blackColor()
        label.fontSize = 27
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Baseline
        label.fontName = "AppleSDGothicNeo-Light"
        label.position = CGPointMake(0, -8)
        letterLabel = label
        
        let points = SKLabelNode(text: String(tile.value))
        points.fontColor = UIColor.blackColor()
        points.fontSize = 12
        points.fontName = "AppleSDGothicNeo-Light"
        points.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        points.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        points.position = CGPointMake(8, -7)
        
        background = SKSpriteNode(texture: nil, color: UIColor.Papyrus_Tile, size: CGSizeMake(edge - 2, edge - 2))
        background.position = CGPointZero

        super.init(texture: nil, color: UIColor.Papyrus_TileBorder, size: CGSizeMake(edge, edge))
        addChild(background)
        addChild(label)
        addChild(points)
        setScale(scale)
    }
    
    /// Change letter presented on tile, only works for blank tiles.
    func changeLetter(newLetter: Character) {
        if self.tile.value == 0 {
            self.tile.changeLetter(newLetter)
            self.letterLabel.text = String(newLetter)
        }
    }
    
    /// Change color of tile to signify recently placed.
    func illuminate() {
        background.color = UIColor.Papyrus_TileIlluminated
    }
    
    /// Change color of tile to signify not recently placed.
    func deilluminate() {
        background.color = UIColor.Papyrus_Tile
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Papyrus {
    class func createRackSprites(forGame game: Papyrus, frame: CGRect) -> [TileSprite] {
        var sprites = [TileSprite]()
        guard let rack = game.player?.rackTiles where rack.count > 0 else {
            return sprites
        }
        let squareSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions)
        let tileSize = squareSize * 2.0
        let spacing = (CGRectGetWidth(frame) - tileSize * CGFloat(rack.count)) / 2
        var index: CGFloat = 0
        for tile in rack {
            let sprite = TileSprite(tile: tile, edge: tileSize, scale: 1.0)
            sprite.position = CGPointMake(tileSize * index + squareSize + spacing, frame.size.height - spacing)
            sprites.append(sprite)
            index++
        }
        return sprites
    }
}