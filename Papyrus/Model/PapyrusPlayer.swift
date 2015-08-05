//
//  PapyrusPlayer.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

class Player: NSObject {
    typealias DrawFunction = (Int, Int, Player?, Tile.Placement, Tile.Placement) throws -> (Int)
    typealias CountFunction = (Tile.Placement, Player?) -> (Int)
    
    var score: Int = 0
    init(score: Int? = 0) {
        self.score = score!
    }
    func count(f: CountFunction) -> Int {
        return f(.Rack, self)
    }
    func draw(start: Int, end: Int, f: DrawFunction) throws -> Int {
        return try f(start, end, self, .Bag, .Rack)
    }
    func refill(start: Int, f: DrawFunction, countf: CountFunction) throws -> Int {
        return try draw(start, end: PapyrusRackAmount - count(countf), f: f)
    }
}

extension Papyrus {
    func createPlayer() throws -> Player {
        let newPlayer = Player()
        tileIndex += try newPlayer.refill(tileIndex, f: drawTiles, countf: tiles.placedCount)
        player = player ?? newPlayer
        return newPlayer
    }
}