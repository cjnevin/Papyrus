//
//  Enums.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

enum Axis: CustomDebugStringConvertible {
    case Horizontal(Direction)
    case Vertical(Direction)
    func inverse(direction: Direction) -> Axis {
        switch self {
        case .Horizontal(_): return .Vertical(direction)
        case .Vertical(_): return .Horizontal(direction)
        }
    }
    var direction: Direction {
        switch self {
        case .Horizontal(let dir): return dir
        case .Vertical(let dir): return dir
        }
    }
    var debugDescription: String {
        switch self {
        case .Horizontal(let dir): return "H-\(dir)"
        case .Vertical(let dir): return "V-\(dir)"
        }
    }
}

enum Direction: CustomDebugStringConvertible {
    case Prev
    case Next
    var inverse: Direction {
        return self == .Prev ? .Next : .Prev
    }
    var debugDescription: String {
        return self == .Prev ? "Prev" : "Next"
    }
}

enum Placement {
    case Bag
    case Rack
    case Held
    case Board
    case Fixed
}

// TODO: Remove?
enum ValidationError: ErrorType {
    case InvalidArrangement
    case UnfilledSquare
    case InsufficientTiles
    case NoCenterIntersection
    case NoIntersection
    case UndefinedWord(String)
    case Message(String)
}