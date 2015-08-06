//
//  PapyrusPlayer.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

/// An instance of a Player which has a score and can be assigned to tiles.
/// - SeeAlso: Papyrus.player is the current Player.
class Player: NSObject {
    /// Players current score.
    var score: Int = 0
    init(score: Int? = 0) {
        self.score = score!
    }
}

extension Papyrus {
    /// - Returns: A new player with their rack pre-filled. Or an error if refill fails.
    func createPlayer() -> Player {
        let newPlayer = Player()
        tileIndex += replenishRack(player: newPlayer)
        player = player ?? newPlayer
        return newPlayer
    }
    
    /// Add tiles to a players rack from the bag.
    /// - Returns: Number of tiles able to be drawn for a player.
    func replenishRack(player pl: Player) -> Int {
        let needed = PapyrusRackAmount - tiles.inRack(pl).count
        var count = 0
        for i in tileIndex..<tiles.count where tiles[i].placement == .Bag && count < needed {
            tiles[i].placement = .Rack(pl)
            count++
        }
        return count
    }
}