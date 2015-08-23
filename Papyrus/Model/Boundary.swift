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
    var length: Int {
        return end.iterable - start.iterable
    }
    var hashValue: Int {
        return debugDescription.hashValue
    }
    var debugDescription: String {
        return "\(start.axis): \(start.iterable),\(start.fixed) - \(end.iterable),\(end.fixed)"
    }
    /// - Returns: Whether this boundary appears to contain valid positions.
    var isValid: Bool {
        let valid = start.fixed == end.fixed &&
            start.iterable <= end.iterable &&
            start.isHorizontal == end.isHorizontal
        return valid
    }
    
    // TODO: Unit test this.
    /// - Returns: True if the axis and fixed values match and the iterable value intersects the given boundary.
    func iterableInsection(boundary: Boundary) -> Bool {
        // Check if same axis and same fixed value.
        if boundary.start.isHorizontal == start.isHorizontal &&
            boundary.start.fixed == start.fixed {
            // If they coexist on the same fixed line, check if there is any iterable intersection.
            return boundary.start.iterable < start.iterable && boundary.end.iterable >= end.iterable ||
                boundary.start.iterable <= start.iterable && boundary.end.iterable > end.iterable
        }
        return false
    }
    
    // TODO: Unit test this.
    /// - Returns: True if on adjacent fixed value and iterable seems to be in the same range.
    /// i.e. At least end position of the given boundary falls within the start-end range of this
    /// boundary. Or the start position of the given boundary falls within the start-end range
    /// of this boundary.
    func adjacentIntersection(boundary: Boundary) -> Bool {
        if boundary.start.isHorizontal == start.isHorizontal &&
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
    
    // TODO: Unit test this.
    /// - Returns: True if the axis is different but the fixed or iterable values intersect.
    func oppositeIntersection(boundary: Boundary) -> Bool {
        if boundary.start.isHorizontal != start.isHorizontal {
            // Check if fixed values match
            if boundary.start.fixed == start.fixed {
                return true
            }
            // Check if fixed value matches value in iteration.
            //if (boundary.start.iterable...boundary.end.iterable)
            //    .filter({ $0 == start.fixed }).count > 0 { return true }
            
            // Check if iteration value matches fixed value.
            //if (start.iterable...end.iterable)
            //    .filter({ $0 == boundary.start.fixed }).count > 0 { return true }
        }
        return false
    }
    
    // TODO: Unit test this.
    /// - Returns: Whether the given row and column fall within this boundary.
    func encompasses(row: Int, column: Int) -> Bool {
        if start.isHorizontal {
            let sameRow = row == start.fixed && row == end.fixed
            let validColumn = column >= start.iterable && column <= end.iterable
            return sameRow && validColumn
        } else {
            let sameColumn = column == start.fixed && column == end.fixed
            let validRow = row >= start.iterable && row <= end.iterable
            return sameColumn && validRow
        }
    }
}

extension Papyrus {
    
    ///  Get boundary of sprites we have played.
    ///  - returns: Boundary or nil.
    func getBoundary(positions: [Position]) -> Boundary? {
        print(positions)
        //if positions.count < 1 { throw ValidationError.InvalidArrangement }
        if positions.count == 1 {
            var newFirst = positions.first!.switchDirection(.Prev)
            newFirst = next(newFirst, last: newFirst)
            
            var newLast = positions.first!.switchDirection(.Next)
            newLast = next(newLast, last: newLast)
            
            let possibleBoundary = Boundary(start: newFirst, end: newLast)
            
            if newFirst.iterable != newLast.iterable {
                return possibleBoundary
            } else {
                // Try other axis...
                var otherAxisFirst = positions.first!.otherAxis(.Prev)
                otherAxisFirst = next(otherAxisFirst, last: otherAxisFirst)
                
                var otherAxisLast = positions.first!.otherAxis(.Next)
                otherAxisLast = next(otherAxisLast, last: otherAxisLast)
                
                if otherAxisLast.iterable != otherAxisLast.iterable {
                    return Boundary(start: otherAxisFirst, end: otherAxisLast)
                } else {
                    return possibleBoundary
                }
            }
        } else {
            if let first = positions.first, last = positions.last {
                var newFirst = first.switchDirection(.Prev)
                newFirst = next(newFirst, last: newFirst)
                var newLast = last.switchDirection(.Next)
                newLast = next(newLast, last: newLast)
                return Boundary(start: newFirst, end: newLast)
            }
        }
        return nil
    }
    
    ///  Helper method for walking the board.
    ///  - parameter current: Current position to check.
    ///  - parameter last:    Previous position to restore to if current fails.
    ///  - returns: Last position with a valid tile.
    func next(current: Position, last: Position) -> Position {
        if emptyAt(current) || current.isInvalid {
            return last
        } else {
            let new = current.newPosition()
            if current == new { return current }
            return next(new, last: current)
        }
    }
    
