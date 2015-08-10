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
        //
        // TODO: If we encounter a word + 1 tile, we should attempt to play a word on the opposite axis.
        //
        //
        
        print("---")
        print("Calculating possibilities...")
        // There may be a problem with this algorithm, 
        // I've had an odd occassion where no play were available but there were some.
        // I guess we could skip or swap tiles? lol
        var prospects = Prospects()
        let anagramFunc = Lexicon.sharedInstance.anagramsOf
        let fixed = tiles.onBoardFixed()
        let rackTiles = tiles.inRack(player)
        let rackLetters = rackTiles.map({ $0.letter })
        let distance = rackTiles.count
        wordOperations.addOperationWithBlock() { [weak self] in
            guard let azr = self?.axisZRanges(distance) else { return }
            for item in azr {
                self?.innerOperations.addOperationWithBlock() {
                    let horiz = item.0 == .Horizontal
                    var previousRanges = [Range<Int>]()
                    for (z, range) in item.1 {
                        let iterativeRange = range.0...range.1
                        let rangeTiles = fixed.inRange(iterativeRange, z: z, axis: item.0)
                        for i in iterativeRange {
                            let end = i + distance > PapyrusDimensions ?
                                PapyrusDimensions : i + distance
                            for n in i..<end {
                                // Check if tiles exist in this range
                                var innerRange = i...n
                                // Check if all touching tiles exist in this range
                                //
                                // If not:
                                // - Iterate forward to see if we can have all touching tiles become part of this range
                                // - Ensure iterating backward includes all tiles also
                                // - Filter out existing ranges that had to do the same thing
                                // - go to next item?
                                //
                                // If so, add this range as a potential playable area.
                                var foundTiles = rangeTiles.inRange(innerRange, z: z, axis: item.0).sorted()
                                if foundTiles.count > 0 {
                                    // Check if tile is first offset in array.
                                    if let firstOffset = foundTiles.first?.square?.offset {
                                        // Do nothing, if tiles seem to all fall within the range we chose
                                        if (horiz ? firstOffset.x : firstOffset.y) <= i {
                                            // Loop upward (outside of range) until we find the first touching tile.
                                            func loopUpward(offset:Offset?) {
                                                if let offset = offset, upwardTile = rangeTiles.filter({ $0.square?.offset == offset }).first {
                                                    foundTiles.append(upwardTile)
                                                    innerRange.startIndex = horiz ? offset.x : offset.y
                                                    loopUpward(offset.prev(item.0))
                                                }
                                            }
                                            loopUpward(firstOffset.prev(item.0))
                                        }
                                    }
                                    if let lastOffset = foundTiles.last?.square?.offset {
                                        // Do nothing, if tiles seem to all fall within the range we chose
                                        if (horiz ? lastOffset.x : lastOffset.y) >= n {
                                            // Loop downward (outside of range) until we find the last touching tile.
                                            func loopDownward(offset:Offset?) {
                                                if let offset = offset, upwardTile = rangeTiles.filter({ $0.square?.offset == offset }).first {
                                                    foundTiles.append(upwardTile)
                                                    innerRange.endIndex = horiz ? offset.x : offset.y
                                                    loopDownward(offset.next(item.0))
                                                }
                                            }
                                            loopDownward(lastOffset.next(item.0))
                                        }
                                    }
                                }
                                // Check if we already tried this range previously
                                // can occur when word are outside of range.
                                // Ignore duplicate ranges...
                                if !previousRanges.contains(innerRange) {
                                    previousRanges.append(innerRange)
                                    foundTiles = foundTiles.sorted()
                                    if foundTiles.count > 0 {
                                        let fixedLetters = foundTiles.map({ tile -> (Int, Character) in
                                            ((horiz ? tile.square!.offset.x : tile.square!.offset.y) - i, tile.letter)
                                        })
                                        var results = [String]()
                                        anagramFunc(String(rackLetters), length: n-i, prefix: "",
                                            fixedLetters: fixedLetters, fixedCount: fixedLetters.count,
                                            source: dictionary, results: &results)
                                        if results.count > 0 {
                                            print("\(innerRange), \(foundTiles.map{$0.letter}) :: \(results)")
                                            
                                            // Replace tiles from our rack with the letters we tried to play.
                                            // Except from the tiles that are fixed.
                                            
                                            for result in results {
                                                var index = 0
                                                var resultTiles = [(tile: Tile, square: Square)]()
                                                let characters = result.characters
                                                for char in characters {
                                                    guard let tile = foundTiles.filter({ ((horiz ? $0.square!.offset.x : $0.square!.offset.y) - i) == index }).first ??
                                                        rackTiles.filter({ char == $0.letter }).first ??
                                                        rackTiles.filter({ "?" == $0.letter }).first,
                                                        offset = Offset(x: horiz ? index + i : z, y: horiz ? z : index + i),
                                                        square = tile.square ?? self?.squares.at(offset) else
                                                    {
                                                        assert(false)
                                                        return
                                                    }
                                                    resultTiles.append((tile, square))
                                                    index++
                                                }
                                                // TODO: Improve this.
                                                if resultTiles.filter({rackTiles.contains($0.tile)}).count > 0 {
                                                    let word = Word(resultTiles, axis: item.0)
                                                    if word.value.rangeOfString("?") == nil {
                                                        assert(word.value == result)
                                                    }
                                                    do {
                                                        if let intersectedWords = try self?.intersectingWords(word) {
                                                            var allWords = intersectedWords
                                                            allWords.append(word)
                                                            var points = allWords.reduce(0, combine: { (value, item) -> Int in
                                                                return value + item.points
                                                            })
                                                            if word.tiles.filter({rackTiles.contains($0)}).count == PapyrusRackAmount {
                                                                points += 50;
                                                            }
                                                            
                                                            // TODO: Add bonus
                                                            prospects.append((points, word, intersectedWords))
                                                        }
                                                    } catch {
                                                        print("Invalid word")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            while self?.innerOperations.operationCount > 0 {
                
            }
            //print("Prospects: \(prospects)")
            prospects.sortInPlace({ (lhs, rhs) -> Bool in
                lhs.0 > rhs.0
            })
            print("Best Prospect: \(prospects.first?.1.value)")
            
            // Return prospect on main thread.
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                prospect(prospects.first)
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