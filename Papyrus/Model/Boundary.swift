//
//  Boundary.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

typealias Boundaries = [Boundary]

func == (lhs: Boundary, rhs: Boundary) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct Boundary: CustomDebugStringConvertible, Equatable, Hashable {
    let start: Position
    let end: Position
    var horizontal: Bool {
        return start.horizontal
    }
    var length: Int {
        return end.iterable - start.iterable
    }
    var iterableRange: Range<Int> {
        return start.iterable...end.iterable
    }
    var hashValue: Int {
        return debugDescription.hashValue
    }
    var debugDescription: String {
        return "\(start.horizontal): \(start.iterable),\(start.fixed) - \(end.iterable),\(end.fixed)"
    }
    
    init?(start: Position?, end: Position?) {
        if start == nil || end == nil { return nil }
        self.start = start!
        self.end = end!
        if !isValid { return nil }
    }
    
    init?(positions: [Position]) {
        if let first = positions.first,
            last = positions.last,
            firstOtherAxis = first.positionWithHorizontal(!first.horizontal),
            lastOtherAxis = last.positionWithHorizontal(!last.horizontal)
        {
            if positions.count == 1 && firstOtherAxis.iterable != lastOtherAxis.iterable {
                self.start = firstOtherAxis
                self.end = lastOtherAxis
            } else {
                self.start = first
                self.end = last
            }
            if !isValid { return nil }
        }
        return nil
    }
    
    /// - returns: Whether this boundary appears to contain valid positions.
    private var isValid: Bool {
        let valid = start.fixed == end.fixed &&
            start.iterable <= end.iterable &&
            start.horizontal == end.horizontal
        return valid
    }
    
    /// - returns: True if the axis and fixed values match and the iterable value intersects the given boundary.
    func containedIn(boundary: Boundary) -> Bool {
        return boundary.contains(self)
    }
    
    /// - returns: True if the given boundary is contained in this boundary.
    func contains(boundary: Boundary) -> Bool {
        // Check if same axis and same fixed value.
        if boundary.horizontal == horizontal && boundary.start.fixed == start.fixed {
            // If they coexist on the same fixed line, check if there is any iterable intersection.
            return
                start.iterable <= boundary.start.iterable &&
                end.iterable >= boundary.end.iterable
        }
        return false
    }
    
    /// - returns: True if position is within this boundary's range.
    func contains(position: Position) -> Bool {
        // If different fixed position it cannot be contained
        if position.horizontal != horizontal { return false }
        if position.fixed != start.fixed { return false }
        return iterableRange.contains(position.iterable)
    }
    
    /// - returns: True if boundary intersects another boundary on opposite axis.
    func intersects(boundary: Boundary) -> Bool {
        // Check if different axis
        if horizontal == boundary.start.horizontal { return false }
        // Check if same fixed value
        if start.fixed != boundary.start.fixed { return false }
        // Check if iterable value intersects on either range
        return iterableRange.contains({boundary.iterableRange.contains($0)}) ||
            boundary.iterableRange.contains({iterableRange.contains($0)})
    }
    
    /// - returns: True if on adjacent fixed value and iterable seems to be in the same range.
    /// i.e. At least end position of the given boundary falls within the start-end range of this
    /// boundary. Or the start position of the given boundary falls within the start-end range
    /// of this boundary.
    func adjacentTo(boundary: Boundary) -> Bool {
        if boundary.start.horizontal == start.horizontal &&
            ((boundary.start.fixed + 1) == start.fixed ||
                (boundary.start.fixed - 1) == start.fixed) {
            return
                (boundary.start.iterable >= start.iterable &&
                    boundary.start.iterable <= end.iterable) ||
                (boundary.end.iterable > start.iterable &&
                    boundary.start.iterable <= start.iterable)
        }
        return false
    }
    
    // MARK: Shrink
    // These methods favour the lesser values of the two (min/max).
    
    /// - returns: New boundary encompassing the new start and end iterable values.
    func shrink(startIterable: Int, endIterable: Int) -> Boundary? {
        guard let s = start.positionWithIterable(max(start.iterable, startIterable)),
            e = end.positionWithIterable(min(end.iterable, endIterable)) else { return nil }
        return Boundary(start: s, end: e)
    }
    
    /// Shrinks the current Boundary to encompass the given start and end iterable values.
    mutating func shrinkInPlace(startIterable: Int, endIterable: Int) {
        if let newBoundary = shrink(startIterable, endIterable: endIterable) {
            self = newBoundary
        }
    }
    
    /// - returns: New boundary encompassing the new start and end positions.
    func shrink(newStart: Position, newEnd: Position) -> Boundary? {
        return shrink(newStart.iterable, endIterable: newEnd.iterable)
    }
    
    /// Shrinks the current Boundary to encompass the given start and end positions.
    mutating func shrinkInPlace(newStart: Position, newEnd: Position) {
        if let newBoundary = shrink(newStart, newEnd: newEnd) {
            self = newBoundary
        }
    }
    
    // MARK: Stretch
    // These methods favour the greater values of the two (min/max).
    
    /// - returns: New boundary encompassing the new start and end iterable values.
    func stretch(startIterable: Int, endIterable: Int) -> Boundary? {
        guard let s = start.positionWithIterable(min(start.iterable, startIterable)),
            e = end.positionWithIterable(max(end.iterable, endIterable)) else { return nil }
        return Boundary(start: s, end: e)
    }
    
    /// Stretches the current Boundary to encompass the given start and end iterable values.
    mutating func stretchInPlace(startIterable: Int, endIterable: Int) {
        if let newBoundary = stretch(startIterable, endIterable: endIterable) {
            self = newBoundary
        }
    }
    
    /// - returns: New boundary encompassing the new start and end positions.
    func stretch(newStart: Position, newEnd: Position) -> Boundary? {
        return stretch(newStart.iterable, endIterable: newEnd.iterable)
    }
    
    /// Stretches the current Boundary to encompass the given start and end positions.
    mutating func stretchInPlace(newStart: Position, newEnd: Position) {
        if let newBoundary = stretch(newStart, newEnd: newEnd) {
            self = newBoundary
        }
    }
}

