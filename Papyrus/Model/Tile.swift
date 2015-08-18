//
//  Tile.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func == (lhs: Tile, rhs: Tile) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

class Tile: CustomDebugStringConvertible, Equatable, Hashable {
    var letter: Character
    var placement: Placement
    let value: Int
    init(_ letter: Character, _ value: Int) {
        self.letter = letter
        self.value = value
        self.placement = .Bag
    }
    var debugDescription: String {
        return String(letter)
    }
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

extension Papyrus {
    static let TileConfiguration: [(Int, Int, Character)] = [(9, 1, "A"), (2, 3, "B"), (2, 3, "C"), (4, 2, "D"), (12, 1, "E"),
        (2, 4, "F"), (3, 2, "G"), (2, 4, "H"), (9, 1, "I"), (1, 8, "J"), (1, 5, "K"),
        (4, 1, "L"), (2, 3, "M"), (6, 1, "N"), (8, 1, "O"), (2, 3, "P"), (1, 10, "Q"),
        (6, 1, "R"), (4, 1, "S"), (6, 1, "T"), (4, 1, "U"), (2, 4, "V"), (2, 4, "W"),
        (2, 4, "Y"), (1, 10, "Z"), (2, 0, "?")]
    
    /// - Returns: Array of tiles created by iterating TileConfiguration.
    func createTiles() -> [Tile] {
        return Papyrus.TileConfiguration.flatMap { e in
            (0..<e.0).map({ _ in
                Tile(e.2, e.1)
            })
            }.sort({_, _ in arc4random() % 2 == 0})
    }
    
    /// Returns all tiles in the bag.
    var bagTiles: [Tile] {
        return tiles.filter({$0.placement == Placement.Bag})
    }
    
    /// - Parameter position: Position to check.
    /// - Returns: Whether there is a tile at a given position.
    func emptyAt(position: Position?) -> Bool {
        return squareAt(position)?.tile == nil
    }
    
    /// - Returns: Letter for a given position.
    func letterAt(position: Position) -> Character? {
        return squareAt(position)?.tile?.letter
    }
    
    /// - Returns: Letter for a given position.
    func letterAt(row: Int, _ col: Int) -> Character? {
        return squareAt(row, col)?.tile?.letter
    }
    
    /// - Returns: Letter at given iterable/fixed value for axis.
    func letterAt(horizontal: Bool, iterable: Int, fixed: Int) -> Character? {
        return squareAt(horizontal, iterable: iterable, fixed: fixed)?.tile?.letter
    }
    
    /// Returns all tiles in a given boundary.
    func tilesIn(boundary: Boundary) -> [Tile] {
        return squaresIn(boundary).mapFilter({$0?.tile})
    }
}