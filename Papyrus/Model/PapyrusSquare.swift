//
//  PapyrusSquare.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func ==(lhs: Square, rhs: Square) -> Bool {
	return lhs.offset == rhs.offset
}

struct Square: Equatable, Hashable {
	enum Modifier: String {
		case None = "_"
		case Center = "X"
		case Letterx2 = "D"
		case Letterx3 = "T"
		case Wordx2 = "W"
		case Wordx3 = "Z"
		var wordMultiplier: UInt {
			switch (self) {
			case .Center, .Wordx2: return 2
			case .Wordx3: return 3
			default: return 1
			}
		}
		var letterMultiplier: UInt {
			switch (self) {
			case .Letterx2: return 2
			case .Letterx3: return 3
			default: return 1
			}
		}
	}
	let modifier: Modifier
	let offset: Offset
	func at(x xx: Int, y yy: Int, inArray arr: [[Square]]) -> Square? {
		guard let n = offset.at(x: xx, y: yy) else { return nil }
		return arr[n.x][n.y]
	}
	func advance(o: Orientation, amount: Int, inArray arr: [[Square]]) -> Square? {
		guard let n = offset.advance(o, amount: amount) else { return nil }
		return arr[n.x][n.y]
	}
	func next(o: Orientation, inArray arr: [[Square]]) -> Square? {
		return advance(o, amount: 1, inArray: arr)
	}
	func prev(o: Orientation, inArray arr: [[Square]]) -> Square? {
		return advance(o, amount: -1, inArray: arr)
	}
	var hashValue: Int {
		return "\(offset.x),\(offset.y)".hashValue
	}
}

extension Papyrus {
	class func createSquares() -> [[Square]] {
		let m = PapyrusMiddle
		func symmetricalOffsets(offsets: [(Int, Int)]) -> [Offset] {
			func symmetrical(offset: Offset) -> [Offset] {
				let a = offset.x, b = offset.y
				return [Offset(x: m-a, y: m-b), Offset(x: m-a, y: m+b),
					Offset(x: m+a, y: m+b), Offset(x: m+a, y: m-b),
					Offset(x: m-b, y: m-a), Offset(x: m-b, y: m+a),
					Offset(x: m+b, y: m+a), Offset(x: m+b, y: m-a)]
					.filter({$0 != nil})
					.map({$0!})
			}
			return offsets.flatMap({symmetrical(Offset(x: $0.0, y: $0.1)!)})
		}
		let modifiers: [Square.Modifier: [Offset]] = [
			.Center: symmetricalOffsets([(0,0)]),
			.Wordx3: symmetricalOffsets([(m-1, m-1), (0, m-1)]),
			.Letterx2: symmetricalOffsets([(1, 1), (1, 5), (0, 4), (m-1, 4)]),
			.Letterx3: symmetricalOffsets([(2, 6), (2, 2)]),
			.Wordx2: symmetricalOffsets([(3, 3), (4, 4), (5, 5), (6, 6)])
		]
		var output = [[Square]]()
		for x in (1...PapyrusDimensions) {
			var xSquares = [Square]()
			for y in (1...PapyrusDimensions) {
				var modifier = Square.Modifier.None
				if let offset = Offset(x: x, y: y) {
					for (mod, offsets) in modifiers where offsets.contains(offset) {
						modifier = mod
						break
					}
					xSquares.append(Square(modifier: modifier, offset: offset))
				}
			}
			output.append(xSquares)
		}
		return output
	}
}