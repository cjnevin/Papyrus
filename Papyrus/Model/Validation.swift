//
//  PapyrusValidation.swift
//  Papyrus
//
//  Created by Chris Nevin on 15/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    
    /// - Parameter givenBoundary: Boundary of tiles that have been dropped on the board.
    /// - Returns: Array of boundaries that intersect the supplied boundary.
    func intersectingPlays(givenBoundary: Boundary) -> Boundaries {
        // Perhaps these should be persisted and created on submission?
        var output = Boundaries()
        for boundary in playedBoundaries {
            // Check if given boundary is intersecting this boundary...
            if boundary.iterableInsection(givenBoundary) ||
                boundary.adjacentIntersection(givenBoundary) ||
                boundary.oppositeIntersection(givenBoundary) {
                output.append(boundary)
            }
        }
        return output
    }
    
    /// - Parameter boundary: Boundary to check.
    /// - Parameter submit: Whether this move is final or just used for validation.
    /// - Returns: True if boundary appears to be playable and words are all valid.
    func playBoundary(boundary: Boundary, submit: Bool) throws {
        // If boundary validation fails, fail.
        if !boundary.isValid { throw ValidationError.InvalidArrangement }
        
        // If no words have been played, this boundary must intersect middle.
        if playedBoundaries.count == 0 && (boundary.start.fixed != PapyrusMiddle ||
            boundary.start.iterable > PapyrusMiddle || boundary.end.iterable < PapyrusMiddle) { throw ValidationError.NoCenterIntersection }
        
        // If boundary contains squares that are empty, fail.
        let tiles = tilesIn(boundary)
        if tiles.count != boundary.length { throw ValidationError.UnfilledSquare }
        
        // If no words have been played ensure that tile count is valid.
        if playedBoundaries.count == 0 && tiles.count < 2 { throw ValidationError.InsufficientTiles }
        
        // If all of these tiles are not owned by the current player, fail.
        if player?.tiles.filter({tiles.contains($0)}).count == 0 { throw ValidationError.NoTiles }
        
        // If words have been played, it must intersect one of these played words.
        // Assumption: Previous boundaries have passed validation.
        if playedBoundaries.count > 0 && intersectingPlays(boundary).count == 0 { throw ValidationError.NoIntersection }
        
        
        // TODO: Calculate score.
        
        // Validate words, will throw if any are invalid...
        
        // Check if main word is valid.
        let mainWord = String(tiles.mapFilter({$0.letter}))
        let _ = try Lexicon.sharedInstance.defined(mainWord)
        print(mainWord)
        
        // Get new intersections created by this play, we may have modified other words.
        let intersections = intersectingBoundaries(boundary.start)

        // Check if intersecting words are valid.
        let words = readable(intersections)
        for word in words {
            let _ = try Lexicon.sharedInstance.defined(word)
            print(word)
        }
        
        // If final, add boundaries to played boundaries.
        if submit {
            var finalBoundaries = [boundary]
            finalBoundaries.extend(intersections.map({$0.1}))
            for finalBoundary in finalBoundaries {
                if playedBoundaries.filter({$0.start == finalBoundary.start && $0.end == finalBoundary.end}).count == 0 {
                   playedBoundaries.append(finalBoundary)
                }
            }
        }
        
        // Should happen after this method...
        // TODO: Change tiles to 'fixed'
        // Increment score
        // Draw new tiles. If count == 0 && rackCount == 0 complete game
        // Change player
        // Attempt AI play
        // Increment score
        // Draw tiles. If count == 0 && rackCount == 0 complete game
        // Change player
        // Wait
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
                f(nil)
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
            f(dropped)
        })
    }
    
}