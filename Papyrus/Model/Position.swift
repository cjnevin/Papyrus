//
//  Position.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func == (lhs: Position, rhs: Position) -> Bool {
    // Match on same axis
    if lhs.horizontal == rhs.horizontal { return lhs.hashValue == rhs.hashValue }
    // Match on perpendicular axis (swap iterable/fixed)
    return lhs.fixed == rhs.iterable && lhs.iterable == rhs.fixed
}

struct Position: Equatable, Hashable {
    let horizontal: Bool
    let iterable: Int
    let fixed: Int
    
    init?(horizontal: Bool, iterable: Int, fixed: Int) {
        //self.ascending = ascending
        self.horizontal = horizontal
        self.iterable = iterable
        self.fixed = fixed
        if isInvalid { return nil }
    }
    
    init?(horizontal: Bool, row: Int, col: Int) {
        //self.ascending = ascending
        self.horizontal = horizontal
        self.iterable = horizontal ? col : row
        self.fixed = horizontal ? row : col
        if isInvalid { return nil }
    }
    
    /// - returns: Hash value, unique.
    var hashValue: Int {
        return "\(horizontal),\(iterable),\(fixed)".hashValue
    }
    /// - returns: False if iterable or fixed falls outside of the board boundaries.
    private var isInvalid: Bool {
        return isInvalid(iterable) || isInvalid(fixed)
    }
    /// - returns: False if z is out of the board boundaries.
    private func isInvalid(z: Int) -> Bool {
        return z < 0 || z >= PapyrusDimensions
    }
    
    // MARK: Next
    
    /// - returns: Next position or nil (boundaries are enforced).
    func next() -> Position? {
        return positionWithIterable(iterable + 1)
    }
    /// Mutates current item if possible.
    mutating func nextInPlace() {
        if let newPosition = next() {
            self = newPosition
        }
    }
    /// Mutates current item while it passes validation.
    mutating func nextInPlaceWhile(passing: (position: Position) -> Bool) {
        if let position = nextWhile(passing) {
            self = position
        }
    }
    /// - returns: Next position while it passes validation otherwise last position.
    func nextWhile(passing: (position: Position) -> Bool) -> Position? {
        if !passing(position: self) { return nil }
        if let position = next() where passing(position: position) {
            return position.nextWhile(passing)
        }
        return self
    }
    
    // MARK: Previous
    
    /// - returns: Previous position or nil (boundaries are enforced).
    func previous() -> Position? {
        return positionWithIterable(iterable - 1)
    }
    /// Mutates current item if possible.
    mutating func previousInPlace() {
        if let newPosition = previous() {
            self = newPosition
        }
    }
    /// Mutates current item while it passes validation.
    mutating func previousInPlaceWhile(passing: (position: Position) -> Bool) {
        if let position = previousWhile(passing) {
            self = position
        }
    }
    /// - returns: Previous position while it passes validation otherwise last position.
    func previousWhile(passing: (position: Position) -> Bool) -> Position? {
        if !passing(position: self) { return nil }
        if let position = previous() where passing(position: position) {
            return position.previousWhile(passing)
        }
        return self
    }
    
    
    // MARK: Adjustment
    
    /// Swap iterable and fixed when axis changes (row: 5, col: 2) == (col: 2, row: 5).
    func positionWithHorizontal(newValue: Bool) -> Position? {
        if newValue == horizontal { return self }
        return Position(horizontal: newValue, iterable: fixed, fixed: iterable)
    }
    func positionWithFixed(newValue: Int) -> Position? {
        if newValue == fixed { return self }
        if isInvalid(newValue) { return nil }
        return Position(horizontal: horizontal, iterable: iterable, fixed: newValue)
    }
    func positionWithIterable(newValue: Int) -> Position? {
        if newValue == iterable { return self }
        if isInvalid(newValue) { return nil }
        return Position(horizontal: horizontal, iterable: newValue, fixed: fixed)
    }
}

extension Papyrus {
    /// - Parameter: Initial position to begin this loop.
    /// - returns: Last position with a valid tile.
    func nextWhileEmpty(initial: Position?) -> Position? {
        return initial?.nextWhile { self.emptyAt($0) }
    }
    
    /// - Parameter: Initial position to begin this loop.
    /// - returns: Last position with an empty square.
    func nextWhileFilled(initial: Position?) -> Position? {
        return initial?.nextWhile { !self.emptyAt($0) }
    }

    /// - Parameter: Initial position to begin this loop.
    /// - returns: Furthest possible position from initial position using PapyrusRackAmount.
    func nextWhileTilesInRack(initial: Position) -> Position? {
        var counter = player?.rackTiles.count ?? 0
        func decrementer(position: Position) -> Bool {
            if emptyAt(position) { counter-- }
            return counter > -1
        }
        return initial.nextWhile(decrementer)
    }
    
    
    /// - Parameter: Initial position to begin this loop.
    /// - returns: Last position with a valid tile.
    func previousWhileEmpty(initial: Position?) -> Position? {
        return initial?.previousWhile { self.emptyAt($0) }
    }
    
    /// - Parameter: Initial position to begin this loop.
    /// - returns: Last position with an empty square.
    func previousWhileFilled(initial: Position?) -> Position? {
        return initial?.previousWhile { !self.emptyAt($0) }
    }
    
    /// - Parameter: Initial position to begin this loop.
    /// - returns: Furthest possible position from initial position using PapyrusRackAmount.
    func previousWhileTilesInRack(initial: Position) -> Position? {
        var counter = player?.rackTiles.count ?? 0
        func decrementer(position: Position) -> Bool {
            if emptyAt(position) { counter-- }
            return counter > -1
        }
        return initial.previousWhile(decrementer)
    }
}