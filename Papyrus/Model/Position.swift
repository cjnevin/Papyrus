//
//  Position.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct Position: Equatable, Hashable {
    let ascending: Bool // -> if true, <- if false
    let horizontal: Bool
    let iterable: Int
    let fixed: Int
    
    init?(ascending: Bool, horizontal: Bool, iterable: Int, fixed: Int) {
        self.ascending = ascending
        self.horizontal = horizontal
        self.iterable = iterable
        self.fixed = fixed
        if isInvalid { return nil }
    }
    
    init?(ascending: Bool, horizontal: Bool, row: Int, col: Int) {
        self.ascending = ascending
        self.horizontal = horizontal
        self.iterable = horizontal ? col : row
        self.fixed = horizontal ? row : col
        if isInvalid { return nil }
    }
    
    /// - returns: Hash value, unique.
    var hashValue: Int {
        return "\(horizontal),\(ascending),\(iterable),\(fixed)".hashValue
    }
    /// - returns: False if iterable or fixed falls outside of the board boundaries.
    private var isInvalid: Bool {
        return isInvalid(iterable) || isInvalid(fixed)
    }
    /// - returns: False if z is out of the board boundaries.
    private func isInvalid(z: Int) -> Bool {
        return z < 0 || z >= PapyrusDimensions
    }
    /// - returns: Value of next item in a given direction. Enforces boundaries.
    private func adjust(z: Int) -> Int {
        let n = ascending ? z + 1 : z - 1
        return isInvalid(n) ? z : n
    }
    /// - returns: New position in direction defined by Axis. Boundaries are enforced.
    func next() -> Position? {
        let nextIterable = ascending ? iterable + 1 : iterable - 1
        if isInvalid(nextIterable) { return nil }
        return Position(ascending: ascending, horizontal: horizontal, iterable: nextIterable, fixed: fixed)
    }
    /// Mutates current item if possible.
    mutating func nextInPlace() {
        if let newPosition = next() {
            self = newPosition
        }
    }
    /// Mutates current item while it passes validation.
    mutating func nextInPlaceWhile(passing: (position: Position) -> Bool) {
        self = nextWhile(passing)
    }
    /// - returns: Next position while it passes validation otherwise last position.
    func nextWhile(passing: (position: Position) -> Bool) -> Position {
        if let position = next() where passing(position: position) {
            return position
        }
        return self
    }
    
    // MARK:
    func positionWithAscending(newValue: Bool) -> Position? {
        if newValue == ascending { return self }
        return Position(ascending: newValue, horizontal: horizontal, iterable: iterable, fixed: fixed)
    }
    func positionWithHorizontal(newValue: Bool) -> Position? {
        if newValue == horizontal { return self }
        return Position(ascending: ascending, horizontal: newValue, iterable: iterable, fixed: fixed)
    }
    func positionWithFixed(newValue: Int) -> Position? {
        if newValue == fixed { return self }
        return Position(ascending: ascending, horizontal: horizontal, iterable: iterable, fixed: newValue)
    }
    func positionWithIterable(newValue: Int) -> Position? {
        if newValue == iterable { return self }
        return Position(ascending: ascending, horizontal: horizontal, iterable: newValue, fixed: fixed)
    }
}

extension Papyrus {
    /// - Parameter: Initial position to begin this loop, will call position's axis->direction to determine next position.
    /// - returns: Furthest possible position from initial position using PapyrusRackAmount.
    func rackLoop(initial: Position) -> Position {
        var counter = player?.rackTiles.count ?? 0
        func decrementer(position: Position) -> Bool {
            if emptyAt(position) != false { counter-- }
            return counter > -1
        }
        return initial.nextWhile(decrementer)
    }
}