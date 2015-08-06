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
    typealias DrawFunction = (Int, Int, Player?, Tile.Placement, Tile.Placement) throws -> (Int)
    typealias CountFunction = (Tile.Placement, Player?) -> (Int)
    
    /// Players current score.
    var score: Int = 0
    init(score: Int? = 0) {
        self.score = score!
    }
    /// Count tiles in rack using the CountFunction.
    func count(f: CountFunction) -> Int {
        return f(.Rack, self)
    }
    /// Draw tiles using the DrawFunction.
    func draw(start: Int, end: Int, f: DrawFunction) throws -> Int {
        return try f(start, end, self, .Bag, .Rack)
    }
    /// Add tiles to this players rack using two external functions.
    func refill(start: Int, f: DrawFunction, countf: CountFunction) throws -> Int {
        return try draw(start, end: PapyrusRackAmount - count(countf), f: f)
    }
}

extension Papyrus {
    /// - Returns: A new player with their rack pre-filled. Or an error if refill fails.
    func createPlayer() throws -> Player {
        let newPlayer = Player()
        tileIndex += try newPlayer.refill(tileIndex, f: drawTiles, countf: tiles.placedCount)
        player = player ?? newPlayer
        return newPlayer
    }
}