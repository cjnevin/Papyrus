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
    let axis: Axis
    let iterable: Int
    let fixed: Int
    /// - Returns: Hash value, unique.
    var hashValue: Int {
        return "\(axis.debugDescription),\(iterable),\(fixed)".hashValue
    }
    /// - Returns: False if iterable or fixed falls outside of the board boundaries.
    var isInvalid: Bool {
        return outOfBounds(iterable) || outOfBounds(fixed)
    }
    /// - Returns: False if z is out of the board boundaries.
    private func outOfBounds(z: Int) -> Bool {
        return z < 0 || z >= PapyrusDimensions
    }
    /// - Returns: Value of next item in a given direction.
    private func adjust(z: Int, dir: Direction) -> Int {
        let n = dir == .Next ? z + 1 : z - 1
        return outOfBounds(n) ? z : n
    }
    /// - Returns: New position in direction defined by Axis.
    func newPosition() -> Position {
        return Position(axis: axis, iterable: adjust(iterable, dir: axis.direction), fixed: fixed)
    }
    /// - Returns: Position on alternate axis.
    func otherAxis(direction: Direction) -> Position {
        return Position(axis: axis.inverse(direction), iterable: iterable, fixed: fixed)
    }
    /// - Returns: Whether axis is 'Horizontal'.
    var isHorizontal: Bool {
        switch axis {
        case .Horizontal(_): return true
        case .Vertical(_): return false
        }
    }
}

// MARK:- Static Constructors
extension Position {
    static func newPosition(axis: Axis, iterable: Int, fixed: Int) -> Position? {
        let position = Position(axis: axis, iterable: iterable, fixed: fixed)
        if position.isInvalid { return nil }
        return position
    }
    static func newPosition(direction: Direction, horizontal: Bool, row: Int, col: Int) -> Position? {
        let iterable = horizontal ? col : row
        let fixed = horizontal ? row : col
        let axis = (horizontal ? Axis.Horizontal : Axis.Vertical)(direction)
        return newPosition(axis, iterable: iterable, fixed: fixed)
    }
}


extension Papyrus {
    /// - Parameter: Initial position to begin this loop, will call position's axis->direction to determine next position.
    /// - Returns: Furthest possible position from initial position using PapyrusRackAmount.
    func getPositionLoop(initial: Position) -> Position {
        var counter = PapyrusRackAmount
        func decrementer(position: Position) -> Bool {
            if emptyAt(position) { counter-- }
            return counter > -1
        }
        let position = loop(initial, validator: decrementer) ?? initial
        return position
    }
    
    /// Loop while we are fulfilling the validator.
    /// Caveat: first position must pass validation prior to being sent to this method.
    func loop(position: Position, validator: (position: Position) -> Bool, fun: ((position: Position) -> ())? = nil) -> Position? {
        // Return nil if square is outside of range (should only occur first time)
        if position.isInvalid { return nil }
        // Check new position.
        let newPosition = position.newPosition()
        let continued = validator(position: newPosition)
        if newPosition.isInvalid || !continued {
            fun?(position: position)
            return position
        } else {
            fun?(position: newPosition)
            return loop(newPosition, validator: validator, fun: fun) ?? newPosition
        }
    }
    
    /// Loop while we are fulfilling the empty value
    func loop(position: Position, empty: Bool? = false, fun: ((position: Position) -> ())? = nil) -> Position? {
        // Return nil if square is outside of range (should only occur first time)
        // Return nil if this square is empty (should only occur first time)
        if position.isInvalid || emptyAt(position) != empty! { return nil }
        // Check new position.
        let newPosition = position.newPosition()
        if newPosition.isInvalid || emptyAt(newPosition) != empty! {
            fun?(position: position)
            return position
        } else {
            fun?(position: newPosition)
            return loop(newPosition, empty: empty, fun: fun)
        }
    }
}