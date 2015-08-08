//
//  Papyrus.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

let PapyrusRackAmount: Int = 7
let PapyrusDimensions: Int = 15
let PapyrusDimensionsRange = (-1, PapyrusDimensions + 1)
let PapyrusMiddle: Int = PapyrusDimensions/2 + 1
let PapyrusMiddleOffset = Offset(x: PapyrusMiddle, y: PapyrusMiddle)

typealias PapyrusStateFunction = (Papyrus.State, Papyrus) -> ()

class Papyrus {
    enum State {
        case Cleanup
        case Preparing
        case Ready
        case Completed
    }
    
    static let sharedInstance = Papyrus()
    var inProgress: Bool = false
    let squares: [Square]
    let innerOperations = NSOperationQueue()
    let wordOperations = NSOperationQueue()
    
    lazy var words = Set<Word>()
    lazy var tiles = [Tile]()
    var tileIndex: Int = 0
    
    lazy var players = [Player]()
    var playerIndex: Int = 0
    var player: Player? {
        if players.count <= playerIndex { return nil }
        return players[playerIndex]
    }
    
    var changeFunction: PapyrusStateFunction?
    
    private init() {
        squares = Papyrus.createSquares()
        tiles = [Tile]()
    }
    
    func newGame(f: PapyrusStateFunction) {
        inProgress = true
        changeFunction?(.Cleanup, self)
        changeFunction = f
        changeFunction?(.Preparing, self)
        tiles.removeAll()
        words.removeAll()
        players.removeAll()
        tileIndex = 0
        playerIndex = 0
        tiles.extend(Papyrus.createTiles())
        changeFunction?(.Ready, self)
    }
}