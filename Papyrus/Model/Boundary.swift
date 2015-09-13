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
        return iterableRange.endIndex - iterableRange.startIndex
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
        guard let first = positions.first, last = positions.last else { return nil }
        self.start = first
        self.end = last
        if !isValid { return nil }
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
        // If different axis, swap
        if position.horizontal != horizontal {
            return contains(position.positionWithHorizontal(horizontal)!)
        }
        // If different fixed position it cannot be contained
        if position.fixed != start.fixed { return false }
        return iterableRange.contains(position.iterable)
    }
    
    /// - returns: True if boundary intersects another boundary on opposite axis.
    func intersects(boundary: Boundary) -> Bool {
        // Check if different axis
        if horizontal == boundary.start.horizontal { return false }
        // FIXME: Check if same fixed value ??
        if start.fixed != boundary.start.fixed { return false }
        // Check if iterable value intersects on either range
        return iterableRange.contains({boundary.iterableRange.contains($0)}) ||
            boundary.iterableRange.contains({iterableRange.contains($0)})
    }
    
    /// Currently unused.
    /// - returns: Boundary at previous fixed index or nil.
    func previous() -> Boundary? {
        return Boundary(start: start.positionWithFixed(start.fixed - 1),
            end: end.positionWithFixed(end.fixed - 1))
    }
    
    /// Currently unused.
    /// - returns: Boundary at next fixed index or nil.
    func next() -> Boundary? {
        return Boundary(start: start.positionWithFixed(start.fixed + 1),
            end: end.positionWithFixed(end.fixed + 1))
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
        if startIterable == start.iterable && endIterable == end.iterable { return self }
        return Boundary(
            start: start.positionWithMaxIterable(startIterable),
            end: end.positionWithMinIterable(endIterable))
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
        if startIterable == start.iterable && endIterable == end.iterable { return self }
        return Boundary(
            start: start.positionWithMinIterable(startIterable),
            end: end.positionWithMaxIterable(endIterable))
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
    /// - returns: Array of word boundaries that intersect the supplied boundary.
    func findIntersections(forBoundary boundary: Boundary) -> [Boundary] {
        return boundary.iterableRange.mapFilter { (index) -> (Boundary?) in
            // Flip fixed/iterable values, use index as fixed value.
            guard let invertedPosition = Position(horizontal: !boundary.horizontal, iterable: boundary.start.fixed, fixed: index),
                wordStart = previousWhileFilled(invertedPosition),
                wordEnd = nextWhileFilled(invertedPosition),
                wordBoundary = Boundary(start: wordStart, end: wordEnd) else { return nil }
            return wordBoundary
        }
    }
    
    /// Curried function for checking if an empty position is playable.
    /// We need to check previous item to see if it's empty otherwise
    /// next item must be empty (i.e. 2 squares must be free).
    private func validEmpty(position: Position,
        first: Position -> () -> Position?,
        second: Position -> () -> Position?) -> Bool {
        // Current position must be empty
        assert(emptyAt(position))
            // Check next index (or previous if at end) is empty
            if let startNext = first(position)() where emptyAt(startNext) {
                return true
            } else {
                // Check previous index (or next if at end) is empty or edge of board
                if let startPrevious = second(position)() {
                    return emptyAt(startPrevious)
                }
            }
            return true
    }
    
    /// - returns: Array of boundaries including this boundary which may be possible with the players tiles.
    func playableBoundaries(forBoundary boundary: Boundary) -> Set<Boundary>? {
        // Cannot return any plays if player has no tiles
        guard let rackCount = player?.rackTiles.count where rackCount > 0 else { return nil }
        // Ensure boundary is all tiles, no empty squares
        let boundaryTileCount = tilesIn(boundary).count
        assert(boundaryTileCount == boundary.length)
        
        // Bang everything, we want an assertion if anything fails (as it shouldn't)
        let minMaxBoundary = boundary.stretch(
            previousWhileTilesInRack(boundary.start)!,
            newEnd: nextWhileTilesInRack(boundary.end)!)!
        
        // Get maximum word size, then shift the iterable index
        var maxLength = boundary.length + rackCount
        
        // Adjust for existing tiles on the board
        maxLength += tilesIn(minMaxBoundary).count - boundaryTileCount
        
        // Get range of lengths (must add at least one tile)
        let lengthRange = boundary.length..<maxLength
        
        return Set(minMaxBoundary.iterableRange.flatMap({ (startIterable) -> ([Boundary?]) in
            lengthRange.map({ (length) -> (Boundary?) in
                let endIterable = startIterable + length
                
                guard let stretched = boundary.stretch(startIterable, endIterable: endIterable) else { return nil }
                
                // If we don't have enough tiles in our rack and on the board, this boundary is invalid
                if self.tilesIn(stretched).count + rackCount < stretched.length {
                    print("Not enough tiles \(stretched.length), \(self.tilesIn(stretched))")
                    return nil
                }
                
                // Validate start
                if self.emptyAt(stretched.start) {
                    if !self.validEmpty(stretched.start, first: Position.next, second: Position.previous) { return nil }
                } else {
                    // Must be filled, bang here so we get an assertion otherwise
                    let startFilled = self.previousWhileFilled(stretched.start)!
                    // Stretch to include found tiles
                    stretched.stretch(startFilled, newEnd: stretched.end)
                    // TODO: Might need to check the startFilled.iterable - 2 square is empty here
                }
                
                // Validate end
                if self.emptyAt(stretched.end) {
                    if !self.validEmpty(stretched.end, first: Position.previous, second: Position.next) { return nil }
                } else {
                    // Must be filled, bang here so we get an assertion otherwise
                    let endFilled = self.nextWhileFilled(stretched.end)!
                    // Stretch to include found tiles
                    stretched.stretch(stretched.start, newEnd: endFilled)
                    // TODO: Might need to check the endFilled.iterable + 2 square is empty here
                    
                }
                
                // Must be valid
                return stretched
            })
        }).mapFilter({$0}))
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
        return String(boundary.iterableRange.mapFilter({
            letterAt(Position(horizontal: boundary.start.horizontal, iterable: $0, fixed: boundary.start.fixed))}))
    }
    
    // TODO: Fix this method, some of these boundaries don't include complete words.
    // Not sure which axis is incorrect.
    /// This method will be used by AI to determine location where play is allowed.
    /// - parameter boundaries: Boundaries to use for intersection.
    /// - returns: Areas where play may be possible intersecting the given boundaries.
    func findPlayableBoundaries(boundaries: Boundaries) -> Boundaries {
        var allBoundaries = Set<Boundary>()
        for boundary in boundaries {
            if let boundaries = playableBoundaries(forBoundary: boundary) {
                allBoundaries.unionInPlace(boundaries)
            }
            // Iterate all positions on same axis, then flip to other axis and iterate until we find maximum play size.
            boundary.iterableRange.forEach({
                // Get positions for current square so we can iterate left/right.
                // Loop until we hit an empty square.
                if let wordBoundary =
                    Boundary(
                        start: previousWhileFilled(
                            Position(horizontal: !boundary.horizontal, iterable: boundary.start.fixed, fixed: $0)),
                        end: nextWhileFilled(
                            Position(horizontal: !boundary.horizontal, iterable: boundary.end.fixed, fixed: $0))),
                    invertedBoundaries = playableBoundaries(forBoundary: wordBoundary) {
                        allBoundaries.unionInPlace(invertedBoundaries)
                }
            })
        }
        //print("Boundaries: \(allBoundaries)")
        return Array(allBoundaries)
    }
}
