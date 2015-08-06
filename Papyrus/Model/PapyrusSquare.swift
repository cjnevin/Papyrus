//
//  PapyrusSquare.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func ==(lhs: Square, rhs: Square) -> Bool {
    return lhs.offset == rhs.offset
}

struct Square: Equatable, Hashable {
    /// Type of square on the board
    enum Modifier {
        case None
        case Center
        case Letterx2
        case Letterx3
        case Wordx2
        case Wordx3
        /// - Returns: Word multiplier for this square.
        var wordMultiplier: Int {
            switch (self) {
            case .Center, .Wordx2: return 2
            case .Wordx3: return 3
            default: return 1
            }
        }
        /// - Returns: Letter multiplier for this square.
        var letterMultiplier: Int {
            switch (self) {
            case .Letterx2: return 2
            case .Letterx3: return 3
            default: return 1
            }
        }
        /// - Returns: Array of offsets for use in symmetricalOffsets method.
        private var offsets: [(Int, Int)] {
            let m = PapyrusMiddle
            switch (self) {
            case .Center: return [(0,0)]
            case .Wordx2: return [(3, 3), (4, 4), (5, 5), (6, 6)]
            case .Wordx3: return [(m-1, m-1), (0, m-1)]
            case .Letterx2: return [(1, 1), (1, 5), (0, 4), (m-1, 4)]
            case .Letterx3: return [(2, 6), (2, 2)]
            default: return []
            }
        }
        /// - Returns: Array of symmetrical offsets, used during board creation.
        var symmetricalOffsets: Offsets {
            return offsets.symmetrical()
        }
        /// - Returns: All types of squares.
        static var all: [Modifier] {
            return [.None, .Center, .Letterx2, .Letterx3, .Wordx2, .Wordx3]
        }
    }
    /// Type of square.
    let modifier: Modifier
    /// Where this offset appears on the board.
    let offset: Offset
    var hashValue: Int {
        return "\(offset.x),\(offset.y)".hashValue
    }
}

extension Papyrus {
    /// - Returns: Squares for board.
    class func createSquares() -> [Square] {
        let modifiers = Square.Modifier.all.map({ ($0, $0.symmetricalOffsets) })
        let range = (1...PapyrusDimensions)
        return range.map({ x in
            range.mapFilter({ Offset(x: x, y: $0) }).map({ offset in
                Square(
                    modifier: modifiers.filter({ $0.1.contains(offset) }).map({ $0.0 }).first ?? Square.Modifier.None,
                    offset: offset)
            })
        }).flatMap({ $0 })
    }
}

extension CollectionType where Generator.Element == Square {
    /// - Returns: Square at a particular offset.
    func at(offset: Offset) -> Square? {
        return filter{ $0.offset == offset }.first
    }
}