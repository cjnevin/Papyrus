//
//  Square.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func == (lhs: Square, rhs: Square) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

class Square: CustomDebugStringConvertible, Equatable {
    class func modifierOffsets() -> [Square.Modifier: [(Int, Int)]] {
        return [Square.Modifier.Letterx2: Square.Modifier.Letterx2.offsets(),
            Square.Modifier.Letterx3: Square.Modifier.Letterx3.offsets(),
            Square.Modifier.Center: Square.Modifier.Center.offsets(),
            Square.Modifier.Wordx2: Square.Modifier.Wordx2.offsets(),
            Square.Modifier.Wordx3: Square.Modifier.Wordx3.offsets()]
    }
    enum Modifier {
        case None, Letterx2, Letterx3, Center, Wordx2, Wordx3
        /// Returns all possible modifiers and offsets.
        func offsets() -> [(Int, Int)] {
            let m = 7   // Middle
            func symmetrical(arr: [(Int, Int)]) -> [(Int, Int)] {
                if arr.count == 0 { return arr }
                let symm = arr.map({ (x, y) in
                    [ (m-x, m-y), (m-x, m+y), (m+x, m+y), (m+x, m-y),
                        (m-y, m-x), (m-y, m+x), (m+y, m+x), (m+x, m-y) ]
                })
                return symm.flatMap({$0})
            }
            var buffer = [(Int, Int)]()
            switch self {
            case .Center: return [(0,0)]
            case .Wordx2: buffer = [(3, 3), (4, 4), (5, 5), (6, 6)]
            case .Wordx3: buffer = [(m-1, m-1), (0, m-1)]
            case .Letterx2: buffer = [(1, 1), (1, 5), (0, 4), (m-1, 4)]
            case .Letterx3: buffer = [(2, 6), (2, 2)]
            default: break
            }
            return symmetrical(buffer)
        }
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
    }
    let type: Modifier
    var tile: Tile?
    init(_ type: Modifier) {
        self.type = type
    }
    var debugDescription: String {
        return String(tile?.letter ?? "_")
    }
    /// - Returns: Square array.
    class func createSquares() -> [[Square]] {
        var squares = [[Square]]()
        let modified = Square.modifierOffsets()
        for row in 1...PapyrusDimensions {
            var line = [Square]()
            for col in 1...PapyrusDimensions {
                var mod: Square.Modifier
                for (modifier, offsets) in modified {
                    if offsets.filter({$0.0 == row && $0.1 == col}).count == 0 {
                        mod = modifier
                        break
                    }
                }
                mod = .None
                line.append(Square(mod))
            }
            squares.append(line)
        }
        return squares
    }
    /// - Returns: Letter multiplier for this tile.
    var letterValue: Int {
        guard let tile = tile else { return 0 }
        return (tile.placement == .Fixed ? 1 : type.letterMultiplier) * tile.value
    }
    /// - Returns: Word multiplier for this tile.
    var wordMultiplier: Int {
        guard let tile = tile else { return 0 }
        return (tile.placement == .Fixed ? 1 : type.wordMultiplier)
    }
}

extension Papyrus {
    
    /// - Parameter position: Position to check.
    /// - Returns: Whether there is a tile at a given position.
    func emptyAt(position: Position?) -> Bool {
        return squareAt(position)?.tile == nil
    }
    
    /// - Returns: Letter for a given position.
    func letterAt(position: Position) -> Character? {
        return squareAt(position)?.tile?.letter
    }
    
    /// - Returns: Letter at given iterable/fixed value for axis.
    func letterAt(horizontal: Bool, iterable: Int, fixed: Int) -> Character? {
        return squareAt(horizontal, iterable: iterable, fixed: fixed)?.tile?.letter
    }
    
    /// - Parameter position: Position to check.
    /// - Returns: Square at given position.
    func squareAt(position: Position?) -> Square? {
        guard let position = position else { return nil }
        if position.isHorizontal {
            return squareAt(position.fixed, position.iterable)
        } else {
            return squareAt(position.iterable, position.fixed)
        }
    }
    
    /// - Parameter row: Row to check.
    /// - Parameter col: Column to check.
    /// - Returns: Square at given row and column.
    private func squareAt(row: Int, _ col: Int) -> Square? {
        return squares[row][col]
    }
    
    /// - Returns: Square at given iterable/fixed value for axis.
    func squareAt(horizontal: Bool, iterable: Int, fixed: Int) -> Square? {
        if horizontal {
            return squareAt(fixed, iterable)
        } else {
            return squareAt(iterable, fixed)
        }
    }
    
    /// Returns all squares in a given boundary.
    func squaresIn(boundary: Boundary) -> [Square?] {
        if boundary.isValid {
            let start = boundary.start, end = boundary.end, horizontal = start.isHorizontal
            return (start.iterable...end.iterable).map({
                squareAt(horizontal, iterable: $0, fixed: start.fixed)
            })
        } else {
            return []
        }
    }
}

