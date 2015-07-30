//
//  PapyrusPlayer.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

class Player: NSObject {
    typealias DrawFunction = (Int, Int, Player?, Tile.Placement, Tile.Placement) -> (Int)
    typealias CountFunction = (Tile.Placement, Player?) -> (Int)
    
    var score: Int = 0
    init(_ score: Int) {
        self.score = score
    }
    func count(f: CountFunction) -> Int {
        return f(.Rack, self)
    }
    func draw(start: Int, end: Int, f: DrawFunction) -> Int {
        return f(start, end, self, .Bag, .Rack)
    }
    func refill(start: Int, f: DrawFunction, countf: CountFunction) -> Int {
        return draw(start, end: PapyrusRackAmount - count(countf), f: f)
    }
}

extension Papyrus {
    func createPlayer() -> Player {
        let player = Player(0)
        tileIndex += player.refill(tileIndex, f: drawTiles, countf: tiles.placedCount)
        return player
    }
}