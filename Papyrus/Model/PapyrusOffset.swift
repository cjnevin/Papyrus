//
//  PapyrusOffset.swift
//  Papyrus
//
//  Created by Chris Nevin on 16/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func > (lhs: Offset, rhs: Offset) -> Bool {
    return lhs.x + lhs.y > rhs.x + rhs.y
}

func < (lhs: Offset, rhs: Offset) -> Bool {
    return lhs.x + lhs.y < rhs.x + rhs.y
}

func == (lhs: Offset, rhs: Offset) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

/// An x,y offset on the board, only valid if within board boundaries.
struct Offset: Comparable, Hashable, CustomDebugStringConvertible {
    let x: Int
    let y: Int
    init?(x: Int, y: Int) {
        if !Offset.valid(x, y: y) { return nil }
        self.x = x
        self.y = y
    }
    init?(_ tuple: (Int, Int)) {
        if !Offset.valid(tuple.0, y: tuple.1) { return nil }
        x = tuple.0
        y = tuple.1
    }
    /// False if offset falls outside of predefined board size
    private static func valid(x: Int, y: Int) -> Bool {
        guard let _ = (x, y) <~> PapyrusDimensionsRange else { return false }
        return true
    }
    /// Return offset for given x,y coordinates if valid
    /// - SeeAlso: valid(x:y:)
    static func at(x xx: Int, y yy: Int) -> Offset? {
        guard let n = (xx, yy) <~> PapyrusDimensionsRange else { return nil }
        return Offset(n)
    }
    /// Return offset for given x,y coordinates if valid
    /// - SeeAlso: valid(x:y:)
    func at(x xx: Int, y yy: Int) -> Offset? {
        return Offset.at(x: xx, y: yy)
    }
    /// Return new offset `amount` away from current offset in given direction or nil
    /// - SeeAlso: valid(x:y:)
    func advance(o: Orientation, amount: Int) -> Offset? {
        return o == .Horizontal ? at(x: x + amount, y: y) :
            at(x: x, y: y + amount)
    }
    /// Return next offset in given direction or nil
    /// - SeeAlso: valid(x:y:)
    func next(o: Orientation) -> Offset? {
        return advance(o, amount: 1)
    }
    /// Return previous offset in given direction or nil
    /// - SeeAlso: valid(x:y:)
    func prev(o: Orientation) -> Offset? {
        return advance(o, amount: -1)
    }
    var hashValue: Int {
        return debugDescription.hashValue
    }
    var debugDescription: String {
        return "(\(x),\(y))"
    }
}


extension CollectionType where Generator.Element == (Int, Int) {
    /// Convert tuple array to Offset array.
    func toOffsets() -> [Offset] {
        return mapFilter{ Offset(x: $0.0, y: $0.1) }
    }
    /// Convert tuple array to Offset array with symmetrical logic around PapyrusMiddle.
    func symmetrical() -> [Offset] {
        let m = PapyrusMiddle
        func s(offset: (Int, Int)) -> [Offset]? {
            let x = offset.0, y = offset.1
            return [ (m-x, m-y), (m-x, m+y), (m+x, m+y), (m+x, m-y),
                (m-y, m-x), (m-y, m+x), (m+y, m+x), (m+x, m-y) ]
                .toOffsets()
        }
        return flatMap{ s($0) }.flatMap{ $0 }
    }
}
