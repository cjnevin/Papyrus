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
        guard let dictionary = Lexicon.sharedInstance.dictionary else {
            return Prospects()
        }
        //
        // This is very slow, should switch to GADDAG or similar pattern to reduce
        // processing time. However, it should provide decent enough functionality
        // for playing an opponent for now (albeit a slow one).
        //
        // Another approach might be to create every permutation of tiles we may encounter.
        // Then filter by defined words.
        //
        // This approach has a side effect of shuffling the letters played on the board as well
        // which could be cleaned up with a 'fixed letters' parameter providing indexes.
        //
        let f = Lexicon.sharedInstance.anagramsOf
        let letters = String(userTiles.mapFilter({$0.letter}))
        print("---")
        print("Calculating possibilities...")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var allResults = [(Run, [String], [(Int, Character)])]()
            for run in self.runs(withTiles: userTiles) {
                if let o = self.orientation(ofOffsets: run.map({$0.0})) {
                    let anagramLetters = run.filter({$0.1 != nil}).map({ (offset, tile) -> (Int, Character) in
                        if o == .Horizontal {
                            return (offset.x, tile!.letter)
                        } else {
                            return (offset.y, tile!.letter)
                        }
                    })
                    var results = Set<String>()
                    f(letters, length: run.count, prefix: "", fixedLetters: anagramLetters, source: dictionary, results: &results)
                    if results.count > 0 {
                        allResults.append((run, Array(results), anagramLetters))
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                /*let bestResult: (Run, String)
                for (run, words, fixed) in allResults {
                    if let o = self.orientation(ofOffsets: run.map({$0.0})) {
                        let offsets = run.map({$0.0})
                        let squares = self.squares.filter({offsets.contains($0.offset)})
                        for word in words {
                            for i in 0..<word.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
                                if fixed.filter({$0.0 == i}).count > 0 {
                                    // Ignore calculation for this square
                                } else {
                                    if let square = squares.filter({$0.offset == offsets[i]}).first {
                                        square.modifier.letterMultiplier
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                }*/
                for result in allResults {
                    print(result)
                }
            }
        }
        
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