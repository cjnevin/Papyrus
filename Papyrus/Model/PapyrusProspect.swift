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
            
            var prospects = Prospects()
            
            let fixed = self.tiles.onBoardFixed()
            let rackTiles = self.tiles.inRack(self.player)
            let rackLetters = rackTiles.map({ $0.letter })
            let distance = rackTiles.count
            let azr = self.axisZRanges(distance)
            
            for item in azr {
                let horiz = item.0 == .Horizontal
                for (z, range) in item.1 {
                    // Step through range 1 item at a time
                    // Iterate from 1-distance
                    // Range must contain at least one tile
                    // Range must contain all touching tiles
                    
                    for i in range {
                        for n in i..<(i + distance) {
                            // Check if tiles exist in this range
                            let innerRange = i...n
                            // Check if all touching tiles exist in this range
                            //
                            // If not:
                            // - Iterate forward to see if we can have all touching tiles become part of this range
                            // - Ensure iterating backward includes all tiles also
                            // - Filter out existing ranges that had to do the same thing
                            // - go to next item?
                            //
                            // If so, add this range as a potential playable area.
                            let tiles = fixed.inRange(innerRange, z: z, axis: item.0).sorted()
                            
                            
                            
                            if tiles.count == 0 {
                                // Cannot play this move
                            } else {
                                // Find words that contain this tile
                                for tile in tiles {
                                    // Actually, offsets may be better...
                                    
                                    
                                    for word in tile.words where word.axis == item.0 {
                                        
                                    }
                                }
                                
                            }
                            
                            print("\(innerRange), \(tiles.map{$0.letter})")
                        }
                    }
                    
                    // We should actually check words here, instead of tiles.
                    // Then we can ensure that the full word is included in our tests.
                    // If the word is short it will be more likely to be possible to append to it.
                    /*
                    let fixedLetters = fixed.filter({ $0.square?.offset != nil })
                        .filter({ offsets.contains($0.square!.offset) })
                        .map({ tile in (offsets.indexOf(tile.square!.offset), tile.letter) })
                    */
                    /*
                    for x in range {
                        buffer = Run()
                        range.map{ y in checkOffset(Offset(x: x, y: y)) }
                    }
                    for y in range {
                        buffer = Run()
                        range.map{ x in checkOffset(Offset(x: x, y: y)) }
                    }
                    */
                    
                }
            }
        }
    }
}

            
            
            
            /*for run in self.runs(withTiles: userTiles) {
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
                            let (axis, _, _) = try self.tileAxis(tileSquares.mapFilter({$0.tile}))
                            let word = Word(tileSquares, axis: axis)
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
        }*/
        //}
        
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
    //}
//}