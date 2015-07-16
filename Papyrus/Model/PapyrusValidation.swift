//
//  PapyrusValidation.swift
//  Papyrus
//
//  Created by Chris Nevin on 15/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

// TODO: Create orientation/offset tuple (Orientation, Offset) to cleanup func logic...

typealias ValidationFunction = (inout tiles: [Tile]) throws -> (o: Orientation, range: (start: Offset, end: Offset))

extension Papyrus {
	private func addTiles(inout letters: Set<Tile>, offset: Offset, maxOffset: Offset?, o: Orientation, f: Offset -> (o: Orientation) -> Offset?) -> Offset {
		var start = offset
		while let n = f(start)(o: o) {
			guard let matched = tile(n) else { break }
			letters.insert(matched)
			start = n
			if let maximum = maxOffset where maximum == n { break }
		}
		return start
	}
	
	private func prepareTiles(inout letters: [Tile]) throws -> (o: Orientation, range: (start: Offset, end: Offset)) {
		var sorted = sortTiles(letters)
		guard let first = sorted.first?.square?.offset, last = sorted.last?.square?.offset else {
			throw ValidationError.InvalidTileArrangement
		}
		// For a single tile, lets make sure we have the right orientation
		// Otherwise, use orientation calculated above
		guard let o: Orientation = first == last ?
			(nil != tile(first.prev(.Horizontal)) ||
				nil != tile(first.next(.Horizontal))) ?
				.Horizontal : .Vertical : (first.x == last.x ?
					.Vertical : first.y == last.y ?
						.Horizontal : nil) else {
							throw ValidationError.InvalidTileArrangement
		}
		// Go through tiles to see if there are any gaps
		var tileSet = Set(sorted)
		let offset = addTiles(&tileSet, offset: first, maxOffset: last, o: o, f: Offset.next)
		if offset < last { throw ValidationError.InvalidTileArrangement }
		// Go in direction tiles were played to determine where word ends
		// Pad range with tiles played arround these `tiles`
		let range = (addTiles(&tileSet, offset: first, maxOffset: nil, o: o, f: Offset.prev),
			addTiles(&tileSet, offset: last, maxOffset: nil, o: o, f: Offset.next))
		// Resort the tiles
		letters = sortTiles(Array(tileSet))
		// Ensure all tiles are on same line, cannot be in multiple directions
		if letters.filter({ o == .Horizontal ? $0.square!.offset.y == first.y : $0.square!.offset.x == first.x }).count != letters.count {
			throw ValidationError.InvalidTileArrangement
		}
		return (o, range)
	}
	
	private func intersectingWords(word: Word) throws -> [Word] {
		var output = [Word]()
		let inverted = word.orientation.invert
		for tile in word.tiles {
			if let offset = tile.square?.offset {
				var tileSet = Set([tile])
				addTiles(&tileSet, offset: offset, maxOffset: nil, o: inverted, f: Offset.prev)
				addTiles(&tileSet, offset: offset, maxOffset: nil, o: inverted, f: Offset.next)
				if tileSet.count > 1 {
					do {
						if let intersectingWord = try Word(Array(tileSet), f: prepareTiles) {
							output.append(intersectingWord)
						}
					} catch (let err) {
						throw err
					}
				}
			}
		}
		return output
	}
	
	func move(letters: [Tile]) throws -> [Word] {
		var outWords = [Word]()
		do {
			if let word = try Word(letters, f: prepareTiles) {
				print("Main word: \(word.value)")
				let definition = try dictionary.defined(word.value)
				print("Definition: \(definition)")
				let intersectedWords = try intersectingWords(word)
				for intersectingWord in intersectedWords {
					print("-- Intersecting word: \(intersectingWord.value)")
					let definition = try dictionary.defined(intersectingWord.value)
					print("-- Definition: \(definition)")
				}
				if words.count == 0 && !word.intersectsCenter {
					throw ValidationError.NoCenterIntersection
				} else if words.count > 0 && intersectedWords.count == 0 && words.flatMap({$0.tiles}).filter({(word.tiles.contains($0))}).count == 0 {
					throw ValidationError.NoWordIntersection
				}
				// Prepare words to be returned, modified later
				outWords.extend(intersectedWords)
				outWords.append(word)
				// Calculate score for current move.
				// Filter out calculation for words with ALL fixed tiles.
				// If all tiles used add 50 to score.
				let summableWords = outWords.filter{!$0.immutable}
				let sum = summableWords.map({$0.points}).reduce(0, combine: +) +
					(word.length == PapyrusRackAmount ? 50 : 0)
				// Make tile fixed, no one will be able to drag them from this point onward.
				outWords.flatMap{$0.tiles}.map{$0.placement = .Fixed}
				// Assign `summableWords` to `outWords` so we can return them.
				outWords = summableWords
				// Add words to played words.
				words.unionInPlace(outWords)
				// Add score to current player.
				player?.score += sum
				// Refill their rack.
				player?.refill(tileIndex, f: drawTiles, countf: countTiles)
				print("Sum: \(sum), new total: \(player!.score)")
				// If tiles.count == 0 current player won
				if tiles(withPlacement: .Rack, owner: player).count == 0 {
					// Assumption, player won!
					changedState(.Completed)
					// Calculate all other players tiles to subtract
					var index = 1;
					for p in players {
						let newScore = tiles(withPlacement: .Rack, owner: p).map({$0.value}).reduce(p.score, combine: -)
						print("Player \(index)'s new score: \(newScore)")
						p.score = newScore
						index++
					}
				}
			}
		}
		catch (let err) {
			throw err
		}
		return outWords
	}
}