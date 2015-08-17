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
let PapyrusMiddle: Int = PapyrusDimensions/2 + 1

typealias PapyrusStateFunction = (Papyrus.State, Papyrus) -> ()

class Papyrus {
    enum State {
        case Cleanup
        case Preparing
        case Ready
        case ChangedPlayer
        case Completed
    }
    
    static let sharedInstance = Papyrus()
    var inProgress: Bool = false
    let squares: [[Square]]
    let innerOperations = NSOperationQueue()
    let wordOperations = NSOperationQueue()
    
    /// Array of positions of tiles we have dropped on the board.
    lazy var pendingPositions = [Position]()
    
    lazy var playedBoundaries = Boundaries()
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
        squares = Square.createSquares()
    }
    
    func newGame(f: PapyrusStateFunction) {
        inProgress = true
        changeFunction?(.Cleanup, self)
        changeFunction = f
        changeFunction?(.Preparing, self)
        playedBoundaries.removeAll()
        tiles.removeAll()
        players.removeAll()
        tileIndex = 0
        playerIndex = 0
        tiles.extend(createTiles())
        changeFunction?(.Ready, self)
    }
}