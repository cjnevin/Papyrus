//
//  GameScene.swift
//  Papyrus
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import SpriteKit
import SceneKit

protocol GameSceneDelegate {
    func boundariesChanged(boundary: Boundary?, error: ValidationError?, score: Int)
    func pickLetter(completion: (Character) -> ())
}

protocol GameSceneProtocol {
    func changed(lifecycle: Lifecycle)
    func submitPlay() throws
}

class GameScene: SKScene, GameSceneProtocol {
    /// - Returns: Current game object.
    internal var game: Papyrus {
        return Papyrus.sharedInstance
    }
    /// - Returns: Currently dragged tile user is holding.
    var heldTile: TileSprite? {
        return tileSprites.filter({ $0.tile.placement == Placement.Held }).first
    }
    /// Delegate for tile picking.
    var actionDelegate: GameSceneDelegate?
    /// - Returns: All square sprites in play.
    lazy var squareSprites = [SquareSprite]()
    /// - Returns: All tile sprites in play.
    lazy var tileSprites = [TileSprite]()
    
    /// Move and illuminate sprites for tiles we just placed.
    /// - SeeAlso: `replaceRackSprites()`, `TileSprite.illuminate()`, `TileSprite.deilluminate()`
    private func completeMove(withTiles moveTiles: [Tile]) {
        // Light up the words we touched...
        tileSprites.map{ $0.deilluminate() }
        tileSprites.filter{ moveTiles.contains($0.tile) }.map{ $0.illuminate() }
        // Remove existing rack sprites.
        if game.playerIndex == 0 {
            replaceRackSprites()
        }
    }
        
    ///  Handle changes in state of game.
    ///  - parameter lifecycle: Current state.
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
            replaceRackSprites()
            
        case .Completed:
            print("Completed")
        
        case .ChangedPlayer:
            // Lock tiles...
            print("Changed player")
            
        }
        
    }
    
    // MARK:- Helpers
    
    /// Create sprites representing squares in Papyrus game, only called once.
    private func createSquareSprites() {
        if squareSprites.count == 0 {
            squareSprites.extend(Papyrus.createSquareSprites(forGame: game, frame: self.frame))
            squareSprites.filter{ $0.parent == nil }.map{ self.addChild($0) }
        }
    }
    
    /// Replace rack sprites with newly drawn tiles.
    private func replaceRackSprites() {
        // Remove existing rack sprites.
        let rackSprites = tileSprites.filter({ (game.player?.rackTiles.contains($0.tile)) == true })
        tileSprites = tileSprites.filter{ !rackSprites.contains($0) }
        rackSprites.map{ $0.removeFromParent() }
        // Create new rack sprites in new positions.
        let boardSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions) * CGFloat(PapyrusDimensions + 1)
        let newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - boardSize)
        tileSprites.extend(Papyrus.createRackSprites(forGame: game, frame: newFrame))
        tileSprites.filter{ $0.parent == nil }.map{ self.addChild($0) }
    }
    
    /// Remove all tile sprites from game.
    private func cleanupSprites() {
        tileSprites.map{ $0.removeFromParent() }
        tileSprites.removeAll()
        squareSprites.map { $0.tileSprite = nil }
    }
    
    /// - Returns: All sprites for squares contained in array.
    private func sprites(s: [Square]) -> [SquareSprite] {
        return squareSprites.filter{ s.contains($0.square) }
    }
    
    /// - Returns: All sprites for tiles contained in array.
    private func sprites(t: [Tile]) -> [TileSprite] {
        return tileSprites.filter{ t.contains($0.tile) }
    }
    
    
    // MARK:- Checks
    
    ///  Get position array for sprites with axis.
    ///  - parameter horizontal: Axis to check.
    ///  - returns: Array of positions.
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
            for col in cols {
                positions.append(Position(axis: Axis.Horizontal(.Prev), iterable: col.col, fixed: col.row))
            }
        } else if let firstCol = cols.first?.col, lastCol = cols.last?.col where firstCol == lastCol {
            // Horizontal
            for row in rows {
                positions.append(Position(axis: Axis.Vertical(.Prev), iterable: row.row, fixed: row.col))
            }
        }
        return positions
    }
    
    /// Check to see if play is valid.
    func checkBoundary() {
        let positions = getPositions()
        if positions.count < 1 { print("insufficient tiles"); return }
        if positions.count == 1 { print("special logic"); return }
        if positions.count > 1 {
            if let boundary = game.getBoundary(positions) {
                do {
                    let score = try game.play(boundary, submit: false)
                    actionDelegate?.boundariesChanged(boundary, error: nil, score: score)
                } catch let err as ValidationError {
                    switch err {
                    case .InsufficientTiles: print("not enough tiles")
                    case .InvalidArrangement: print("invalid arrangement")
                    case .NoCenterIntersection: print("no center")
                    case .NoIntersection: print("no intersection")
                    case .UnfilledSquare: print("skipped square")
                    case .UndefinedWord(let word): print("undefined \(word)")
                    case .Message(let message): print(message)
                    default: break
                    }
                    actionDelegate?.boundariesChanged(boundary, error: err, score: 0)
                } catch _ {
                    actionDelegate?.boundariesChanged(boundary, error: nil, score: 0)
                }
            } else {
                print("No boundary")
                actionDelegate?.boundariesChanged(nil, error: ValidationError.NoBoundary, score: 0)
            }
        }
    }
    
    /// Attempt to submit a word, will throw an error if validation fails.
    func submitPlay() throws {
        if let tile = heldTile, origin = heldOrigin {
            tile.resetPosition(origin)
        }
        let positions = getPositions()
        if let boundary = game.getBoundary(positions) {
            let score = try game.play(boundary, submit: true)
            replaceRackSprites()
        }
    }
    
}