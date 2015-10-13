//
//  GameScene.swift
//  Papyrus
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import SpriteKit
import SceneKit
import PapyrusCore

enum SceneError: ErrorType {
    case Thinking
    case NoBoundary
    case NoMoves
    case UnknownError
}

protocol GameSceneDelegate {
    func invalidMove(error: ErrorType?)
    func validMove(move: Move)
    func pickLetter(completion: (Character) -> ())
}

protocol GameSceneProtocol {
    func changed(lifecycle: Lifecycle)
    func submit(move: Move) throws
}

class GameScene: SKScene, GameSceneProtocol {
    /// - returns: Current game object.
    let game = Papyrus()
    
    /// - returns: Currently dragged tile user is holding.
    var heldTile: TileSprite? {
        return tileSprites.filter({ $0.tile.placement == Placement.Held }).first
    }
    /// Delegate for tile picking.
    var actionDelegate: GameSceneDelegate?
    /// - returns: All square sprites in play.
    lazy var squareSprites = [SquareSprite]()
    /// - returns: All tile sprites in play.
    lazy var tileSprites = [TileSprite]()
    
    static var operationQueue: NSOperationQueue {
        struct Static {
            static let instance = NSOperationQueue()
        }
        Static.instance.maxConcurrentOperationCount = 1
        return Static.instance
    }
    
    /// Illuminate sprites for tiles we just placed.
    /// - SeeAlso: `TileSprite.illuminate()`, `TileSprite.deilluminate()`
    private func highlight(move: Move) {
        // Light up the words we touched...
        let tiles = move.word.tiles + move.intersections.flatMap({$0.tiles})
        tileSprites.forEach{ $0.deilluminate() }
        tileSprites.filter{ tiles.contains($0.tile) }.forEach{ $0.illuminate() }
    }
    
    /// Handle changes in state of game.
    /// - parameter lifecycle: Current state.
    func changed(lifecycle: Lifecycle) {
        switch lifecycle {
        case .Cleanup:
            print("Cleanup")
            cleanupSprites()
            
        case .Preparing:
            print("Preparing")
            createSquareSprites()
            
        case .Ready:
            print("Ready")
            game.createPlayer()
            replaceRackSprites()
            game.createPlayer(.Newbie)
            game.createPlayer(.Average)
            game.createPlayer(.Champion)
            
        case .Completed:
            print("Completed")
            for player in game.players {
                print("- \(player.difficulty) score: \(player.score)")
            }
            print("Winning score: \(game.players.map({$0.score}).maxElement())")
        
        case .NoMoves:
            game.nextPlayer()
            
        case .ChangedPlayer:
            // Lock tiles...
            print("Changed player \(game.playerIndex)")
            let isHuman = game.player?.difficulty == .Human
            if !isHuman {
                attemptAIPlay({ (move, error) -> () in
                    print(move, error)
                })
            }
            
        case .EndedTurn:
            let isHuman = game.player?.difficulty == .Human
            if isHuman {
            // Replace rack sprites.
                replaceRackSprites()
            }
            // Change player
            game.nextPlayer()
        }
        
    }
    
    // MARK:- Helpers
    
    /// Create sprites representing squares in Papyrus game, only called once.
    private func createSquareSprites() {
        if squareSprites.count == 0 {
            squareSprites.appendContentsOf(Papyrus.createSquareSprites(forGame: game, frame: self.frame))
            squareSprites.filter{ $0.parent == nil }.forEach{ self.addChild($0) }
        }
    }
    
    /// Replace rack sprites with newly drawn tiles.
    private func replaceRackSprites() {
        // Remove existing rack sprites.
        let rackSprites = tileSprites.filter({ (game.player?.rackTiles.contains($0.tile)) == true })
        tileSprites = tileSprites.filter{ !rackSprites.contains($0) }
        rackSprites.forEach{ $0.removeFromParent() }
        // Create new rack sprites in new positions.
        let boardSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions) * CGFloat(PapyrusDimensions + 1)
        let newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - boardSize)
        tileSprites.appendContentsOf(Papyrus.createRackSprites(forGame: game, frame: newFrame))
        tileSprites.filter{ $0.parent == nil }.forEach{ self.addChild($0) }
    }
    
    /// Remove all tile sprites from game.
    private func cleanupSprites() {
        tileSprites.forEach{ $0.removeFromParent() }
        tileSprites.removeAll()
        squareSprites.forEach { $0.tileSprite = nil }
    }
    
    /// - returns: All sprites for squares contained in array.
    private func sprites(s: [Square]) -> [SquareSprite] {
        return squareSprites.filter{ s.contains($0.square) }
    }
    
    /// - returns: All sprites for tiles contained in array.
    private func sprites(t: [Tile]) -> [TileSprite] {
        return tileSprites.filter{ t.contains($0.tile) }
    }
    
}