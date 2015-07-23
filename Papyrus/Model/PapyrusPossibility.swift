//
//  PapyrusPossibility.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    typealias Possibility = (score: Int, word: String)
    typealias Possibilities = [Possibility]
    
    func possibilities(withTiles userTiles: [Tile]) -> Possibilities {
        var possibilities = Possibilities()
        for run in runs(withTiles: userTiles) {
            for offset in run {
                
            }
        }
        
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