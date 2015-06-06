//
//  Locution.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import Foundation

func == (lhs: Locution.Tile, rhs: Locution.Tile) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

func == (lhs: Locution.Board.Square, rhs: Locution.Board.Square) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

class Locution {
	enum Language {
		case English
	}
	
	class Bag {
        let total: Int
        var tiles: [Tile]
		
		init(language: Language) {
            tiles = [Tile]()
			if language == .English {
				// Apparently Array(count:repeatedValue:) creates objects with the same pointer
				var config = [(9, 1, "A"), (2, 3, "B"), (2, 3, "C"), (4, 2, "D"), (12, 1, "E"),
				(2, 4, "F"), (3, 2, "G"), (2, 4, "H"), (9, 1, "I"), (1, 8, "J"), (1, 5, "K"),
				(4, 1, "L"), (2, 3, "M"), (6, 1, "N"), (8, 1, "O"), (2, 3, "P"), (1, 10, "Q"),
				(6, 1, "R"), (4, 1, "S"), (6, 1, "T"), (4, 1, "U"), (2, 4, "V"), (2, 4, "W"),
				(2, 4, "Y"), (1, 10, "Z"), (2, 0, "?")]
				for (count, value, letter) in config {
					for _ in 1...count {
						tiles.append(Tile(letter: letter, value: value))
					}
				}
			}
            total = tiles.count
        }
    }
	
	class Tile: Equatable {
        let letter: String
        let value: Int
        init(letter: String, value: Int) {
            self.letter = letter
            self.value = value
        }
    }
    
    class Rack {
        var amount = 7
        var tiles: [Tile]
        init() {
            tiles = [Tile]()
        }
        
        func replenish(fromBag bag: Bag) -> [Tile] {
			var needed = amount - tiles.count
            var newTiles = [Tile]()
            if needed > 0 {
                for _ in 1...needed {
                    var index = Int(arc4random_uniform(UInt32(bag.tiles.count)))
                    newTiles.append(bag.tiles[index])
                    bag.tiles.removeAtIndex(index)
                }
            }
            tiles.extend(newTiles)
            return newTiles
        }
    }
    
    class Board {
		class Square: Equatable {
            enum SquareType {
                case Normal
                case Center
                case DoubleLetter
                case TripleLetter
                case DoubleWord
                case TripleWord
            }
            
            let squareType: SquareType
            let point: (x: Int, y: Int)
            var immutable = false
            var tile: Tile?
            
            init(squareType: SquareType, point: (x: Int, y:Int)) {
                self.squareType = squareType
                self.point = point
            }
            
            func fill(tile: Tile?) {
                self.tile = tile
            }
			
            func value() -> Int {
                var multiplier: Int = 1
                if !immutable {
                    switch (squareType) {
                    case .DoubleLetter:
                        multiplier = 2
                    case .TripleLetter:
                        multiplier = 3
                    default:
                        multiplier = 1
                    }
                }
                if let value = self.tile?.value {
                    return value * multiplier;
                }
                return 0
            }
            
            func wordMultiplier() -> Int {
                if !immutable {
                    switch (squareType) {
                    case .Center, .DoubleWord:
                        return 2
                    case .TripleWord:
                        return 3
                    default:
                        return 1
                    }
                }
                return 1
            }
        }
        
        let dimensions: Int
        var squares: [Square]
        
        init(dimensions: Int) {
            self.dimensions = dimensions;
            self.squares = [Square]()
            var middle = dimensions/2+1
            for row in 1...dimensions {
                for col in 1...dimensions {
                    var point = (row, col)
					if symmetrical(point, offset: 0, offset2: 0, middle: middle) {
                        squares.append(Square(squareType: .Center, point: point))
                    } else if symmetrical(point, offset: middle - 1, offset2: middle - 1, middle: middle) || symmetrical(point, offset: 0, offset2: middle - 1, middle: middle) {
                        squares.append(Square(squareType: .TripleWord, point: point))
                    } else if symmetrical(point, offset: 1, offset2: 1, middle: middle) || symmetrical(point, offset: 1, offset2: 5, middle: middle) || symmetrical(point, offset: 0, offset2: 4, middle: middle) || symmetrical(point, offset: middle - 1, offset2: 4, middle: middle) {
                        squares.append(Square(squareType: .DoubleLetter, point: point))
                    } else if symmetrical(point, offset: 2, offset2: 6, middle: middle) || symmetrical(point, offset: 2, offset2: 2, middle: middle) {
                        squares.append(Square(squareType: .TripleLetter, point: point))
                    } else if symmetrical(point, offset: 3, offset2: 3, middle: middle) || symmetrical(point, offset: 4, offset2: 4, middle: middle) || symmetrical(point, offset: 5, offset2: 5, middle: middle) || symmetrical(point, offset: 6, offset2: 6, middle: middle) {
                        squares.append(Square(squareType: .DoubleWord, point: point))
                    } else {
                        squares.append(Square(squareType: .Normal, point: point))
                    }
                }
            }
        }
        
        func emptySquares() -> [Square] {
            return squares.filter({$0.tile == nil})
        }
        
        func filledSquares() -> [Square] {
            return squares.filter({$0.tile != nil})
        }
        
        private func symmetrical(point: (Int, Int), offset: Int, offset2: Int, middle: Int) -> Bool {
            switch (point) {
            case
            (middle - offset, middle - offset2),
            (middle - offset, middle + offset2),
            (middle + offset, middle + offset2),
            (middle + offset, middle - offset2),
            (middle - offset2, middle - offset),
            (middle - offset2, middle + offset),
            (middle + offset2, middle + offset),
            (middle + offset2, middle - offset):
                return true
            default:
                return false
            }
        }
    }
    
    let bag: Bag
    let rack: Rack
    let board: Board
    
    init() {
        self.board = Board(dimensions: 15)
		self.bag = Bag(language:.English)
        self.rack = Rack()
        self.rack.replenish(fromBag: bag)
    }
}
