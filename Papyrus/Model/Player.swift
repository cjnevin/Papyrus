//
//  Player.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

func == (lhs: Player, rhs: Player) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

/// An instance of a Player which has a score and can be assigned to tiles.
/// - SeeAlso: Papyrus.player is the current Player.
class Player: Equatable {
    /// Players current score.
    var score: Int = 0
    /// All tiles played by this player.
    lazy var tiles = Set<Tile>()
    /// Current rack tiles.
    var rackTiles: [Tile] {
        return tiles.filter({$0.placement == Placement.Rack})
    }
    /// Current play tiles, i.e. tiles on the board that haven't been submitted yet.
    var currentPlayTiles: [Tile] {
        return tiles.filter({$0.placement == Placement.Board})
    }
    /// Currently held tile, i.e. one being dragged around.
    var heldTile: Tile? {
        let held = tiles.filter({$0.placement == Placement.Held})
        assert(held.count < 2)
        return held.first
    }
    /// Method to return first rack tile with a given letter.
    func firstRackTile(withLetter letter: Character) -> Tile? {
        return rackTiles.filter({$0.letter == letter}).first
    }
    init(score: Int? = 0) {
        self.score = score!
    }
    
    func moveTile(tile: Tile, to: Placement) -> Bool {
        if tiles.contains(tile) {
            tile.placement = to
            if to == Placement.Bag {
                tiles.remove(tile)
                assert(tiles.contains(tile) == false)
            }
            return true
        }
        return false
    }
}

extension Papyrus {
    /// - returns: A new player with their rack pre-filled. Or an error if refill fails.
    func createPlayer() -> Player {
        let newPlayer = Player()
        tileIndex += replenishRack(newPlayer)
        players.append(newPlayer)
        return newPlayer
    }
    /// Advances to next player's turn.
    func nextPlayer() {
        playerIndex++
        if playerIndex >= players.count {
            playerIndex = 0
        }
        lifecycleCallback?(.ChangedPlayer, self)
    }
    /// Add tiles to a players rack from the bag.
    /// - returns: Number of tiles able to be drawn for a player.
    func replenishRack(player: Player) -> Int {
        let needed = PapyrusRackAmount - player.rackTiles.count
        var count = 0
        for i in tileIndex..<tiles.count where tiles[i].placement == .Bag && count < needed {
            tiles[i].placement = .Rack
            player.tiles.insert(tiles[i])
            count++
        }
        return count
    }
}