    /// - Parameter boundary: Boundary of tiles that have been dropped on the board.
    /// - Returns: Array of boundaries that intersect the supplied boundary.
    func walkBoundary(boundary: Boundary) -> [Boundary] {
        var boundaries = [Boundary]()
        let prevAxis = boundary.start.isHorizontal ? Axis.Vertical(.Prev) : Axis.Horizontal(.Prev)
        let nextAxis = boundary.start.isHorizontal ? Axis.Vertical(.Next) : Axis.Horizontal(.Next)
        for index in boundary.start.iterable...boundary.end.iterable {
            var first = Position(axis: prevAxis, iterable: boundary.start.fixed, fixed: index)
            var last = Position(axis: nextAxis, iterable: boundary.start.fixed, fixed: index)
            first = next(first, last: first)
            last = next(last, last: last)
            if first.iterable != last.iterable {
                boundaries.append(Boundary(start: first, end: last))
            }
        }
        print(boundaries)
        return boundaries
    }
    
    
    
    /// Calculate score for a given boundary.
    /// - Parameter boundary: The boundary you want the score of.
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
    /// - Parameter boundary: The boundary to get the letters for.
    func readable(boundary: Boundary) -> String? {
        let start = boundary.start, end = boundary.end
        if start.iterable >= end.iterable { return nil }
        return String((start.iterable...end.iterable).mapFilter({
            letterAt(start.isHorizontal, iterable: $0, fixed: start.fixed)}))
    }
    
    /// Create a boundary if positions are valid. Does not validate iterable values all exist.
    /// - Parameter positions: Array of positions to put a boundary around or nil.
    func boundary(forPositions positions: [Position]) -> Boundary? {
        if positions.count == 0 { return nil }
        let fixed = positions.sort({$0.fixed < $1.fixed})
        if fixed.first?.fixed == fixed.last?.fixed {
            let iterable = positions.sort({$0.iterable < $1.iterable})
            if let first = iterable.first, last = iterable.last {
                return Boundary(
                    start: first,
                    end: Position(
                        axis: last.isHorizontal ? Axis.Horizontal(.Next) : Axis.Vertical(.Next),
                        iterable: last.iterable,
                        fixed: last.fixed))
            }
        }
        return nil
    }
    
    /// This method will be used by AI to determine location where play is allowed.
    /// - Parameter boundaries: Boundaries to use for intersection.
    /// - Returns: Areas where play may be possible intersecting the given boundaries.
    func findPlayableBoundaries(boundaries: Boundaries) -> Boundaries {
        var allBoundaries = Set<Boundary>()
        for boundary in boundaries {
            assert(boundary.isValid)
            var currentBoundaries = Set<Boundary>()
            let startPosition = getPositionLoop(boundary.start)
            let endPosition = getPositionLoop(boundary.end)
            let start = boundary.start
            let end = boundary.end
            for i in startPosition.iterable...endPosition.iterable {
                // Restrict start index to include the entire word.
                let s = i > start.iterable ? start.iterable : i
                // Restrict end index to include the entire word.
                let e = i < end.iterable ? end.iterable : i
                // Skip same boundary as existing word.
                if s == start.iterable && e == end.iterable {
                    continue
                }
                // Create positions, if possible
                guard let
                    iterationStart = Position.newPosition(boundary.start.axis, iterable: s, fixed: start.fixed),
                    iterationEnd = Position.newPosition(boundary.end.axis, iterable: e, fixed: end.fixed) else {
                        print("A: Skipped \(i)")
                        continue
                }
                // Compare boundary before adding to array
                let boundary = Boundary(start: iterationStart, end: iterationEnd)
                currentBoundaries.insert(boundary)
                //print("Added same axis boundary: \(boundary)")
            }
            
            let inverseAxisStart = boundary.start.axis.inverse(.Prev)
            let inverseAxisEnd = boundary.end.axis.inverse(.Next)
            
            for i in boundary.start.iterable...boundary.end.iterable {
                // Attempt to create inverse positions.
                guard let startPosition = Position.newPosition(inverseAxisStart, iterable: start.fixed, fixed: i),
                    endPosition = Position.newPosition(inverseAxisEnd, iterable: end.fixed, fixed: i) else {
                        print("B: Skipped \(i)")
                        continue
                }
                // Iterate until we use all tiles or find an invalid position.
                let iterationStart = getPositionLoop(startPosition)
                let iterationEnd = getPositionLoop(endPosition)
                // Insert boundary
                let boundary = Boundary(start: iterationStart, end: iterationEnd)
                currentBoundaries.insert(boundary)
                //print("Added inverse axis boundary: \(boundary)")
            }
            allBoundaries.unionInPlace(currentBoundaries)
        }
        print("Boundaries: \(allBoundaries)")
        return Array(allBoundaries)
    }
}
