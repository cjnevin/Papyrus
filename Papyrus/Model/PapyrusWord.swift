//
//  PapyrusWord.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

enum Orientation {
    case Horizontal
    case Vertical
    static var both: [Orientation] { return [.Horizontal, .Vertical] }
    var invert: Orientation { return self == .Horizontal ? .Vertical : .Horizontal }
}

func ==(lhs: Word, rhs: Word) -> Bool {
    return lhs.tiles.filter({ rhs.tiles.contains($0) }).count == lhs.tiles.count
}

struct Word: Hashable, Equatable {
    let length: Int
    let orientation: Orientation
    let offsets: [Offset]
    let squares: [Square]
    let range: (start: Offset, end: Offset)
    let tiles: [Tile]
    let value: String
    let intersectsCenter: Bool
    private var _points: Int
    var points: Int {
        return immutable ? 0 : _points
    }
    var bonus: Int {
        return tiles.placedCount(.Board) == PapyrusRackAmount ? 50 : 0
    }
    var immutable: Bool {
        return tiles.placedCount(.Fixed) == tiles.count
    }
    var hashValue: Int {
        var output = String()
        for square in tiles.mapFilter({ $0.square }) {
            if !output.isEmpty { output += "|" }
            output += "\(square.offset.x),\(square.offset.y)"
        }
        return output.hashValue
    }
    init?(_ array: [Tile], f: ValidationFunction) throws {
        tiles = array
        let cfg = try f(tiles: &tiles)
        orientation = cfg.o
        range = cfg.range
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
