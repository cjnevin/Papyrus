//
//  PapyrusValidation.swift
//  Papyrus
//
//  Created by Chris Nevin on 15/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

// TODO: Create orientation/offset tuple (Orientation, Offset) to cleanup func logic...

enum ValidationError: ErrorType {
    case Arrangement([Tile])
    case Center(Offset, Word)
    case Intersection(Word)
    case Invalid(Word)
    case Undefined(String)
    case Message(String)
    case NoTiles
}

typealias ValidationFunction = (inout tiles: Tiles) throws -> (o: Orientation, range: OffsetRange)

extension Papyrus {
    /// Add tiles found when walking in a direction within a given range.
    /// - Parameters:
    ///     - letters: In-out set of letters.
    ///     - o: Direction to search for letters.
    ///     - range: Offset range to search (optional end).
    ///     - f: Function to use for validation.
    /// - Returns: End Offset of a range.
    private func addTiles(inout letters: Set<Tile>, o: Orientation, range: OffsetRangeOptional, f:  OffsetOrientationFunction) -> Offset {
        var start = range.0
        while let n = f(start)(o: o), matched = tiles.at(n) {
            letters.insert(matched)
            start = n
            if let m = range.1 where m == n { break }
        }
        return start
    }
    
    /// Add tiles found when walking in a direction within a given range.
    /// - Parameters:
    ///     - letters: In-out set of letters.
    ///     - o: Direction to search for letters.
    ///     - range: Offset range to search (optional end).
    ///     - f: Function to use for validation.
    /// - Returns: Offset array
    private func addTiles(inout letters: Set<Tile>, o: Orientation, range: OffsetRangeOptional, f:  [OffsetOrientationFunction]) -> Offsets {
        return f.map { self.addTiles(&letters, o: o, range: range, f: $0) }
    }
    
    /// Conforms to ValidationFunction
    /// - Parameter letters: In-out array of sorted letters.
    /// - Returns: Tuple containing Orientation and an Offset Range for the given tiles.
    /// - Throws: ValidationError regarding tile configuration.
    private func validateTiles(inout letters: Tiles) throws -> (o: Orientation, range: OffsetRange) {
        let sorted = letters.sorted()
        guard let first = sorted.first?.square?.offset, last = sorted.last?.square?.offset else {
            throw ValidationError.NoTiles
        }
        // For a single tile, lets make sure we have the right orientation
        // Otherwise, use orientation calculated above
        guard let orientation: Orientation = first == last ?
            (nil != tiles.at(first.prev(.Horizontal)) ||
                nil != tiles.at(first.next(.Horizontal))) ?
                .Horizontal : .Vertical : (first.x == last.x ?
                    .Vertical : first.y == last.y ?
                        .Horizontal : nil) else {
                            throw ValidationError.Arrangement(sorted)
        }
        // Go through tiles to see if there are any gaps
        var tileSet = Set(sorted)
        let offset = addTiles(&tileSet, o: orientation, range: (first, last), f: Offset.next)
        if offset < last { throw ValidationError.Arrangement(Array(tileSet)) }
        // Go in direction tiles were played to determine where word ends
        // Pad range with tiles played arround these `tiles`
        let range = (addTiles(&tileSet, o: orientation, range: (first, nil), f: Offset.prev),
                     addTiles(&tileSet, o: orientation, range: (last, nil), f: Offset.next))
        // Resort the tiles
        letters = tileSet.sorted()
        // Ensure all tiles are on same line, cannot be in multiple directions
        if letters.filter({ orientation == .Horizontal ? $0.square!.offset.y == first.y : $0.square!.offset.x == first.x }).count != letters.count {
            throw ValidationError.Arrangement(letters)
        }
        return (orientation, range)
    }
    
    /// - Parameter word: Word to check intersections against.
    /// - Returns: An array of Words that intersect the word given.
    /// - Throws: Fails if a Word cannot be validated.
    private func intersectingWords(word: Word) throws -> Words {
        var output = Words()
        let inverted = word.orientation.invert
        for tile in word.tiles.filter({ $0.square?.offset != nil }) {
            var tileSet = Set([tile])
            addTiles(&tileSet, o: inverted, range: (tile.square!.offset, nil),
                f: [Offset.prev, Offset.next])
            if tileSet.count > 1 {
                if let intersectingWord = try Word(Array(tileSet), f: validateTiles) {
                    output.append(intersectingWord)
                }
            }
        }
        return output
    }
    
    /// Completes the game if the current player has no tiles in their rack.
    private func completeGameIfNoTilesInRack() {
        // If tiles.count == 0 current player won
        if tiles.inRack(player).count == 0 {
            // Assumption, player won!
            changeFunction?(.Completed, self)
            // Calculate all other players tiles to subtract
            var index = 1;
            for p in players {
                let newScore = tiles.inRack(p).map({ $0.value }).reduce(p.score, combine: -)
                print("Player \(index)'s new score: \(newScore)")
                p.score = newScore
                index++
            }
        }
    }
    
    /// - Parameter letters: Tiles to attempt to play.
    /// - Returns: An array of Words that are included in this play.
    /// - Throws: Fails if a Word cannot be validated.
    func move(letters: Tiles) throws -> Words {
        var outWords = Words()
        if let word = try Word(letters, f: validateTiles), player = player {
            print("Main word: \(word.value)")
            let definition = try Lexicon.sharedInstance.defined(word.value)
            print("Definition: \(definition)")
            let intersectedWords = try intersectingWords(word)
            for intersectingWord in intersectedWords {
                print("-- Intersecting word: \(intersectingWord.value)")
                let definition = try Lexicon.sharedInstance.defined(intersectingWord.value)
                print("-- Definition: \(definition)")
            }
            if words.count == 0 && !word.intersectsCenter {
                throw ValidationError.Center(PapyrusMiddleOffset!, word)
            } else if words.count > 0 && intersectedWords.count == 0 && words.flatMap({ $0.tiles }).filter({ word.tiles.contains($0) }).count == 0 {
                throw ValidationError.Intersection(word)
            }
            // Prepare words to be returned, modified later
            outWords.extend(intersectedWords)
            outWords.append(word)
            // Calculate score for current move.
            // Filter out calculation for words with ALL fixed tiles.
            // If all tiles used add 50 to score.
            let sum = word.bonus + outWords.map{ $0.points }.reduce(0, combine: +)
            // Make tile fixed, no one will be able to drag them from this point onward.
            // Assign `mutableWords` to `outWords` so we can return them.
            outWords = outWords.filter{ !$0.immutable }
            outWords.flatMap({ $0.tiles }).map({ $0.placement = .Fixed(player, $0.square!) })
            // Add words to played words.
            words.unionInPlace(outWords)
            // Add score to current player.
            player.score += sum
            print("Sum: \(sum), new total: \(player.score)")
            // Refill their rack.
            replenishRack(player: player)
            // TODO: Remove
            //possibilities(withTiles: rackTiles)
            completeGameIfNoTilesInRack()
        }
        return outWords
    }
}