//
//  Game.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import Foundation

// MARK:- Generic Operators

infix operator |>   { precedence 50 associativity left }

func |> <T,U>(lhs: T, rhs: T -> U) -> U {
	return rhs(lhs)
}

// MARK:- Class Operators

func == (lhs: Game.Board.Coordinate, rhs: Game.Board.Coordinate) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}
func < (lhs: Game.Board.Coordinate, rhs: Game.Board.Coordinate) -> Bool {
	return lhs.x + lhs.y < rhs.x + rhs.y
}
func > (lhs: Game.Board.Coordinate, rhs: Game.Board.Coordinate) -> Bool {
	return lhs.x + lhs.y > rhs.x + rhs.y
}
func == (lhs: Game.Tile, rhs: Game.Tile) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
func == (lhs: Game.Board.Square, rhs: Game.Board.Square) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

// MARK:- Game

enum GameFactoryState {
	case Preparing
	case Ready
	case Completed
}

class GameFactory {
	static let sharedInstance = GameFactory()
	var game: Game?
	func newGame(stateChanged: (GameFactoryState) -> ()) {
		game = nil
		stateChanged(.Preparing)
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			// TODO: Make Game send updates for critical events, like no tiles remaining.
			autoreleasepool {
				self.game = Game()
				dispatch_async(dispatch_get_main_queue()) {
					stateChanged(.Ready)
				}
			}
		}
	}
}

class Game {
	// Create some aliases for easier use
	typealias Coordinate = Board.Coordinate
	typealias Square = Board.Square
	typealias SquareType = Square.SquareType
	typealias Word = Board.Word
	
	// Shared
	enum Language: String {
		case English = "CSW12"
	}
	enum Orientation {
		case Horizontal
		case Vertical
		func opposite() -> Orientation {
			return self == .Horizontal ? .Vertical : .Horizontal
		}
	}
	
	let bag: Bag
	let board: Board
	let dictionary: Dictionary
	lazy var players = [Player]()
	var currentPlayer: Player?
	var rack: Rack? {
		get {
			return currentPlayer?.rack
		}
	}
	init() {
		dictionary = Dictionary(language: .English)
		board = Board(dimensions: 15)
		bag = Bag(language:.English)
		addPlayer()	// Need at least one
	}
	
	
	// MARK:- Player
	
	func addAI(intelligence: AIPlayer.Intelligence) {
		let ai = AIPlayer(i: intelligence)
		ai.rack.replenish(fromBag: bag)
		players.append(ai)
		if currentPlayer == nil {
			currentPlayer = ai
		}
	}
	
	class AIPlayer : Player {
		enum Intelligence {
			case Newbie
			case Master
		}
		let intelligence: Intelligence
		init(i: Intelligence) {
			intelligence = i
		}
	}
	
	func addPlayer() {
		var player = Player()
		player.rack.replenish(fromBag: bag)
		players.append(player)
		if currentPlayer == nil {
			currentPlayer = player
		}
	}
	
	class Player {
		let rack: Rack
		private var points = 0
		var score: Int {
			get {
				return points
			}
		}
		init() {
			rack = Rack()
		}
		func incrementScore(value: Int) {
			points += value
			println("Added Score: \(value), new score: \(points)")
		}
	}
	
	// MARK:- Dictionary / AI
	
	class Dictionary {
		private static let DefKey = "Def"
		private let dictionary: NSDictionary
		let language: Language
		init(language l: Language) {
			language = l
			if let path = NSBundle.mainBundle().pathForResource(language.rawValue, ofType: "plist"),
				values = NSDictionary(contentsOfFile: path) {
				dictionary = values
			} else {
				dictionary = NSDictionary()
			}
		}
		
