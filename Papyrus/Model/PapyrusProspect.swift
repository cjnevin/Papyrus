//
//  PapyrusProspect.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    typealias Prospect = (score: Int, word: String)
    typealias Prospects = [Prospect]
    
    func possibilities(withTiles userTiles: [Tile]) -> Prospects {
        // Create every possible permutation of user's tiles.
        let perms = permutations(userTiles) // 5040 for 7 tiles.
        
        var possibilities = Prospects()
        for run in runs(withTiles: userTiles) {

            
            
            // Our iterate must include at least one of these tiles.
            // Therefore we need to iterate from current Offset until we hit one.
            // If multiple are hit before an empty square we must include them all.
            var filled = run.map{tile($0)}
            
            for offset in run {
                // For each occupied square, find all possible words using that tile
                // and the letters in hand.
            }
        }
        
        /*
        [[(2,8), (3,8), (4,8), (5,8), (6,8), (7,8), (8,8),
        (9,8), (10,8), (11,8), (12,8), (13,8), (14,8)],
        [(8,2), (8,3), (8,4), (8,5), (8,6), (8,7), (8,8),
        (8,9), (8,10), (8,11), (8,12), (8,13), (8,14)]]
        */
        
        // Collect runs, which tell us where our potential playable squares on the board exist
        // these squares may be occupied and allow us to append or prepend to existing words or
        // single letters.
        
        // Iterate from start of run to existing tile, to determine if we can prepend 7 tiles
        // then step 1 letter forward, seeing if we can prepend 6 tiles, etc,
        // then on the previous step, also select the tile after the existing tile
        // if it is already populated store this anagram then add 1 to the end
        // store this tile until we hit an empty square OR nil (edge of board).
        // Once we iterate far enough that we start at an existing tile with the previous
        // square empty (we should not crop tiles already played, rather we should include them).
        
        
        

        // Iterate each run
        // Detect existing tiles
        //
        
        // Determine potential words for each defined area on the board.
        
        // Finally, sort words using score potential.
        
        // AI difficulty can then be determined by average/min/max of score range.
        
        // Return sorted moves.
        return possibilities
    }
}