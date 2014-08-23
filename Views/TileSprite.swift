//
//  TileSprite.swift
//  Locution
//
//  Created by Chris Nevin on 23/08/2014.
//  Copyright (c) 2014 Alive Mobile Group. All rights reserved.
//

import SpriteKit

class TileSprite: SKSpriteNode {
    var movable: Bool = true
    let tile: Board.Tile?
    init(tile: Board.Tile, edge: CGFloat, scale: CGFloat) {
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