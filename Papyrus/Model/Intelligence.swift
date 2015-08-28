//
//  Intelligence.swift
//  Papyrus
//
//  Created by Chris Nevin on 17/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

typealias BoundaryTiles = (Boundary, [Tile])

extension Papyrus {

    func possibilities(player: Player) -> [BoundaryTiles]? {
        guard let source = Lexicon.sharedInstance.dictionary else { return nil }
        var boundaryTiles = [BoundaryTiles]()
        let rackTiles = player.rackTiles
        let letters = String(rackTiles.mapFilter({$0.letter}))
        let boundaries = findPlayableBoundaries(playedBoundaries)
        print(boundaries)
        print(letters)
        for boundary in boundaries {
            let squares = squaresIn(boundary)
            var index = 0
            let indexedCharacters = squares.map({ square -> (Int, Character?) in
                index++
                return (index - 1, square?.tile?.letter)
            }).filter({$0.1 != nil}).map({($0.0, $0.1!)})
            
            var results = [String]()
            
            // TODO: Fix this, it occassionally returns anomalies.
            // Optional(["C", "W", "T", "G", "E", "L", "T"])
            // Word played = AR
            // Word suggested to play: AROW - no O.
            // This is highly unreliable.
            Lexicon.sharedInstance.anagramsOf(letters, length: boundary.length + 1, prefix: "",
                fixedLetters: indexedCharacters, fixedCount: indexedCharacters.count,
                source: source, results: &results)
            print("Anagrams using: \(letters) with length: \(boundary.length)")
            
            print(indexedCharacters)
            print(results)
            if results.count > 0 {
                var invalid = false
                for result in results {
                    var tiles = [Tile]()
                    var index = 0
                    for char in result.characters {
                        // Check if we already have a tile at a given index
                        let tile = squares[index]?.tile ??
                            player.firstRackTile(withLetter: char) ??
                            player.firstRackTile(withLetter: "?")
                        // HACK:
                        if tile == nil {
                            invalid = true
                            print("Skipped invalid")
                            break
                        }
                        assert(tile != nil)
                        tiles.append(tile!)
                        index++
                    }
                    if !invalid {
                        boundaryTiles.append((boundary, tiles))
                    }
                }
            }
        }
        return boundaryTiles
    }
    
}