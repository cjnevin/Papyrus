//
//  PapyrusTileSprite.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

class TileSprite: SKSpriteNode {
	var animationPoint: CGPoint?
	var movable: Bool {
		return tile.placement != .Fixed
	}
	var origin: CGPoint?
	var tile: Tile
	let letterLabel: SKLabelNode
	let tileBackground: SKSpriteNode
	
	init(tile: Tile, edge: CGFloat, scale: CGFloat) {
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
		
		let background = SKSpriteNode(texture: nil, color: UIColor.TileColor(), size: CGSizeMake(edge - 2, edge - 2))
		background.position = CGPointZero
		tileBackground = background
		
		super.init(texture: nil, color: UIColor.TileBorderColor(), size: CGSizeMake(edge, edge))
		addChild(background)
		addChild(label)
		addChild(points)
		setScale(scale)
	}
	
	func changeLetter(newLetter: Character) {
		if self.tile.letterValue == 0 {
			self.tile.letter = newLetter
			self.letterLabel.text = String(newLetter)
		}
	}
	
	func illuminate() {
		tileBackground.color = UIColor.TileColorIlluminated()
	}
	
	func deilluminate() {
		tileBackground.color = UIColor.TileColor()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension Papyrus {
	class func createRackSprites(forGame game: Papyrus, frame: CGRect) -> [TileSprite] {
		var sprites = [TileSprite]()
		let squareSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions)
		let tileSize = squareSize * 2.0
		let rack = game.tiles(withPlacement: .Rack, owner: game.player)
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