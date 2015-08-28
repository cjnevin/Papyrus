//
//  Play.swift
//  Papyrus
//
//  Created by Chris Nevin on 15/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    
    ///  Attempt to play an AI move.
    ///  - parameter neededTilePositions: Tiles to add to the board if successful.
    func playAI(inout neededTilePositions: [(Square,Tile)]) throws {
        assert(playerIndex != 0)
        
        guard let player = player else { throw ValidationError.NoPlayer }
        
        // Get playable boundaries
        // Collect prospects for boundaries (anagramsOf + firstRackTile)
        // Attempt AI play
        // TODO: Fix, currently incorrect, gets stuck in 'loop(position: Position, validator: (position: Position)' loop.
        guard let possibles = possibilities(player) else { throw ValidationError.NoOptions }
        for (boundary, tiles) in possibles {
            print("Playable: \(String(tiles.mapFilter({$0.letter}))) -- \(boundary)")
        }
        if let (aiBoundary, aiTiles) = possibles.last {
            var aiTileIndex = 0
            for iterable in aiBoundary.start.iterable...aiBoundary.end.iterable {
                let position = Position(axis: aiBoundary.start.axis, iterable: iterable, fixed: aiBoundary.start.fixed)
                let square = squareAt(position)
                let tile = aiTiles[aiTileIndex]
                if tile.placement != .Fixed {
                    tile.placement = .Fixed
                    square?.tile = tile
                    neededTilePositions.append((square!, tile))
                }
                aiTileIndex++
            }
            print("Player tiles: \(player.rackTiles.mapFilter({$0.letter}))")
            print("Played: \(String(aiTiles.mapFilter({$0.letter})))")
            print("Boundary: \(aiBoundary)")
            do {
                try play(aiBoundary, submit: true)
            } catch {
                // Reverse changes...
                for (square, tile) in neededTilePositions {
                    square.tile = nil
                    tile.placement = .Rack
                }
                neededTilePositions.removeAll()
                print("Failed! \(error)")
            }
        }
    }
    
    /// - Parameter boundary: Boundary to check.
    /// - Parameter submit: Whether this move is final or just used for validation.
    /// - Throws: If boundary cannot be played you will receive a ValidationError.
    /// - Returns: Score of word including intersecting words.
    func play(boundary: Boundary, submit: Bool) throws -> Int {
        
        // Throw error if no player...
        guard let player = player else { throw ValidationError.NoPlayer }
        
        // If boundary validation fails, fail.
        if !boundary.isValid { throw ValidationError.InvalidArrangement }
        
        // If no words have been played, this boundary must intersect middle.
        let m = PapyrusMiddle - 1
        if playedBoundaries.count == 0 && (boundary.start.fixed != m ||
            boundary.start.iterable > m || boundary.end.iterable < m) {
                throw ValidationError.NoCenterIntersection
        }
        
        // If boundary contains squares that are empty, fail.
        let tiles = tilesIn(boundary)
        if tiles.count - 1 != boundary.length {
            throw ValidationError.UnfilledSquare(squaresIn(boundary))
        }
        
        // If no words have been played ensure that tile count is valid.
        if playedBoundaries.count == 0 && tiles.count < 2 {
            throw ValidationError.InsufficientTiles
        }
        
        // If all of these tiles are not owned by the current player, fail.
        if player.tiles.filter({tiles.contains($0)}).count == 0 {
            throw ValidationError.InsufficientTiles
        }
        
        // If words have been played, it must intersect one of these played words.
        // Assumption: Previous boundaries have passed validation.
        let intersections = walkBoundary(boundary)
        if playedBoundaries.count > 0 && intersections.count == 0 {
            throw ValidationError.NoIntersection
        }
        
        // Validate words, will throw if any are invalid...
        
        // Check if main word is valid.
        let mainWord = String(tiles.mapFilter({$0.letter}))
        print(mainWord)
        let _ = try Lexicon.sharedInstance.defined(mainWord)
        
        // Calculate score for main word.
        var value = score(boundary)
        print(value)
        
        // Filter unmodified words.
        // Get new intersections created by this play, we may have modified other words.
        let unmodified = intersections.filter({ !playedBoundaries.contains($0) })
        value += unmodified.map({ score($0) }).reduce(0, combine: +)
        
        // Check if intersecting words are valid.
        let words = unmodified.mapFilter({ readable($0) })
        for word in words {
            let _ = try Lexicon.sharedInstance.defined(word)
            print(word)
        }
        
        print("Score: \(value)")
        
        // If final, add boundaries to played boundaries.
        if submit {
            // Add boundaries to played boundaries
            var finalBoundaries = [boundary]
            finalBoundaries.extend(intersections)
            for finalBoundary in finalBoundaries {
                if playedBoundaries.filter({$0.start == finalBoundary.start && $0.end == finalBoundary.end}).count == 0 {
                   playedBoundaries.append(finalBoundary)
                }
            }
            // Change tiles to 'fixed'
            tiles.map({$0.placement = Placement.Fixed})
            // Increment score
            player.score += value
            
            // Draw new tiles. If count == 0 && rackCount == 0 complete game
            if replenishRack(player) == 0 && player.rackTiles.count == 0 {
                // Subtract remaining tiles in racks
                for player in players {
                    player.score = player.rackTiles.mapFilter({$0.value}).reduce(player.score, combine: -)
                }
                // Complete the game
                lifecycleCallback?(.Completed, self)
            }
        }
        return value
    }
}