extension Papyrus {
    
    /// - parameter boundary: Boundary containing tiles that have been dropped on the board.
    /// - returns: Array of boundaries that intersect the supplied boundary.
    func walkBoundary(boundary: Boundary) -> [Boundary] {
        var boundaries = [Boundary]()
        // Iterate each position in boundary
        for index in boundary.start.iterable...boundary.end.iterable {
            // Flip fixed/iterable values, use index as fixed value.
            if let
                first = previousWhileEmpty(Position(horizontal: !boundary.horizontal, iterable: boundary.start.fixed, fixed: index)),
                last = nextWhileEmpty(Position(horizontal: !boundary.horizontal, iterable: boundary.start.fixed, fixed: index)),
                invertedBoundary = Boundary(start: first, end: last) where first.iterable != last.iterable
            {
                boundaries.append(invertedBoundary)
            }
        }
        print(boundaries)
        return boundaries
    }
    
    /// Calculate score for a given boundary.
    /// - parameter boundary: The boundary you want the score of.
    func score(boundary: Boundary) -> Int {
        guard let player = player else { return 0 }
        let affectedSquares = squaresIn(boundary)
        var value = affectedSquares.mapFilter({$0?.letterValue}).reduce(0, combine: +)
        value = affectedSquares.mapFilter({$0?.wordMultiplier}).reduce(value, combine: *)
        if affectedSquares.mapFilter({ $0?.tile }).filter({player.tiles.contains($0)}).count == 7 {
            // Add bonus
            value += 50
        }
        return value
    }
    
    /// Get string value of letters in a given boundary.
    /// Does not currently check for gaps - use another method for gap checking and validation.
    /// - parameter boundary: The boundary to get the letters for.
    func readable(boundary: Boundary) -> String? {
        let start = boundary.start, end = boundary.end
        if start.iterable >= end.iterable { return nil }
        return String((start.iterable...end.iterable).mapFilter({
            letterAt(Position(horizontal: start.horizontal, iterable: $0, fixed: start.fixed))}))
    }
    
    /// Find all possible boundaries for a words boundary.
    private func findSameAxisPlaysForBoundary(boundary: Boundary) -> Set<Boundary> {
        var currentBoundaries = Set<Boundary>()
        let start = boundary.start, end = boundary.end
        // Find first and last possible position using rack tiles, skipping filled squares.
        // This should be refactored, so that if we hit two empty squares we know we can play a move, if we just hit one and
        // the following square is filled we need to backout.
        guard let
            startPosition = previousWhileTilesInRack(boundary.start),
            endPosition = nextWhileTilesInRack(boundary.end) else {
            return currentBoundaries
        }
        for i in startPosition.iterable...endPosition.iterable {
            // Restrict start index to include the entire word.
            let s = i >= start.iterable ? start.iterable : i
            // Restrict end index to include the entire word.
            let e = i <= end.iterable ? end.iterable : i
            // Ensure previous index is empty
            if let startMinusOne = start.positionWithIterable(s - 1)
                where !emptyAt(startMinusOne) { continue }
            // Ensure next index is empty
            if let endPlusOne = end.positionWithIterable(e + 1)
                where !emptyAt(endPlusOne) { continue }
            
            // Skip same boundary as existing word.
            if s == start.iterable && e == end.iterable {
                continue
            }
            // Create positions, if possible
            if let newStart = start.positionWithIterable(s),
                newEnd = end.positionWithIterable(e),
                newBoundary = Boundary(start: newStart, end: newEnd)
            {
                assert(newStart.iterable <= start.iterable, "Start is invalid")
                assert(newEnd.iterable >= end.iterable, "End is invalid")
                currentBoundaries.insert(newBoundary)
            }
        }
        return currentBoundaries
    }
    
    // TODO: Fix this method, some of these boundaries don't include complete words.
    // Not sure which axis is incorrect.
    /// This method will be used by AI to determine location where play is allowed.
    /// - parameter boundaries: Boundaries to use for intersection.
    /// - returns: Areas where play may be possible intersecting the given boundaries.
    func findPlayableBoundaries(boundaries: Boundaries) -> Boundaries {
        var allBoundaries = Set<Boundary>()
        for boundary in boundaries {
            
            allBoundaries.unionInPlace(findSameAxisPlaysForBoundary(boundary))
            
            // Iterate length of word on other axis, collecting perpendicular tiles
            let horizontal = !boundary.horizontal
            
            // Iterate all positions on same axis, then flip to other axis and iterate until we find maximum play size.
            for i in boundary.start.iterable...boundary.end.iterable {
                // Get positions for current square so we can iterate left/right.
                // Loop until we hit an empty square.
                guard let wordStart = previousWhileFilled(Position(horizontal: horizontal, iterable: boundary.start.fixed, fixed:i)),
                    wordEnd = nextWhileFilled(Position(horizontal: horizontal, iterable: boundary.end.fixed, fixed: i)),
                    newBoundary = Boundary(start: wordStart, end: wordEnd) else
                {
                    print("Skipped!")
                    continue
                }
                allBoundaries.unionInPlace(findSameAxisPlaysForBoundary(newBoundary))
            }
        }
        print("Boundaries: \(allBoundaries)")
        return Array(allBoundaries)
    }
}
