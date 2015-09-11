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
    var isInvalid: Bool {
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
    /*func oppositeAxis() -> Position {
        return Position(ascending: ascending, horizontal: !horizontal, iterable: iterable, fixed: fixed)!
    }
    mutating func oppositeAxisInPlace() {
        self = oppositeAxis()
    }
    func oppositeDirection() -> Position {
        return Position(ascending: !ascending, horizontal: horizontal, iterable: iterable, fixed: fixed)!
    }
    mutating func oppositeDirectionInPlace() {
        self = oppositeDirection()
    }
    */
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
    func getPositionLoop(initial: Position) -> Position {
        var counter = player?.rackTiles.count ?? 0
        func decrementer(position: Position) -> Bool {
            if emptyAt(position) != false { counter-- }
            return counter > -1 && !position.isInvalid
        }
        let position = loop(initial, validator: decrementer) ?? initial
        return position
    }
    
    /// Loop while we are fulfilling the validator.
    /// Caveat: first position must pass validation prior to being sent to this method.
    func loop(position: Position, validator: (position: Position) -> Bool, fun: ((position: Position) -> ())? = nil) -> Position? {
        // Return nil if square is outside of range (should only occur first time)
        if position.isInvalid { return nil }
        // Get new position
        guard let newPosition = position.next() else { return position }
        // Check if it passes validation
        if validator(position: newPosition) {
            fun?(position: newPosition)
            return loop(newPosition, validator: validator, fun: fun) ?? nil
        } else {
            fun?(position: position)
            return position
        }
    }
    
    /// Loop while we are fulfilling the empty value
    func loop(position: Position, fun: ((position: Position) -> ())? = nil) -> Position? {
        // Return nil if square is outside of range (should only occur first time)
        // Return nil if this square is empty (should only occur first time)
        /*if position.isInvalid || emptyAt(position) == false { return nil }
        // Check new position.
        let newPosition = position.next()
        if newPosition == position { return position }
        if newPosition.isInvalid || emptyAt(newPosition) == false {
            fun?(position: position)
            return position
        } else {
            fun?(position: newPosition)
            return loop(newPosition, fun: fun)
        }*/
        return nil
    }
}