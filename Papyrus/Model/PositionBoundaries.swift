//
//  PositionBoundaries.swift
//  Papyrus
//
//  Created by Chris Nevin on 16/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

typealias PositionBoundaries = [Position: Boundary]

extension Papyrus {
    /// Returns all 'readable' values for a given array of position boundaries.
    /// Essentially, all words.
    func readable(positionBoundaries: PositionBoundaries) -> [String] {
        var output = [String]()
        for (position, range) in positionBoundaries {
            if position != range.start || position != range.end {
                if let word = readable(range) {
                    output.append(word)
                }
            }
        }
        let sorted = positionBoundaries.keys.sort { (lhs, rhs) -> Bool in
            return lhs.iterable < rhs.iterable
        }
        if let first = sorted.first, last = sorted.last where first != last {
            if let word = readable(Boundary(start: first, end: last)) {
                output.append(word)
            }
        }
        return output
    }
    
    /// - Returns: Score for all boundaries.
    /// - Parameter positionBoundaries: Boundaries keyed by position.
    func score(positionBoundaries: PositionBoundaries) -> Int {
        return positionBoundaries.map({score($0.1)}).reduce(0, combine: +)
    }
    
    /// - Parameter position: Position to use.
    /// - Returns: Returns boundaries that intersect this position.
    func intersectingBoundaries(position: Position) -> PositionBoundaries {
        if position.isHorizontal {
            return intersectingBoundaries(true, row: position.fixed, col: position.iterable)
        } else {
            return intersectingBoundaries(false, row: position.iterable, col: position.fixed)
        }
    }
    
    /// Method used to determine intersecting words.
    /// - Parameters:
    ///     - horizontal: Whether to walk horizontally.
    ///     - row: Current row to walk.
    ///     - col: Current column to walk.
    /// - Returns: Boundaries keyed by position.
    func intersectingBoundaries(horizontal: Bool, row: Int, col: Int) -> PositionBoundaries {
        // Collect valid places to play
        var collected = PositionBoundaries()
        func collector(position: Position) {
            // Wrap collector when it needs to be moved, use another function to pass in an array
            if collected[position] == nil {
                let a = position.otherAxis(.Prev)
                let b = position.otherAxis(.Next)
                if let first = loop(a), last = loop(b) {
                    // Add/update boundary
                    collected[position] = Boundary(start: first, end: last)
                }
            }
        }
        
        // Find boundaries of this word
        if let a = Position.newPosition(.Prev, horizontal: horizontal, row: row, col: col),
            b = Position.newPosition(.Next, horizontal: horizontal, row: row, col: col),
            first = loop(a, fun: collector),
            last = loop(b, fun: collector) {
                // Print start and end of word
                print(first)
                print(last)
                // And any squares that are filled around this word (non-recursive)
                print(collected)
        }
        return collected
    }
}