//
//  PapyrusTile.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

/// Check if identical.
func == (lhs: Tile.Placement, rhs: Tile.Placement) -> Bool {
    return Tile.match(lhs, placement: rhs)
}

/// An array of Tile objects.
typealias Tiles = [Tile]

/// Tile is represented as a letter and a value. Other information can be
/// derived by assigning different placements.
class Tile: NSObject, CustomDebugStringConvertible {
    
    /// Each of the potential errors that could occur during placement.
    enum PlacementError: ErrorType {
        case PlacementWithoutPlayerError
    }
    enum UnassociatedPlacement {
        case Bag
        case Rack
        case Held
        case Board
        case Fixed
    }
    enum PlayerPlacement {
        case Rack(Player)
        case Held(Player)
        case Board(Player)
        case Fixed(Player)
    }
    enum Placement: Equatable {
        case Bag
        case Rack(Player)
        case Held(Player)
        case Board(Player, Square)
        case Fixed(Player, Square)
    }
    /// - Returns: Owner if available.
    var owner: Player? {
        switch placement {
        case .Rack(let player):
            return player
        case .Held(let player):
            return player
        case .Board(let player, _):
            return player
        case .Fixed(let player, _):
            return player
        default:
            return nil
        }
    }
    /// - Returns: Current square or nil.
    var square: Square? {
        switch placement {
        case .Board(_, let square):
            return square
        case .Fixed(_, let square):
            return square
        default:
            return nil
        }
    }
    /// - Returns: True if placement == .Fixed
    var isFixed: Bool {
        switch placement {
        case .Fixed(_, _):
            return true
        default:
            return false
        }
    }
    /// Placement defines where the Tile exists in the game.
    var placement = Placement.Bag
    var letter: Character
    let value: Int
    /// - Returns: Letter multiplier for this tile, if placed on a specific square.
    func letterValue(square: Square) -> Int {
        return (isFixed ? 1 : square.modifier.letterMultiplier) * value
    }
    /// - Returns: Word multiplier for this tile, if placed on a specific square.
    func wordMultiplier(square: Square) -> Int {
        return (isFixed ? 1 : square.modifier.wordMultiplier)
    }
    /// - Returns: Letter multiplier for this tile, if it has a square defined
    /// and is not fixed.
    var letterValue: Int {
        guard let sq = square else { return 0 }
        return letterValue(sq)
    }
    /// - Returns: Word multiplier for this tile, if it has a square defined
    /// and is not fixed.
    var wordMultiplier: Int {
        guard let sq = square else { return 1 }
        return wordMultiplier(sq)
    }
    /// - Parameters:
    ///     - letter: Character to draw.
    ///     - value: Value to use in calculations.
    init(_ letter: Character, value: Int) {
        self.letter = letter
        self.value = value
    }
    override var debugDescription: String {
        return "\(letter)"
    }
}

extension Tile {
    /// Compare complete placement with placement ignoring player and square..
    class func match(p: Tile.Placement, unassociatedPlacement: Tile.UnassociatedPlacement) -> Bool {
        switch (p, unassociatedPlacement) {
        case (.Bag, .Bag): return true
        case (.Rack(_), .Rack): return true
        case (.Held(_), .Held): return true
        case (.Board(_,_), .Board): return true
        case (.Fixed(_,_), .Fixed): return true
        default: return false
        }
    }
    
    /// Compare complete placement with placement ignoring square requirement.
    class func match(p: Tile.Placement, playerPlacement: Tile.PlayerPlacement) -> Bool {
        switch (p, playerPlacement) {
        case (.Rack(let a), .Rack(let b)): return a == b
        case (.Held(let a), .Held(let b)): return a == b
        case (.Board(let apl, _), .Board(let bpl)): return apl == bpl
        case (.Fixed(let apl, _), .Fixed(let bpl)): return apl == bpl
        default: return false
        }
    }
    
    /// Compare complete placement with another placement.
    class func match(p: Tile.Placement, placement: Tile.Placement) -> Bool {
        switch (p, placement) {
        case (.Bag, .Bag): return true
        case (.Rack(let a), .Rack(let b)): return a == b
        case (.Held(let a), .Held(let b)): return a == b
        case (.Board(let apl, let asp), .Board(let bpl, let bsp)): return apl == bpl && asp == bsp
        case (.Fixed(let apl, let asp), .Fixed(let bpl, let bsp)): return apl == bpl && asp == bsp
        default: return false
        }
    }
}

extension Papyrus {
    static let TileConfiguration: [(Int, Int, Character)] = [(9, 1, "A"), (2, 3, "B"), (2, 3, "C"), (4, 2, "D"), (12, 1, "E"),
        (2, 4, "F"), (3, 2, "G"), (2, 4, "H"), (9, 1, "I"), (1, 8, "J"), (1, 5, "K"),
        (4, 1, "L"), (2, 3, "M"), (6, 1, "N"), (8, 1, "O"), (2, 3, "P"), (1, 10, "Q"),
        (6, 1, "R"), (4, 1, "S"), (6, 1, "T"), (4, 1, "U"), (2, 4, "V"), (2, 4, "W"),
        (2, 4, "Y"), (1, 10, "Z"), (2, 0, "?")]
    
    /// - Returns: Array of tiles created by iterating TileConfiguration.
    class func createTiles() -> [Tile] {
        return Papyrus.TileConfiguration.flatMap { e in
            (0..<e.0).map({ _ in
                Tile(e.2, value: e.1)
            })
        }.sort({_, _ in arc4random() % 2 == 0})
    }
}

extension CollectionType where Generator.Element == Tile {
    /// - Parameter offset: Accepts optional offset but will return nil.
    ///    Otherwise it will find the tile with a square at the given offset if one exists.
    /// - Returns: Tile at a given offset in this array.
    func at(offset: Offset?) -> Tile? {
        guard let offset = offset, matched = filter({ $0.square?.offset == offset }).first else { return nil }
        return matched
    }
    /// - Returns: True if tile exists at offset.
    func has(offset:Offset?) -> Bool {
        return at(offset) != nil
    }
    /// Returns tiles sorted by offset.
    func sorted() -> [Tile] {
        return filter{ $0.square != nil }.sort{ $0.square!.offset < $1.square!.offset }
    }
    /// - Returns: Array of tiles in the bag.
    func inBag() -> [Tile] {
        return filter({ $0.placement == Tile.Placement.Bag })
    }
    /// - Returns: Array of tiles optionally in a specific players rack.
    func inRack(player: Player? = nil) -> [Tile] {
        guard let player = player else {
            return filter({ Tile.match($0.placement, unassociatedPlacement: .Rack) })
        }
        return filter({ Tile.match($0.placement, placement: .Rack(player)) })
    }
    /// - Returns: Array of tiles on the board optionally owned by a specific players.
    func onBoard(player: Player? = nil) -> [Tile] {
        guard let player = player else {
            return filter({ Tile.match($0.placement, unassociatedPlacement: .Board) })
        }
        return filter({ Tile.match($0.placement, playerPlacement: .Board(player)) })
    }
    /// - Returns: Array of tiles on the board (and fixed) optionally owned by a specific players.
    func onBoardFixed(player: Player? = nil) -> [Tile] {
        guard let player = player else {
            return filter({ Tile.match($0.placement, unassociatedPlacement: .Fixed) })
        }
        return filter({ Tile.match($0.placement, playerPlacement: .Fixed(player)) })
    }
}