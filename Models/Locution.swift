//
//  Locution.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import Foundation
import UIKit

func == (lhs: Locution.BoardPoint, rhs: Locution.BoardPoint) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

func == (lhs: Locution.Tile, rhs: Locution.Tile) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

func == (lhs: Locution.Board.Square, rhs: Locution.Board.Square) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

class Locution {
	enum Language: String {
		case English = "CSW12"
	}
	
	class Dictionary {
		private let DefKey = "Def"
		private let dictionary: NSDictionary
		let language: Language
		init(language: Language) {
			self.language = language
			if let path = NSBundle.mainBundle().pathForResource(language.rawValue, ofType: "plist"),
				values = NSDictionary(contentsOfFile: path) {
				self.dictionary = values
			} else {
				self.dictionary = NSDictionary()
			}
		}
		
		func defined(word: String) -> (Bool, String?) {
			var current = dictionary
			var index = word.startIndex
			for char in word.uppercaseString {
				if let inner = current.objectForKey(String(char)) as? NSDictionary {
					index = advance(index, 1)
					if index == word.endIndex {
						if let definition = inner.objectForKey(DefKey) as? String {
							return (true, definition)
						}
					}
					current = inner
				} else {
					// Invalid word
					break
				}
			}
			return (false, nil)
		}
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
	
	typealias BoardPoint = (x: Int, y: Int)

	class Board {
		let rect: CGRect
		
		func getFilledSquare(atPoint point: BoardPoint) -> Square? {
			return filledSquares().filter({$0.point == point}).first
		}
		
		func getAdjacentFilledSquares(atPoint point: BoardPoint, vertically v: Bool, horizontally h: Bool, original: Square, inout output: Set<Square>) {
			if let sq = getFilledSquare(atPoint: point) {
				if (sq == original || !output.contains(sq)) {
					output.insert(sq)
					if h {
						getAdjacentFilledSquares(atPoint: (point.x + 1, point.y), vertically: v, horizontally: h, original: original, output: &output)
						getAdjacentFilledSquares(atPoint: (point.x - 1, point.y), vertically: v, horizontally: h, original: original, output: &output)
					}
					if v {
						getAdjacentFilledSquares(atPoint: (point.x, point.y + 1), vertically: v, horizontally: h, original: original, output: &output)
						getAdjacentFilledSquares(atPoint: (point.x, point.y - 1), vertically: v, horizontally: h, original: original, output: &output)
					}
				}
			}
		}
		
		func getWords(aroundSquares squares: [Square]) -> [Word] {
			// Now collect all dropped tiles in both directions
			var words = [Word]()
			var tempWord = Word(squares)
			if tempWord.isValidArrangement {
				var output = Set<Square>()
				for square in squares {
					getAdjacentFilledSquares(atPoint: square.point, vertically: true, horizontally: false, original: square, output: &output)
					getAdjacentFilledSquares(atPoint: square.point, vertically: false, horizontally: true, original: square, output: &output)
				}
				var adjacentSquares = Array(output)
				if tempWord.isVertical {
					// Get the word that we played vertically
					var fullWordSquares = adjacentSquares.filter({$0.point.x == tempWord.column})
					var fullWord = Word(fullWordSquares)
					words.append(fullWord)
					// Now collect all words played horizontally
					for square in squares {
						var rowWordSquares = adjacentSquares.filter({$0.point.y == square.point.y})
						if rowWordSquares.count > 1 {
							var rowWord = Word(rowWordSquares)
							words.append(rowWord)
						}
					}
				} else {
					// Get the word that we played horizontally
					var fullWordSquares = adjacentSquares.filter({$0.point.y == tempWord.row})
					var fullWord = Word(fullWordSquares)
					words.append(fullWord)
					// Now collect all words played vertically
					for square in squares {
						var columnWordSquares = adjacentSquares.filter({$0.point.x == square.point.x})
						if columnWordSquares.count > 1 {
							var columnWord = Word(columnWordSquares)
							words.append(columnWord)
						}
					}
				}
			}
			return words
		}
	
	
		// Word: Collection of squares
		class Word {
			let squares: [Square]
			let word: String
			let length: Int
			let isVertical: Bool
			var isValidArrangement: Bool = true
			let row: Int
			let column: Int
			init(_ squares: [Square]) {
				// Sort squares as we add them
				self.squares = squares.sorted({$0.point.x + $0.point.y < $1.point.x + $1.point.y})
				
				// Get value of word
				self.word = join("", self.squares.map{$0.tile?.letter}.filter{$0 != nil}.map{$0!})
				self.length = self.word.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
				
				// Determine bounding rect
				let x = self.squares.map({$0.point.x})
				let y = self.squares.map({$0.point.y})
				let minX = x.reduce(Int.max, combine:{min($0, $1)})
				let maxX = x.reduce(Int.min, combine:{max($0, $1)})
				let minY = y.reduce(Int.max, combine:{min($0, $1)})
				let maxY = y.reduce(Int.min, combine:{max($0, $1)})
				
				// Determine if arrangement is valid
				self.isVertical = minX == maxX
				if minX == maxX {
					self.column = maxX
					self.row = -1
				} else if minY == maxY {
					self.row = maxY
					self.column = -1
				} else {
					self.column = -1
					self.row = -1
				}
				// TODO: Restore this code
				/*
				if self.length < 1 {
					isValidArrangement = false
				} else {
					var previous : Square?
					for square in self.squares {
						if let prev = previous {
							if (prev.point.x == square.point.x && square.point.y != prev.point.y + 1) &&
								(prev.point.y == square.point.y && square.point.x != prev.point.x + 1) {
								isValidArrangement = false
								break
							} else {
								isValidArrangement = false
								break
							}
						}
						previous = square
					}
				}*/
			}
			
			func getPoints() -> Int {
				var total = 0
				for square in squares {
					total += square.faceValue()
				}
				for square in squares {
					total *= square.wordMultiplier()
				}
				return total
			}
		}
		
		// Square: Individual square on the board
		class Square: Hashable {
            enum SquareType {
                case Normal
                case Center
                case DoubleLetter
                case TripleLetter
                case DoubleWord
                case TripleWord
            }
			var hashValue: Int {
				get {
					return "\(point.x),\(point.y)".hashValue
				}
			}
            let squareType: SquareType
            let point: BoardPoint
            var immutable = false
            var tile: Tile?
            
            init(squareType: SquareType, point: BoardPoint) {
                self.squareType = squareType
                self.point = point
            }
            
            func faceValue() -> Int {
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
		var words: [Word]
        
        init(dimensions: Int) {
            self.dimensions = dimensions;
            self.squares = [Square]()
			self.words = [Word]()
			self.rect = CGRect(x: 0, y: 0, width: dimensions, height: dimensions)
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
        
        private func symmetrical(point: BoardPoint, offset: Int, offset2: Int, middle: Int) -> Bool {
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
	let dictionary: Dictionary
    
    init() {
        self.board = Board(dimensions: 15)
		self.bag = Bag(language:.English)
        self.rack = Rack()
        self.rack.replenish(fromBag: bag)
		self.dictionary = Dictionary(language: .English)
    }
}
