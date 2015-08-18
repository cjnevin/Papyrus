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
let PapyrusMiddle: Int = 8//PapyrusDimensions/2

typealias LifecycleCallback = (Lifecycle, Papyrus) -> ()

enum Lifecycle {
    case Cleanup
    case Preparing
    case Ready
    case ChangedPlayer
    case Completed
}

class Papyrus {
    static let sharedInstance = Papyrus()
    var lifecycleCallback: LifecycleCallback?
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
    
    private init() {
        squares = Square.createSquares()
    }
    
    ///  Create a new game.
    ///  - parameter callback: Callback which will be called throughout all stages of game lifecycle.
    func newGame(callback: LifecycleCallback) {
        inProgress = true
        lifecycleCallback?(.Cleanup, self)
        lifecycleCallback = callback
        lifecycleCallback?(.Preparing, self)
        playedBoundaries.removeAll()
        tiles.removeAll()
        players.removeAll()
        tileIndex = 0
        playerIndex = 0
        tiles.extend(createTiles())
        lifecycleCallback?(.Ready, self)
    }
}