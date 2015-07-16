//
//  PapyrusWord.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

enum Orientation {
	case Horizontal
	case Vertical
	static var both: [Orientation] { return [.Horizontal, .Vertical] }
	var invert: Orientation { return self == .Horizontal ? .Vertical : .Horizontal }
}

enum ValidationError: String, ErrorType {
	case InvalidTileArrangement = "Invalid tile arrangement."
	case InvalidFirstPlay = "First play must have all tiles lined up."
	case NoWordIntersection = "New words must intersect existing words."
	case InvalidSingleLetterPlay = "You must play more than one letter."
	case NoCenterIntersection = "First play must intersect the center square."
	case InvalidWords = "Invalid word(s)"
	case InvalidWord = "Invalid word"
}

func ==(lhs: Word, rhs: Word) -> Bool {
	return lhs.tiles.filter({rhs.tiles.contains($0)}).count == lhs.tiles.count
}

struct Word: Hashable, Equatable {
	let length: Int
	let orientation: Orientation
	let offsets: [Offset]
	let squares: [Square]
	let range: (start: Offset, end: Offset)
	let tiles: [Tile]
	let value: String
	let points: UInt
	let intersectsCenter: Bool
	var immutable: Bool {
		return tiles.filter({$0.placement == Tile.Placement.Fixed}).count == tiles.count
	}
	var hashValue: Int {
		var output = String()
		for square in tiles.filter({$0.square != nil}).map({$0.square!}) {
			if !output.isEmpty { output += "|" }
			output += "\(square.offset.x),\(square.offset.y)"
		}
		return output.hashValue
	}
	init?(_ array: [Tile], f: ValidationFunction) throws {
		do {
			tiles = array
			let cfg = try f(tiles: &tiles)
			orientation = cfg.o
			range = cfg.range
			value = String(tiles.map({$0.letter}))
			length = value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
			squares = tiles.filter({$0 != nil}).map({$0.square!})
			offsets = squares.map({$0.offset})
			intersectsCenter = offsets.contains(PapyrusMiddleOffset!)
			var total: UInt = tiles.map({$0.letterValue}).reduce(0, combine: +)
			total = tiles.map({$0.wordMultiplier}).reduce(total, combine: *)
			points = total
		}
		catch (let err) {
			throw err
		}
	}
}
