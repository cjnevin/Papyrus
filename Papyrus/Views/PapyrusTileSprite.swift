//
//  PapyrusTileSprite.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit
import PapyrusCore

class TileSprite: SKShapeNode {
    static var defaultTileSize: CGFloat = 0.0
    
    /// - returns: True if tile has yet to be submitted ('Fixed')
    var movable: Bool {
        return tile.placement != .Fixed
    }
    /// Point to animate move to.
    var animationPoint: CGPoint?
    /// Point where tile began.
    var origin: CGPoint!
    /// `Tile` associated with this sprite.
    var tile: Tile
    /// Label which displays textual representation of the letter.
    private let letterLabel: SKLabelNode
    /// Background sprite of tile inside of 'border' sprite.
    let background: SKShapeNode
    
    class func sprite(withTile tile: Tile) -> TileSprite {
        return TileSprite(tile: tile, edge: defaultTileSize, scale: 1.0)
    }
    
    init(tile: Tile, edge: CGFloat, scale: CGFloat) {
        TileSprite.defaultTileSize = edge
        self.tile = tile;
        let letter = String(tile.letter).uppercaseString
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
        
        background = SKShapeNode(rectOfSize: CGSizeMake(edge - 2, edge - 2))
        background.fillColor = UIColor.Papyrus_Tile
        background.position = CGPointZero
        
        super.init()
        path = CGPathCreateWithRect(CGRect(origin: CGPoint(x: -edge / 2, y: -edge / 2),
            size: CGSize(width: edge, height: edge)), nil)
        fillColor = UIColor.Papyrus_TileBorder
        
        addChild(background)
        addChild(label)
        addChild(points)
        setScale(scale)
    }
    
    /// Change letter presented on tile, only works for blank tiles.
    func changeLetter(newLetter: Character) {
        if self.tile.value == 0 {
            self.tile.changeLetter(newLetter)
            self.letterLabel.text = String(newLetter).uppercaseString
        }
    }
    
    /// Change color of tile to signify recently placed.
    func illuminate() {
        background.fillColor = UIColor.Papyrus_TileIlluminated
    }
    
    /// Change color of tile to signify not recently placed.
    func deilluminate() {
        background.fillColor = UIColor.Papyrus_Tile
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}