		func defined(word: String) -> (Bool, String?) {
			var current = dictionary
			var index = word.startIndex
			for char in word.uppercaseString {
				if let inner = current.objectForKey(String(char)) as? NSDictionary {
					index = advance(index, 1)
					if index == word.endIndex {
						if let definition = inner.objectForKey(Dictionary.DefKey) as? String {
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
		
		private func findWords(forLetters letters: [String], prefix: String, source: NSDictionary, inout results: [String]) {
			if let definition = source[Dictionary.DefKey] as? String {
				results.append(prefix)
			}
			for key in source.allKeys as! [String] {
				// Could be cleaned up
				autoreleasepool {
					if let index = find(letters, "?"), newSource = source[key] as? NSDictionary {
						var newLetters = letters
						newLetters.removeAtIndex(index)
						findWords(forLetters: newLetters, prefix: "\(prefix)\(key)", source: newSource, results: &results)
					} else if let index = find(letters, key), newSource = source[key] as? NSDictionary {
						var newLetters = letters
						newLetters.removeAtIndex(index)
						findWords(forLetters: newLetters, prefix: "\(prefix)\(key)", source: newSource, results: &results)
					}
				}
			}
		}
		
		func possibleWords(forLetters letters: [String]) -> [String] {
			var results = [String]()
			findWords(forLetters: letters, prefix: "", source: dictionary, results: &results)
			return results
		}
	}
	
	
	// MARK:- Tile Management
	
	class Bag {
		var total: Int {
			get {
				return totalTiles
			}
		}
		var remaining: Int {
			get {
				return left
			}
		}
		let language: Language
		
		private let totalTiles: Int
		private var left = 0
		private var tiles: [Tile]
		
		init(language: Language) {
			tiles = [Tile]()
			self.language = language
			let cfg = [(9, 1, "A"), (2, 3, "B"), (2, 3, "C"), (4, 2, "D"), (12, 1, "E"),
				(2, 4, "F"), (3, 2, "G"), (2, 4, "H"), (9, 1, "I"), (1, 8, "J"), (1, 5, "K"),
				(4, 1, "L"), (2, 3, "M"), (6, 1, "N"), (8, 1, "O"), (2, 3, "P"), (1, 10, "Q"),
				(6, 1, "R"), (4, 1, "S"), (6, 1, "T"), (4, 1, "U"), (2, 4, "V"), (2, 4, "W"),
				(2, 4, "Y"), (1, 10, "Z"), (2, 0, "?")]
			for (count, value, letter) in cfg {
				for _ in 1...count {
					tiles.append(Tile(letter: letter, value: value))
				}
			}
			totalTiles = tiles.count
			left = totalTiles
		}
		func getTile() -> Tile? {
			if tiles.count > 0 {
				let index = Int(arc4random_uniform(UInt32(tiles.count)))
				let tile = tiles[index]
				tiles.removeAtIndex(index)
				left = tiles.count
				return tile
			}
			return nil
		}
	}
	
	class Rack {
		let amount = 7
		lazy var tiles = [Tile]()
		func replenish(fromBag bag: Bag) -> [Tile] {
			var needed = amount - tiles.count
			var newTiles = [Tile]()
			if needed > 0 {
				for _ in 1...needed {
					if let tile = bag.getTile() {
						newTiles.append(tile)
					}
				}
			}
			tiles.extend(newTiles)
			return newTiles
		}
	}
	
	class Tile: Equatable {
		let value: Int
		var letter: String?		// Changeable from blank (?)
		init(letter l: String, value v: Int) {
			letter = l
			value = v
		}
	}
	
	
	// MARK:- Game Board
	
	func validate(squares: [Square], inout outWords: [Word]) -> (Bool, errors: [String]) {
		let newWords = board.getWords(aroundSquares: squares)
		outWords = newWords
		if newWords.count == 0 {
			return (false, ["Invalid tile arrangement."])
		}
		var errors = [String]()
		for word in newWords {
			if !word.isValidArrangement {
				errors.append("Invalid tile arrangement.")
			} else {
				let (valid, definition) = dictionary.defined(word.word)
				if valid {
					println("Valid word: \(word.word),  definition: \(definition!)")
				} else {
					errors.append("Invalid word: \(word.word)")
				}
			}
		}
		// Check if first play
		if board.words.count == 0 {
			if newWords.count != 1 {
				errors.append("First play must have all tiles lined up.")
			}
			if let word = newWords.first {
				// Ensure word is valid length
				if word.length < 2 {
					errors.append("You must play more than one letter.")
				}
				// Ensure word intersects center
				if !board.containsCenterSquare(inArray: word.squares) {
					errors.append("First play must intersect the center square.")
				}
			}
		} else {
			// Word must intersect the center tile, via another word
			var output = Set<Square>()
			for square in squares {
				board.getAdjacentFilledSquares(square.c, vertically: true, horizontally: true, original: square, output: &output)
			}
			if !board.containsCenterSquare(inArray: Array(output)) {
				errors.append("New words must intersect existing words.")
			}
		}
		return (errors.count == 0, errors)
	}
	
	
	class Board {
		let dimensions: Int
		lazy var squares = [Square]()
		lazy var words = [Word]()
		init(dimensions d: Int) {
			dimensions = d;
			let m = d/2+1
			let cfg: [SquareType: [(Int, Int)]] = [
				.Center: [(0,0)],
				.TripleWord: [(m-1, m-1), (0, m-1)],
				.DoubleLetter: [(1, 1), (1, 5), (0, 4), (m-1, 4)],
				.TripleLetter: [(2, 6), (2, 2)],
				.DoubleWord: [(3, 3), (4, 4), (5, 5), (6, 6)]]
			for row in 1...d {
				for col in 1...d {
					var c = Coordinate(row, y:col)
					var found = false
					for (type, offsets) in cfg {
						for offset in offsets {
							if isSymmetrical(c, offset: offset, middle: m) {
								squares.append(Square(type, c: c))
								found = true
								break
							}
						}
						if found {
							break
						}
					}
					if !found {
						squares.append(Square(.Normal, c:c))
					}
				}
			}
		}
		
		func calculatePossibleWords(tiles: [Tile], o: Orientation) -> [String] {
			// Iterate a = 1...d in orientation
			// Collect all filled perpendicular squares
			
			
			// Iterate b = 1...d in opposite orientation
			// - For each (a, b) see
			
			var c: Coordinate? = Coordinate(1, y:1)
			var yo = o.opposite()
			while c != nil {
				println(join(",",self.perpendicularSquares(o, c: c!).map({($0.tile?.letter != nil ? $0.tile!.letter : "_")!})))
				/*
				
				var yc: Coordinate? = c
				while yc != nil {
					var filled = Set<Square>()
					getAdjacentFilledSquares(yc, vertically: true, horizontally: true, original: squares.filter({$0.c == yc}).first!, output: &filled)
					if filled.count > 0 {
						// Linked to tiles
						println("\(yc!.x) : \(yc!.y)")
					}
					
					yc = yc?.next(yo, d: 1, b: self)
				}*/
				c = c?.next(o, d: 1, b: self)
			}
			return [String]()
		}
		
		func containsCenterSquare(inArray squares: [Square]) -> Bool {
			return (squares.filter{$0.squareType == Square.SquareType.Center}).count == 1
		}
		
		func getFilledSquare(c: Coordinate) -> Square? {
			return squares
				|> { s in filter(s) { $0.c == c && $0.tile != nil } }
				|> { s in first(s) }
		}
		
		func getLetter(c: Coordinate) -> String? {
			return squares
				|> { s in filter(s) { $0.c == c } }
				|> { s in map(s) { $0.tile!.letter! } }
				|> { s in first(s) }
		}
		
		func getAdjacentFilledSquares(c: Coordinate?, vertically v: Bool, horizontally h: Bool, original: Square, inout output: Set<Square>) {
			// We may hit the original square several times in different directions, so we allow it through multiple times
			if let coord = c, sq = getFilledSquare(coord) where sq == original || !output.contains(sq) {
				output.insert(sq)
				if h {
					getAdjacentFilledSquares(coord.next(.Horizontal, d: 1, b: self), vertically: v, horizontally: h, original: original, output: &output)
					getAdjacentFilledSquares(coord.next(.Horizontal, d: -1, b: self), vertically: v, horizontally: h, original: original, output: &output)
				}
				if v {
					getAdjacentFilledSquares(coord.next(.Vertical, d: 1, b: self), vertically: v, horizontally: h, original: original, output: &output)
					getAdjacentFilledSquares(coord.next(.Vertical, d: -1, b: self), vertically: v, horizontally: h, original: original, output: &output)
				}
			}
		}
		
		func getWords(aroundSquares squares: [Square]) -> [Word] {
			// Now collect all dropped tiles in both directions
			var words = [Word]()
			var tempWord = Word(squares)
			var output = Set<Square>()
			for square in squares {
				getAdjacentFilledSquares(square.c, vertically: true, horizontally: false, original: square, output: &output)
				getAdjacentFilledSquares(square.c, vertically: false, horizontally: true, original: square, output: &output)
			}
			let adjacentSquares = Array(output)
			if tempWord.orientation == .Vertical {
				// Get the word that we played vertically
				let fullWordSquares = adjacentSquares.filter({$0.c.x == tempWord.column})
				if fullWordSquares.count > 1 {
					words.append(Word(fullWordSquares))
				}
				// Now collect all words played horizontally
				for square in squares {
					let rowWordSquares = adjacentSquares.filter({$0.c.y == square.c.y})
					if rowWordSquares.count > 1 {
						words.append(Word(rowWordSquares))
					}
				}
			} else {
				// Get the word that we played horizontally
				let fullWordSquares = adjacentSquares.filter({$0.c.y == tempWord.row})
				if fullWordSquares.count > 1 {
					words.append(Word(fullWordSquares))
				}
				// Now collect all words played vertically
				for square in squares {
					let columnWordSquares = adjacentSquares.filter({$0.c.x == square.c.x})
					if columnWordSquares.count > 1 {
						words.append(Word(columnWordSquares))
					}
				}
			}
			return words
		}
		
		private func isSymmetrical(c: Coordinate, offset: (Int, Int), middle m: Int) -> Bool {
			let a = offset.0, b = offset.1
			return contains([Coordinate(m - a, y:m - b),
				Coordinate(m - a, y:m + b),
				Coordinate(m + a, y:m + b),
				Coordinate(m + a, y:m - b),
				Coordinate(m - b, y:m - a),
				Coordinate(m - b, y:m + a),
				Coordinate(m + b, y:m + a),
				Coordinate(m + b, y:m - a)], c)
		}
		
		func perpendicularSquares(o: Orientation, c: Coordinate) -> [Square] {
			return squares.filter({ o.opposite() == .Vertical ? $0.c.y == c.x : $0.c.x == c.y })
		}
		
		func noTile(c: Coordinate) -> Bool {
			return squares.filter({$0.tile == nil && $0.c == c}).count == 0
		}
		
		class Coordinate: Equatable {
			let x, y: Int
			init(_ coord:(Int, Int)) {
				x = coord.0
				y = coord.1
			}
			init(_ x: Int, y: Int) {
				self.x = x
				self.y = y
			}
			func next(o: Orientation, d:Int, b: Board) -> Coordinate? {
				if o == .Horizontal {
					var z = x + d
					if z >= 0 && z <= b.dimensions {
						return Coordinate(z, y: y)
					}
				} else {
					let z = y + d
					if z >= 0 && z <= b.dimensions {
						return Coordinate(x, y: z)
					}
				}
				return nil
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
					return "\(c.x),\(c.y)".hashValue
				}
			}
			let c: Coordinate
			let squareType: SquareType
			var immutable = false
			var tile: Tile?
			init(_ squareType: SquareType, c: Coordinate) {
				self.squareType = squareType
				self.c = c
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
				if let value = tile?.value {
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
		
		// Word: Collection of squares
		class Word {
			let squares: [Square]
			let word: String
			let orientation: Orientation
			private var validArrangement = true
			var isValidArrangement: Bool {
				get {
					return validArrangement
				}
			}
			let length, row, column: Int
			var points: Int {
				get {
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
			init(_ squares: [Square]) {
				// Sort squares as we add them
				self.squares = (squares |> {s in sorted(s) {$0.c < $1.c} })
				
				// Get value of word
				word = (self.squares
					|> { s in map(s) {$0.tile?.letter} }
					|> { s in filter(s) {$0 != nil} }
					|> { s in map(s) {$0!} }
					|> String.join(""))
				length = word.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
				
				// Determine bounding rect
				let x = self.squares.map({$0.c.x})
				let y = self.squares.map({$0.c.y})
				let minX = x.reduce(Int.max, combine:{min($0, $1)})
				let maxX = x.reduce(Int.min, combine:{max($0, $1)})
				let minY = y.reduce(Int.max, combine:{min($0, $1)})
				let maxY = y.reduce(Int.min, combine:{max($0, $1)})
				
				// Determine if arrangement is valid
				orientation = minX == maxX ? .Vertical : .Horizontal
				if minX == maxX {
					column = maxX
					row = -1
				} else if minY == maxY {
					row = maxY
					column = -1
				} else {
					column = -1
					row = -1
				}
				var previous: Square?
				for square in self.squares {
					if let prev = previous where (minY == maxY && prev.c.x + 1 != square.c.x) || (minX == maxX && prev.c.y + 1 != square.c.y) {
						validArrangement = false
						break
					}
					previous = square
				}
			}
		}
	}
}
