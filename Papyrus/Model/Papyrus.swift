//
//  Papyrus.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

let RackAmount: Int = 7

class Papyrus {
	enum State {
		case Preparing
		case Ready
		case Completed
	}

	typealias StateChangedFunction = (State, Papyrus?) -> ()
	let fState: StateChangedFunction
	let squares: [[Square]]
	var tiles: [Tile]
	var tileIndex: Int = 0
	let dictionary: Dictionary
	lazy var words = [Word]()
	lazy var players = [Player]()
	var player: Player?
	
	private init(f: StateChangedFunction) {
		fState = f
		squares = Papyrus.createSquares()
		print(squares.count)
		
		tiles = Papyrus.createTiles()
		print(tiles.count)
		
		dictionary = Dictionary(.English)
		
		players.append(createPlayer())
		player = players.first
		/*players.append(createPlayer())
		players.append(createPlayer())
		players.append(createPlayer())
		players.append(createPlayer())
		players.append(createPlayer())
		players.append(createPlayer())
		players.append(createPlayer())
		*/
		changedState(.Ready)
	}
	
	func changedState(state: State) {
		// Papyrus is created on a background thread, we want to pass these events to the main thread.
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			self.fState(state, self)
		}
	}
	
	func submit(word: Word) throws {
		// Validate the word that we played, and all words that intersect our word.
		/*
		
		
		var affectedWords = Set<Word>()
		var definitions = [String]()
		do {
			try validate(word: word, affectedWords: &affectedWords, definitions: &definitions)
		}
		catch (let err) {
			throw err
		}
		// Make tile fixed, no one will be able to drag them from this point onward.
		affectedWords.flatMap{$0.tiles}.map{$0.placement = .Fixed}
		// Add words to played words.
		words.extend(affectedWords)
		// Increment score for current player.
		var sum = affectedWords.flatMap{$0.points}.reduce(0, combine: +)
		if word.length == RackAmount { sum += 50 }
		player?.score += sum
		// Refill their rack.
		player?.refill(tileIndex, f: drawTiles, countf: countTiles)*/
	}
}

extension Papyrus {
	class func newGame(f: StateChangedFunction) {
		f(.Preparing, nil)
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			autoreleasepool {
				let _ = Papyrus(f: f)
			}
		}
	}
}