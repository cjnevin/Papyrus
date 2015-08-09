//
//  PapyrusProspect.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {

    typealias Prospect = (score: Int, word: Word, intersected: Words)
    typealias Prospects = [Prospect]
    
    func findProspect(withTiles userTiles: [Tile], prospect: (Prospect?) -> Void) {
        guard let dictionary = Lexicon.sharedInstance.dictionary else {
            prospect(nil)
            return
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
        // There's an issue with orientation here sometimes. 
        // Tiles are played vertically instead of horizontally.
        // Might be the 'runs' being returned.
        print("---")
        print("Calculating possibilities...")
        wordOperations.addOperationWithBlock() {
            let anagramFunc = Lexicon.sharedInstance.anagramsOf
            let letters = String(userTiles.mapFilter({ $0.letter }))
            var prospects = Prospects()
            for run in self.runs(withTiles: userTiles) {
                self.innerOperations.addOperationWithBlock() {
                    var anagramLetters = [(Int, Character)]()
                    var offsetIndex = 0
                    for (_, tile) in run {
                        if let char = tile?.letter {
                            anagramLetters.append((offsetIndex, char))
                        }
                        offsetIndex++
                    }
                    var results = Set<String>()
                    anagramFunc(letters, length: run.count, prefix: "",
                        fixedLetters: anagramLetters, source: dictionary, results: &results)
                    for result in results {
                        var remainingTiles = userTiles
                        var tileSquares = [(tile: Tile, square: Square)]()
                        var index = 0
                        for letter in result.characters {
                            let os = run[index].offset//Offset(x:run[index].offset.y, y:run[index].offset.x)
                            if let square = self.squares.filter({ $0.offset == os }).first {
                                if let tile = run[index].tile {
                                    // Insert this run item
                                    tileSquares.append((tile: tile, square: square))
                                    assert(tile.letter == letter)
                                } else if let tile = remainingTiles.filter({ $0.letter == letter }).first ?? remainingTiles.filter({ $0.letter == "?" }).first {
                                    // Insert one of the persons tiles
                                    remainingTiles = remainingTiles.filter{ $0 != tile }
                                    tileSquares.append((tile: tile, square: square))
                                    assert(tile.letter == letter || tile.letter == "?")
                                }
                            }
                            index++
                        }
                        assert(tileSquares.count == run.count)
                        
                        do {
                            let (orientation, _, _) = try self.tileOrientation(tileSquares.mapFilter({$0.tile}))
                            let word = Word(tileSquares, orientation: orientation)
                            let intersectedWords = try self.intersectingWords(word)
                            var allWords = intersectedWords
                            allWords.append(word)
                            let points = intersectedWords.reduce(0, combine: { (value, item) -> Int in
                                return value + item.points
                            })
                            prospects.append((points, word, intersectedWords))
                        } catch {
                        }
                    }
                }
            }
            while self.innerOperations.operationCount > 0 {
                
            }
            prospects.sortInPlace({ $0.0 > $1.0 })
            prospect(prospects.first)
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
    }
}