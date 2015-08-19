//
//  Play.swift
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
    
    func extend(boundary: Boundary) -> Boundary {
        let newStart = loop(boundary.start) ?? boundary.start
        let newEnd = loop(boundary.end) ?? boundary.end
        return Boundary(start: newStart, end: newEnd)
    }
    
    /// - Parameter boundary: Boundary to check.
    /// - Parameter submit: Whether this move is final or just used for validation.
    /// - Throws: If boundary cannot be played you will receive a ValidationError.
    /// - Returns: Score of word including intersecting words.
    func play(boundary: Boundary, submit: Bool) throws -> Int {
        
        // If boundary validation fails, fail.
        //if !boundary.isValid { throw ValidationError.InvalidArrangement }
        
        // If no words have been played, this boundary must intersect middle.
        let m = PapyrusMiddle - 1
        if playedBoundaries.count == 0 && (boundary.start.fixed != m ||
            boundary.start.iterable > m || boundary.end.iterable < m) { throw ValidationError.NoCenterIntersection }
        
        // If boundary contains squares that are empty, fail.
        let tiles = tilesIn(boundary)
        if tiles.count != boundary.length { throw ValidationError.UnfilledSquare }
        
        // If no words have been played ensure that tile count is valid.
        //if playedBoundaries.count == 0 && tiles.count < 2 { throw ValidationError.InsufficientTiles }
        
        // If all of these tiles are not owned by the current player, fail.
        if player?.tiles.filter({tiles.contains($0)}).count == 0 { throw ValidationError.InsufficientTiles }
        
        // TODO: Switch to intersectingPositionBoundaries...
        
        print("INTERSECT: \(readable(intersectingBoundaries(true, row: boundary.start.fixed, col: boundary.start.iterable)))")
        
        // If words have been played, it must intersect one of these played words.
        // Assumption: Previous boundaries have passed validation.
        if playedBoundaries.count > 0 && intersectingPlays(boundary).count == 0 { throw ValidationError.NoIntersection }
        
        // Validate words, will throw if any are invalid...
        
        // Check if main word is valid.
        let mainWord = String(tiles.mapFilter({$0.letter}))
        let _ = try Lexicon.sharedInstance.defined(mainWord)
        print(mainWord)
        
        // Calculate score for main word.
        var value = score(boundary)
        print(value)
        
        // Get new intersections created by this play, we may have modified other words.
        let intersections = intersectingBoundaries(boundary.start)
        value += score(intersections)
        
        // Check if intersecting words are valid.
        let words = readable(intersections)
        for word in words {
            let _ = try Lexicon.sharedInstance.defined(word)
            print(word)
        }
        print(value)
        
        // If final, add boundaries to played boundaries.
        if submit {
            // Add boundaries to played boundaries
            var finalBoundaries = [boundary]
            finalBoundaries.extend(intersections.map({$0.1}))
            for finalBoundary in finalBoundaries {
                if playedBoundaries.filter({$0.start == finalBoundary.start && $0.end == finalBoundary.end}).count == 0 {
                   playedBoundaries.append(finalBoundary)
                }
            }
            // Change tiles to 'fixed'
            tiles.map({$0.placement = Placement.Fixed})
            // Increment score
            player?.score += value
            if let player = player {
                // Draw new tiles. If count == 0 && rackCount == 0 complete game
                if replenishRack(player) == 0 && player.rackTiles.count == 0 {
                    // Subtract remaining tiles in racks
                    for player in players {
                        player.score = player.rackTiles.mapFilter({$0.value}).reduce(player.score, combine: -)
                    }
                    // Complete the game
                    lifecycleCallback?(.Completed, self)
                } else {
                    // Change player
                    //nextPlayer()
                    //lifecycleCallback?(.ChangedPlayer, self)
                    // Get playable boundaries
                    // Collect prospects for boundaries (anagramsOf + firstRackTile)
                    // Attempt AI play
                }
            }
        }
        return value
    }
}