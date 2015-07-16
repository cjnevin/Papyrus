//
//  PapyrusSquareSprite.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

class SquareSprite: SKSpriteNode {
	var square: Square?
	var origin: CGPoint?
	var tileSprite: TileSprite?
	
	init(square: Square, edge: CGFloat) {
		self.square = square
		super.init(texture: nil, color: UIColor.SquareBorderColor(), size: CGSizeMake(edge, edge))
		let innerSquare = SKSpriteNode(texture: nil, color: Papyrus.colorForSquare(square), size: CGSizeMake(edge-1, edge-1))
		self.addChild(innerSquare)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func isEmpty() -> Bool {
		return tileSprite?.movable ?? true
	}
}

extension Papyrus {
	class func colorForSquare(square: Square) -> UIColor {
		switch (square.modifier) {
		case .Center:	return UIColor.CenterTileColor()
		case .Letterx2: return UIColor.DoubleLetterTileColor()
		case .Wordx2:	return UIColor.DoubleWordTileColor()
		case .Letterx3:	return UIColor.TripleLetterTileColor()
		case .Wordx3:	return UIColor.TripleWordTileColor()
		default:		return UIColor.BoardTileColor()
		}
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
	