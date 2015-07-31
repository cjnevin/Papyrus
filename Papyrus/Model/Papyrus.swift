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

class Papyrus {
    enum State {
        case Preparing
        case Ready
        case Completed
    }

    typealias StateChangedFunction = (State, Papyrus?) -> ()
    let fState: StateChangedFunction
    let squares: [[Square]]
    var tiles: [Tile]
    var tileIndex: Int = 0
    let dictionary: Dictionary
    lazy var words = Set<Word>()
    lazy var players = [Player]()
    var player: Player?
    
    private init(f: StateChangedFunction) {
        fState = f
        squares = Papyrus.createSquares()
        print(squares.count)
        
        tiles = Papyrus.createTiles()
        print(tiles.count)
        
        dictionary = Dictionary(.English)
        
        do {
            let p = try createPlayer()
            
            players.append(p)
            player = players.first
        } catch {
            
        }
        /*players.append(createPlayer())
        players.append(createPlayer())
        players.append(createPlayer())
        players.append(createPlayer())
        players.append(createPlayer())
        players.append(createPlayer())
        players.append(createPlayer())
        */
        changedState(.Ready)
        
        currentRuns()
    }
    
    func changedState(state: State) {
        // Papyrus is created on a background thread, we want to pass these events to the main thread.
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.fState(state, self)
        }
    }
}

extension Papyrus {
    class func newGame(f: StateChangedFunction) {
        f(.Preparing, nil)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            autoreleasepool {
                let _ = Papyrus(f: f)
            }
        }
    }
}