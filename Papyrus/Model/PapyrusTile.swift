//
//  PapyrusTile.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension CollectionType where Generator.Element == Tile {
    func at(offset: Offset?) -> Tile? {
        guard let offset = offset, matched = filter({ $0.square?.offset == offset }).first else { return nil }
        return matched
    }
    func placedCount(placement: Tile.Placement, owner: Player? = nil) -> Int {
        return placed(placement, owner: owner).count
    }
    func placed(placement: Tile.Placement, owner: Player? = nil) -> [Tile] {
        return filter{ Tile.placed($0)(placement, owner: owner) != nil }
    }
    func place(newPlacement: Tile.Placement, owner: Player? = nil) throws {
        for tile in self {
            try tile.place(newPlacement, owner: owner)
        }
    }
    func sorted() -> [Tile] {
        return filter{ $0.square != nil }.sort{ $0.square!.offset < $1.square!.offset }
    }
}

class Tile: NSObject, CustomDebugStringConvertible {
    enum PlacementError: ErrorType {
        case PlacementWithoutPlayerError
        case PlaceInBagWithPlayerError
    }
    enum Placement {
        case Bag
        case Rack
        case Held
        case Board
        case Fixed
    }
    var owner: Player?
    var square: Square?
    var placement = Placement.Bag
    var letter: Character
    let value: Int
    var letterValue: Int {
        guard let sq = square else { return 0 }
        return (placement == .Fixed ? 1 : sq.modifier.letterMultiplier) * value
    }
    var wordMultiplier: Int {
        guard let sq = square else { return 1 }
        return (placement == .Fixed ? 1 : sq.modifier.wordMultiplier)
    }
    init(_ letter: Character, value: Int) {
        self.letter = letter
        self.value = value
    }
    func place(p: Placement, owner o: Player? = nil) throws {
        if p != .Bag && o == nil && owner == nil {
            throw PlacementError.PlacementWithoutPlayerError
        } else if p == .Bag && (o != nil) {
            throw PlacementError.PlaceInBagWithPlayerError
        }
        if o == nil && owner != nil && p != .Bag {
            // Don't update owner if nil but already previously set
        } else {
            self.owner = o
        }
        self.placement = p
    }
    func placed(p: Placement, owner o: Player?) -> Tile? {
        return (placement == p && ((o != nil && owner == o) || (o == nil))) ? self : nil
    }
    override var debugDescription: String {
        return "\(letter)"
    }
}

extension Papyrus {
    static let TileConfiguration: [(Int, Int, Character)] = [(9, 1, "A"), (2, 3, "B"), (2, 3, "C"), (4, 2, "D"), (12, 1, "E"),
        (2, 4, "F"), (3, 2, "G"), (2, 4, "H"), (9, 1, "I"), (1, 8, "J"), (1, 5, "K"),
        (4, 1, "L"), (2, 3, "M"), (6, 1, "N"), (8, 1, "O"), (2, 3, "P"), (1, 10, "Q"),
        (6, 1, "R"), (4, 1, "S"), (6, 1, "T"), (4, 1, "U"), (2, 4, "V"), (2, 4, "W"),
        (2, 4, "Y"), (1, 10, "Z"), (2, 0, "?")]
    
    class func createTiles() -> [Tile] {
        return Papyrus.TileConfiguration.flatMap { e in
            (0..<e.0).map({ _ in
                Tile(e.2, value: e.1)
            })
        }.sort({_, _ in arc4random() % 2 == 0})
    }
    
    func drawTiles(start: Int, end: Int, owner: Player?, from: Tile.Placement, to: Tile.Placement) throws -> Int {
        var count = 0
        for i in start..<tiles.count where tiles[i].placement == from && count < end {
            try tiles[i].place(to, owner: owner)
            count++
        }
        return count
    }
    
    var droppedTiles: [Tile] {
        return tiles.placed(.Board, owner: player)
    }
    
    var rackTiles: [Tile] {
        return tiles.placed(.Rack, owner: player)
    }
}