//
//  PapyrusValidation.swift
//  Papyrus
//
//  Created by Chris Nevin on 15/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

enum ValidationError: ErrorType {
    case Arrangement([Tile])
    case Center(Offset, Word)
    case Intersection(Word)
    case Invalid(Word)
    case Undefined(String)
    case Message(String)
    case NoTiles
}

typealias ValidationFunction = (inout tiles: Tiles) throws -> (axis: Axis, range: OffsetRange)

extension Papyrus {
    func tileAxis(letters: Tiles, alreadySorted: Bool? = false) throws -> (Axis, Offset, Offset) {
        let sorted = alreadySorted! == true ? letters : letters.sorted()
        guard let first = sorted.first?.square?.offset, last = sorted.last?.square?.offset else {
            throw ValidationError.NoTiles
        }
        let axis: Axis
        if letters.count == 1 {
            axis = tiles.has(first.prev(.Vertical)) || tiles.has(first.next(.Vertical)) ?
                Axis.Vertical : Axis.Horizontal
        } else if first.x == last.x {
            axis = Axis.Vertical
        } else if first.y == last.y {
            axis = Axis.Horizontal
        } else {
            throw ValidationError.Arrangement(letters)
        }
        return (axis, first, last)
    }
    
    /// Add tiles found when walking in a direction within a given range.
    /// - Parameters:
    ///     - letters: In-out set of letters.
    ///     - axis: Direction to search for letters.
    ///     - range: Offset range to search (optional end).
    ///     - f: Function to use for validation.
    /// - Returns: End Offset of a range.
    private func addTiles(inout letters: Set<Tile>, axis: Axis, range: OffsetRangeOptional, f:  OffsetAxisFunction) -> Offset {
        var start = range.0
        while let n = f(start)(axis: axis), matched = tiles.at(n) {
            letters.insert(matched)
            start = n
            if let m = range.1 where m == n { break }
        }
        return start
    }
    
    /// Add tiles found when walking in a direction within a given range.
    /// - Parameters:
    ///     - letters: In-out set of letters.
    ///     - axis: Direction to search for letters.
    ///     - range: Offset range to search (optional end).
    ///     - f: Function to use for validation.
    /// - Returns: Offset array
    private func addTiles(inout letters: Set<Tile>, axis: Axis, range: OffsetRangeOptional, f:  [OffsetAxisFunction]) -> Offsets {
        return f.map { self.addTiles(&letters, axis: axis, range: range, f: $0) }
    }
    
    /// Conforms to ValidationFunction
    /// - Parameter letters: In-out array of sorted letters.
    /// - Returns: Tuple containing Axis and an Offset Range for the given tiles.
    /// - Throws: ValidationError regarding tile configuration.
    func validateTiles(inout letters: Tiles) throws -> (axis: Axis, range: OffsetRange) {
        let sorted = letters.sorted()
        let (axis, first, last) = try tileAxis(sorted, alreadySorted: true)
        // Go through tiles to see if there are any gaps
        var tileSet = Set(sorted)
        let offset = addTiles(&tileSet, axis: axis, range: (first, last), f: Offset.next)
        if offset < last { throw ValidationError.Arrangement(Array(tileSet)) }
        // Go in direction tiles were played to determine where word ends
        // Pad range with tiles played arround these `tiles`
        let range = (addTiles(&tileSet, axis: axis, range: (first, nil), f: Offset.prev),
                     addTiles(&tileSet, axis: axis, range: (last, nil), f: Offset.next))
        // Resort the tiles
        letters = tileSet.sorted()
        // Ensure all tiles are on same line, cannot be in multiple directions
        if letters.filter({ axis == .Horizontal ? $0.square!.offset.y == first.y : $0.square!.offset.x == first.x }).count != letters.count {
            throw ValidationError.Arrangement(letters)
        }
        return (axis, range)
    }
    
    /// - Parameter word: Word to check intersections against.
    /// - Returns: An array of Words that intersect the word given.
    /// - Throws: Fails if a Word cannot be validated.
    func intersectingWords(word: Word) throws -> Words {
        var output = Words()
        let inverted = word.axis.invert
        for tile in word.tiles.filter({ $0.square?.offset != nil }) {
            var tileSet = Set([tile])
            addTiles(&tileSet, axis: inverted, range: (tile.square!.offset, nil),
                f: [Offset.prev, Offset.next])
            if tileSet.count > 1 {
                if let intersectingWord = try Word(Array(tileSet), validator: validateTiles) {
                    output.append(intersectingWord)
                }
            }
        }
        return output
    }
    
    /// Completes the game if the current player has no tiles in their rack.
    func completeGameIfNoTilesInRack() {
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
    
    /// Calculate score for a played word.
    private func calculateScore(playedWord: Word, intersecting array: Words) -> [Tile]? {
        guard let player = player else { return nil }
        // Calculate score for current move.
        // Filter out calculation for words with ALL fixed tiles.
        // If all tiles used add 50 to score.
        let sum = playedWord.bonus + playedWord.points + array.map{ $0.points }.reduce(0, combine: +)
        // Make tile fixed, no one will be able to drag them from this point onward.
        // Assign `mutableWords` to `outWords` so we can return them.
        var outWords = array
        var outTiles = [Tile]()
        outWords.append(playedWord)
        outWords.filter({ !$0.immutable }).map({
            for i in 0..<$0.tiles.count {
                assert($0.squares.count > i)
                assert($0.tiles.count > i)
                let square = $0.squares[i], tile = $0.tiles[i]
                tile.placement = .Fixed(player, square)
                outTiles.append(tile)
            }
        })
        // Add words to played words.
        words.unionInPlace(outWords)
        // Add score to current player.
        player.score += sum
        print("Sum: \(sum), new total: \(player.score)")
        // Refill their rack.
        replenishRack(player: player)
        // Check if the game is complete
        completeGameIfNoTilesInRack()
        return outTiles
    }
    
    /// - Returns: An array of Tiles that were played.
    func automateMove(f: (Tiles?) -> Void) {
        
        
        findProspect(withTiles: tiles.inRack(player), prospect: { (prospect) -> Void in
            guard let prospect = prospect else {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    f(nil)
                }
                return
            }
            var tiles = prospect.intersected.flatMap({ $0.tiles })
            tiles.extend(prospect.word.tiles)
            assert(tiles.filter({ Tile.match($0.placement, unassociatedPlacement: Tile.UnassociatedPlacement.Fixed) }).count > 0)
            for intersect in prospect.intersected {
                print("\(intersect.value), \(intersect.axis)")
            }
            print("\(prospect.word.value), \(prospect.word.axis)")
            let dropped = self.calculateScore(prospect.word, intersecting: prospect.intersected)
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                f(dropped)
            }
        })
    }
    
    /// - Parameter letters: Tiles to attempt to play.
    /// - Returns: An array of Tiles that are included in this play.
    /// - Throws: Fails if a Word cannot be validated.
    func move(letters: Tiles) throws -> Tiles? {
        if let word = try Word(letters, validator: validateTiles) {
            print("Main word: \(word.value), \(word.axis)")
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
            } else if words.count > 0 && intersectedWords.count == 0 &&
                words.flatMap({ $0.tiles }).filter({ word.tiles.contains($0) }).count == 0 {
                throw ValidationError.Intersection(word)
            }
            // Prepare words to be returned, modified later
            var tiles = intersectedWords.flatMap({ $0.tiles })
            tiles.extend(word.tiles)
            calculateScore(word, intersecting: intersectedWords)
            return tiles
        }
        return nil
    }
}