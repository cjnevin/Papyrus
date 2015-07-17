//
//  PapyrusValidation.swift
//  Papyrus
//
//  Created by Chris Nevin on 15/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

// TODO: Create orientation/offset tuple (Orientation, Offset) to cleanup func logic...

enum ValidationError: ErrorType {
    case Arrangement([Tile])
    case Center(Offset, Word)
    case Intersection(Word)
    case Invalid(Word)
    case Undefined(String)
    case Message(String)
    case NoTiles
}

typealias ValidationFunction = (inout tiles: [Tile]) throws -> (o: Orientation, range: (start: Offset, end: Offset))

extension Papyrus {
    private func addTiles(inout letters: Set<Tile>, o: Orientation, range: (Offset, Offset?), f:  Offset -> (o: Orientation) -> Offset?) -> Offset {
        var start = range.0
        while let n = f(start)(o: o) {
            guard let matched = tile(n) else { break }
            letters.insert(matched)
            start = n
            if let m = range.1 where m == n { break }
        }
        return start
    }
    
    private func addTiles(inout letters: Set<Tile>, o: Orientation, range: (Offset, Offset?), f:  [Offset -> (o: Orientation) -> Offset?]) -> [Offset] {
        return f.map({(self.addTiles(&letters, o: o, range: range, f: $0))})
    }
    
    private func prepareTiles(inout letters: [Tile]) throws -> (o: Orientation, range: (start: Offset, end: Offset)) {
        var sorted = sortTiles(letters)
        guard let first = sorted.first?.square?.offset, last = sorted.last?.square?.offset else {
            throw ValidationError.NoTiles
        }
        // For a single tile, lets make sure we have the right orientation
        // Otherwise, use orientation calculated above
        guard let o: Orientation = first == last ?
            (nil != tile(first.prev(.Horizontal)) ||
                nil != tile(first.next(.Horizontal))) ?
                .Horizontal : .Vertical : (first.x == last.x ?
                    .Vertical : first.y == last.y ?
                        .Horizontal : nil) else {
                            throw ValidationError.Arrangement(sorted)
        }
        // Go through tiles to see if there are any gaps
        var tileSet = Set(sorted)
        let offset = addTiles(&tileSet, o: o, range: (first, last), f: Offset.next)
        if offset < last { throw ValidationError.Arrangement(Array(tileSet)) }
        // Go in direction tiles were played to determine where word ends
        // Pad range with tiles played arround these `tiles`
        let range = (addTiles(&tileSet, o: o, range: (first, nil), f: Offset.prev),
                     addTiles(&tileSet, o: o, range: (last, nil), f: Offset.next))
        // Resort the tiles
        letters = sortTiles(Array(tileSet))
        // Ensure all tiles are on same line, cannot be in multiple directions
        if letters.filter({ o == .Horizontal ? $0.square!.offset.y == first.y : $0.square!.offset.x == first.x }).count != letters.count {
            throw ValidationError.Arrangement(letters)
        }
        return (o, range)
    }
    
    private func intersectingWords(word: Word) throws -> [Word] {
        var output = [Word]()
        let inverted = word.orientation.invert
        for tile in word.tiles {
            if let offset = tile.square?.offset {
                var tileSet = Set([tile])
                addTiles(&tileSet, o: inverted, range: (offset, nil), f: [Offset.prev, Offset.next])
                if tileSet.count > 1 {
                    do {
                        if let intersectingWord = try Word(Array(tileSet), f: prepareTiles) {
                            output.append(intersectingWord)
                        }
                    } catch let err {
                        throw err
                    }
                }
            }
        }
        return output
    }
    
    func move(letters: [Tile]) throws -> [Word] {
        var outWords = [Word]()
        do {
            if let word = try Word(letters, f: prepareTiles) {
                print("Main word: \(word.value)")
                let definition = try dictionary.defined(word.value)
                print("Definition: \(definition)")
                let intersectedWords = try intersectingWords(word)
                for intersectingWord in intersectedWords {
                    print("-- Intersecting word: \(intersectingWord.value)")
                    let definition = try dictionary.defined(intersectingWord.value)
                    print("-- Definition: \(definition)")
                }
                if words.count == 0 && !word.intersectsCenter {
                    throw ValidationError.Center(PapyrusMiddleOffset!, word)
                } else if words.count > 0 && intersectedWords.count == 0 && words.flatMap({$0.tiles}).filter({(word.tiles.contains($0))}).count == 0 {
                    throw ValidationError.Intersection(word)
                }
                // Prepare words to be returned, modified later
                outWords.extend(intersectedWords)
                outWords.append(word)
                // Calculate score for current move.
                // Filter out calculation for words with ALL fixed tiles.
                // If all tiles used add 50 to score.
                let sum = word.bonus + outWords.map({$0.points}).reduce(0, combine: +)
                // Make tile fixed, no one will be able to drag them from this point onward.
                // Assign `mutableWords` to `outWords` so we can return them.
                let mutableWords = outWords.filter{!$0.immutable}
                mutableWords.flatMap{$0.tiles}.map{$0.placement = .Fixed}
                outWords = mutableWords
                // Add words to played words.
                words.unionInPlace(outWords)
                // Add score to current player.
                player?.score += sum
                // Refill their rack.
                player?.refill(tileIndex, f: drawTiles, countf: countTiles)
                print("Sum: \(sum), new total: \(player!.score)")
                // If tiles.count == 0 current player won
                if tiles(withPlacement: .Rack, owner: player).count == 0 {
                    // Assumption, player won!
                    changedState(.Completed)
                    // Calculate all other players tiles to subtract
                    var index = 1;
                    for p in players {
                        let newScore = tiles(withPlacement: .Rack, owner: p).map({$0.value}).reduce(p.score, combine: -)
                        print("Player \(index)'s new score: \(newScore)")
                        p.score = newScore
                        index++
                    }
                }
            }
        }
        catch let err {
            throw err
        }
        return outWords
    }
}