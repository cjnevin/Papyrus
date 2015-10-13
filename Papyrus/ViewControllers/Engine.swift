//
//  Engine.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

enum EngineError: ErrorType {
    case NoMoves
    case UnknownError
}

protocol EngineDelegate {
    func lifecycleChanged(lifecycle: Lifecycle)
    
    func invalidBoundary()
    func invalidMove(error: ErrorType)
    func submittedMove(move: Move)
    func validMove(move: Move)
    func thinking()
}

typealias EngineCallback = (lifecycle: Lifecycle) -> Void

class Engine {
    let delegate: EngineDelegate
    var game: Papyrus!
    var unsubmittedMove: Move?
    
    init(delegate: EngineDelegate) {
        self.delegate = delegate
        self.game = Papyrus(callback: delegate.lifecycleChanged)
    }
    
    func newGame() {
        delegate.lifecycleChanged(.Preparing)
        if Papyrus.dawg == nil {
            Papyrus.operationQueue.addOperationWithBlock { () -> Void in
                Papyrus.dawg = Dawg.load(NSBundle.mainBundle().pathForResource("sowpods", ofType: "bin")!)!
                NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] () -> Void in
                    self?.game.newGame()
                })
            }
            return
        }
        game.newGame()
    }
}
