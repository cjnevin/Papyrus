//
//  PapyrusTile.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

class Tile: NSObject {
	enum Placement {
		case Bag
		case Rack
		case Held
		case Board
		case Fixed
	}
	var owner: Player?
	var square: Square?
	var placement = Placement.Bag
	var letter: Character
	let value: UInt
	var letterValue: UInt {
		guard let sq = square else { return 0 }
		return (placement == .Fixed ? 1 : sq.modifier.letterMultiplier) * value
	}
	var wordMultiplier: UInt {
		guard let sq = square else { return 1 }
		return (placement == .Fixed ? 1 : sq.modifier.wordMultiplier)
	}
	init(_ letter: Character, value: UInt) {
		self.letter = letter
		self.value = value
	}
}

extension Papyrus {
	static let TileConfiguration: [(Int, UInt, Character)] = [(9, 1, "A"), (2, 3, "B"), (2, 3, "C"), (4, 2, "D"), (12, 1, "E"),
		(2, 4, "F"), (3, 2, "G"), (2, 4, "H"), (9, 1, "I"), (1, 8, "J"), (1, 5, "K"),
		(4, 1, "L"), (2, 3, "M"), (6, 1, "N"), (8, 1, "O"), (2, 3, "P"), (1, 10, "Q"),
		(6, 1, "R"), (4, 1, "S"), (6, 1, "T"), (4, 1, "U"), (2, 4, "V"), (2, 4, "W"),
		(2, 4, "Y"), (1, 10, "Z"), (2, 0, "?")]
	
	class func createTiles() -> [Tile] {
		var output = [Tile]()
		for (n, value, letter) in Papyrus.TileConfiguration {
			for _ in 0..<n {
				output.append(Tile(letter, value: value))
			}
		}
		return output.sort({_, _ in arc4random() % 2 == 0})
	}
	
	func countTiles(placement: Tile.Placement, owner: Player?) -> Int {
		return tiles.filter({$0.placement == placement && $0.owner == owner}).count
	}
	
	func drawTiles(start: Int, end: Int, owner: Player?, from: Tile.Placement, to: Tile.Placement) -> Int {
		var count = 0
		for i in start..<tiles.count {
			if tiles[i].placement == from {
				if count < end {
					tiles[i].placement = to
					tiles[i].owner = owner
					count++
				} else {
					break
				}
			}
		}
		return count
	}
	
	var rackTiles: [Tile] {
		return tiles(withPlacement: .Rack, owner: player)
	}
	
	var droppedTiles: [Tile] {
		return tiles(withPlacement: .Board, owner: player)
	}
	
	func tile(at: Offset?) -> Tile? {
		if at == nil { return nil }
		guard let matched = tiles.filter({$0.square?.offset == at}).first else { return nil }
		return matched
	}
	
	func tiles(withPlacement p: Tile.Placement, owner: Player?) -> [Tile] {
		return tiles.filter{$0.placement == p && $0.owner == owner}
	}
	
	func sortTiles(letters: [Tile]) -> [Tile] {
		return letters.filter{$0.square != nil}.sort{$0.square!.offset < $1.square!.offset}
	}
}