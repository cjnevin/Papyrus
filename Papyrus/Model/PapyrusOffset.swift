//
//  PapyrusOffset.swift
//  Papyrus
//
//  Created by Chris Nevin on 16/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func >(lhs: Offset, rhs: Offset) -> Bool {
    return lhs.x + lhs.y > rhs.x + rhs.y
}

func <(lhs: Offset, rhs: Offset) -> Bool {
    return lhs.x + lhs.y < rhs.x + rhs.y
}

func ==(lhs: Offset, rhs: Offset) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

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
    private static func valid(x: Int, y: Int) -> Bool {
        guard let _ = (x, y) <~> PapyrusDimensionsRange else { return false }
        return true
    }
    func at(x xx: Int, y yy: Int) -> Offset? {
        guard let n = (xx, yy) <~> PapyrusDimensionsRange else { return nil }
        return Offset(n)
    }
    func advance(o: Orientation, amount: Int) -> Offset? {
        return at(x: x + (o == .Horizontal ? amount : 0), y: y + (o == .Vertical ? amount: 0))
    }
    func next(o: Orientation) -> Offset? {
        return advance(o, amount: 1)
    }
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
