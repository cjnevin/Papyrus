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
				tiles.extend(Array(count: 9, repeatedValue: Tile(letter: "A", value: 1)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "B", value: 3)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "C", value: 3)))
				tiles.extend(Array(count: 4, repeatedValue: Tile(letter: "D", value: 2)))
				tiles.extend(Array(count: 12, repeatedValue: Tile(letter: "E", value: 1)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "F", value: 4)))
				tiles.extend(Array(count: 3, repeatedValue: Tile(letter: "G", value: 2)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "H", value: 4)))
				tiles.extend(Array(count: 9, repeatedValue: Tile(letter: "I", value: 1)))
				tiles.extend(Array(count: 1, repeatedValue: Tile(letter: "J", value: 8)))
				tiles.extend(Array(count: 1, repeatedValue: Tile(letter: "K", value: 5)))
				tiles.extend(Array(count: 4, repeatedValue: Tile(letter: "L", value: 1)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "M", value: 3)))
				tiles.extend(Array(count: 6, repeatedValue: Tile(letter: "N", value: 1)))
				tiles.extend(Array(count: 8, repeatedValue: Tile(letter: "O", value: 1)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "P", value: 3)))
				tiles.extend(Array(count: 1, repeatedValue: Tile(letter: "Q", value: 10)))
				tiles.extend(Array(count: 6, repeatedValue: Tile(letter: "R", value: 1)))
				tiles.extend(Array(count: 4, repeatedValue: Tile(letter: "S", value: 1)))
				tiles.extend(Array(count: 6, repeatedValue: Tile(letter: "T", value: 1)))
				tiles.extend(Array(count: 4, repeatedValue: Tile(letter: "U", value: 1)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "V", value: 4)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "W", value: 4)))
				tiles.extend(Array(count: 1, repeatedValue: Tile(letter: "X", value: 10)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "Y", value: 4)))
				tiles.extend(Array(count: 1, repeatedValue: Tile(letter: "Z", value: 10)))
				tiles.extend(Array(count: 2, repeatedValue: Tile(letter: "?", value: 0)))
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
                for _ in 0...needed {
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
        let squares: [Square]
        
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
