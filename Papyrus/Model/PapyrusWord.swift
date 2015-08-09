//
//  PapyrusWord.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func ==(lhs: Word, rhs: Word) -> Bool {
    return lhs.tiles.filter({ rhs.tiles.contains($0) }).count == lhs.tiles.count
}

typealias Words = [Word]

/// A collection of tiles with some helpful methods for tile collections.
struct Word: Hashable, Equatable {
    /// Orientation that this word was played. Can only be one.
    let axis: Axis
    /// Offsets releveant to the squares for this word.
    let offsets: [Offset]
    /// Squares relevant to the tiles for this word.
    let squares: [Square]
    /// Word represented as tiles.
    let tiles: [Tile]
    /// Actual word represented as a string.
    let value: String
    /// Length of value.
    let length: Int
    /// Whether this word intersects the center square.
    let intersectsCenter: Bool
    private var _points: Int
    /// - Returns: Point value for the entire word.
    var points: Int {
        return immutable ? 0 : _points
    }
    /// - Returns: Bonus value if all tiles were played.
    var bonus: Int {
        return tiles.onBoard().count == PapyrusRackAmount ? 50 : 0
    }
    /// - Returns: Whether these tiles are fixed to the board.
    var immutable: Bool {
        return tiles.onBoardFixed().count == tiles.count
    }
    var hashValue: Int {
        var output = String()
        for square in tiles.mapFilter({ $0.square }) {
            if !output.isEmpty { output += "|" }
            output += "\(square.offset.x),\(square.offset.y)"
        }
        return output.hashValue
    }
    
    init(_ array: [(tile: Tile, square: Square)], axis: Axis) {
        tiles = array.map{ $0.tile }
        value = String(tiles.map{ $0.letter })
        length = value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        squares = array.mapFilter{ $0.square }
        offsets = squares.map{ $0.offset }
        self.axis = axis
        intersectsCenter = offsets.contains(PapyrusMiddleOffset!)
        var total = 0
        for (tile, square) in array {
            total += tile.letterValue(square)
        }
        for (tile, square) in array {
            total *= tile.wordMultiplier(square)
        }
        _points = total
    }
    
    /// Optionally creates a word with a tile array if it passes validation.
    init?(_ array: [Tile], validator: ValidationFunction) throws {
        tiles = array
        let cfg = try validator(tiles: &tiles)
        axis = cfg.axis
        value = String(tiles.map{ $0.letter })
        length = value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        squares = tiles.mapFilter{ $0.square }
        offsets = squares.map{ $0.offset }
        intersectsCenter = offsets.contains(PapyrusMiddleOffset!)
        var total: Int = tiles.map({ $0.letterValue }).reduce(0, combine: +)
        total = tiles.map({ $0.wordMultiplier }).reduce(total, combine: *)
        _points = total
    }
}

/// Orientation of offsets (x or y axis).
enum Axis {
    /// Offsets have same y value, but differing x values.
    case Horizontal
    /// Offsets have same x value, but differing y values.
    case Vertical
    /// - Returns: Array containing both orientations.
    static var both: [Axis] { return [.Horizontal, .Vertical] }
    /// - Returns: Opposite of current orientation.
    var invert: Axis { return self == .Horizontal ? .Vertical : .Horizontal }
}
