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
    
    
    // MARK:- Checks
    
    /// Get position array for sprites with axis.
    /// - parameter horizontal: Axis to check.
    /// - returns: Array of positions.
    func getPositions() -> [Position] {
        var offsets = [(row: Int, col: Int)]()
        for sprite in squareSprites where sprite.tileSprite != nil && sprite.tileSprite?.tile.placement != Placement.Fixed {
            offsets.append((sprite.square.row, sprite.square.column))
        }
        let rows = offsets.sort({$0.row < $1.row})
        let cols = offsets.sort({$0.col < $1.col})
        
        var positions = [Position]()
        if let firstRow = rows.first?.row, lastRow = rows.last?.row where firstRow == lastRow {
            // Horizontal
            positions.appendContentsOf(cols.mapFilter({Position(horizontal: true, iterable: $0.col, fixed: $0.row)}))
        } else if let firstCol = cols.first?.col, lastCol = cols.last?.col where firstCol == lastCol {
            // Vertical
            positions.appendContentsOf(cols.mapFilter({Position(horizontal: false, iterable: $0.row, fixed: $0.col)}))
        }
        return positions
    }
    
    func moveForPositions(positions: [Position]) throws -> Move? {
        guard let boundary = game.stretchWhileFilled(Boundary(positions: positions)) else {
            throw SceneError.NoBoundary
        }
        do {
            let move = try game.getMove(forBoundary: boundary)
            actionDelegate?.validMove(move)
            return move
        } catch let err as ValidationError {
            switch err {
            case .InsufficientTiles: print("not enough tiles")
            case .InvalidArrangement: print("invalid arrangement")
            case .NoCenterIntersection: print("no center")
            case .NoIntersection: print("no intersection")
            case .UnfilledSquare(_): print("skipped square")
            case .UndefinedWord(let word): print("undefined \(word)")
            case .Message(let message): print(message)
            default: break
            }
            throw err
        } catch _ {
            throw SceneError.UnknownError
        }
    }
    
    /// Check to see if play is valid.
    func validate() {
        actionDelegate?.invalidMove(SceneError.Thinking)
        let positions = self.getPositions()
        if positions.count < 1 { print("insufficient tiles"); return }
        if positions.count >= 1 {
            do {
                if let move = try self.moveForPositions(positions) {
                    self.actionDelegate?.validMove(move)
                }
            } catch {
                if positions.count > 1 {
                    self.actionDelegate?.invalidMove(error)
                } else {
                    // If single position, try other axis
                    let invertedPositions = positions.mapFilter({$0.positionWithHorizontal(!$0.horizontal)})
                    do {
                        if let move = try self.moveForPositions(invertedPositions) {
                            self.actionDelegate?.validMove(move)
                        }
                    } catch {
                        self.actionDelegate?.invalidMove(error)
                    }
                }
            }
        }
    }
    
    /// Attempt to submit a word, will throw an error if validation fails.
    func submit(move: Move) {
        if let tile = heldTile, origin = heldOrigin {
            tile.resetPosition(origin)
        }
        game.player?.submit(move)
        highlight(move)
        print("Points: \(move.total) total: \(game.player!.score)")
        game.draw(game.player!)
    }
    
    func attemptAIPlay(completion: (move: Move?, error: ErrorType?) -> ()) {
        GameScene.operationQueue.addOperationWithBlock { [weak self] () -> Void in
            guard let game = self?.game, player = game.player else { return }
            print("Rack: \(player.rackTiles)")
            var move: Move?
            var errorType: ErrorType?
            do {
                move = try game.getAIMoves().first
                if move == nil {
                    errorType = SceneError.NoMoves
                }
            } catch {
                errorType = error
            }
            NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] () -> Void in
                guard let move = move else {
                    completion(move: nil, error: errorType)
                    return
                }
                player.submit(move)
                print("AI Points: \(move.total) total: \(game.player!.score)")
                for i in 0..<move.word.length {
                    let square = move.word.squares[i]
                    let tile = move.word.tiles[i]
                    let tileSprite = TileSprite.sprite(withTile: tile)
                    self?.tileSprites.append(tileSprite)
                    let squareSprite = self?.squareSprites.filter({$0.square == square}).first
                    squareSprite?.placeTileSprite(tileSprite)
                }
                self?.highlight(move)
                game.draw(player)
                completion(move: move, error: errorType)
            })
        }
    }
}