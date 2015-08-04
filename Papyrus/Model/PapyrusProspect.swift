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
        //let perms = permutations(userTiles) // 5040 for 7 tiles.
        
        // Collect every possible location to place tiles.
        //let t = NSDate().timeIntervalSinceReferenceDate
        
        //let r = runs(withTiles: userTiles)
        
        //print("Elapsed: \(NSDate().timeIntervalSinceReferenceDate - t)")
        
        // Determine potential words for each defined area on the board.
        //
        // Iterate through runs, inserting each possible permutation
        // check if word is defined. Check for perpendicular tiles, if there, 
        // check if each word exists on other axis.
        //
        // Perhaps need to check each tile placement to determine if words on the other axis are
        // valid before continuing with that permutation. Then filter permutations with letter at this
        // index if invalid. Create a grid of valid letters playable at index.
        // i.e. iterate letters (ensuring that letter is valid at each playable index of run, marking bad letters)
        //      filter permutations (or write new algorithm, to ignore these marked letters)
        
        //print("Permutations: \(perms.count)")
        
        
        
        //for run in r {
            // Filter permutations that are same length
            //for perm in perms.filter({$0.count == run.count}) {
            //
            //}
        //}
        
        
        // Finally, sort words using score potential.
        
        // AI difficulty can then be determined by average/min/max of score range.
        
        // Return sorted moves.
        let possibilities = Prospects()
        return possibilities
    }
}