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
    func pickLetter(completion: (Character) -> ())
}

protocol GameSceneProtocol {
    func changedState(state: Papyrus.State)
    func submitPlay() throws
}

class GameScene: SKScene, GameSceneProtocol {
    /// - Returns: Current game object.
    private var game: Papyrus {
        return Papyrus.sharedInstance
    }
    /// - Returns: Currently dragged tile user is holding.
    var heldTile: TileSprite? {
        return tileSprites.filter({ Tile.match($0.tile.placement, unassociatedPlacement: .Held) }).first
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
    
    /// Attempt to submit a word, will throw an error if validation fails.
    func submitPlay() throws {
        // Reset position of any held tile (edge case).
        if let tile = heldTile, origin = heldOrigin {
            tile.resetPosition(origin)
        }
        do {
            if let tiles = try game.move(game.tiles.onBoard(game.player)) {
                completeMove(withTiles: tiles)
                //game.nextPlayer()
                
                squareSprites.map({$0.background.color = Papyrus.colorForSquare($0.square)})
                
                let r = game.axisRuns(game.tiles.inRack(game.player).count)
                for key in r.keys {
                    for (axis, offsets) in r[key]! {
                        let squares = game.squares.filter({ offsets.contains($0.offset) })
                        let spriteArr = sprites(squares)
                        spriteArr.map{ $0.background.color = UIColor.redColor() }
                    }
                }
                /*
                let r = game.runs(withTiles: game.tiles.inRack(game.player))
                
                for run in r {
                    for (offset, _) in run {
                        if let square = game.squares.filter({$0.offset == offset}).first,
                            squareSprite = sprites([square]).first {
                            squareSprite.background.color = UIColor.redColor()
                        }
                        
                    }
                }*/
                
                /*game.automateMove({ [weak self] (automatedTiles) -> Void in
                    if let automatedTiles = automatedTiles {
                        // TODO: Drop tiles on the board...
                        var index = 0
                        for tile in automatedTiles {
                            if let square = tile.square, emptySquare = self?.sprites([square]).first {
                                //dispatch_after(dispatch_time_t(1.0 * Double(index)), dispatch_get_main_queue(), { () -> Void in
                                    let sprite = TileSprite.sprite(withTile: tile)
                                    sprite.yScale = 0.5
                                    sprite.xScale = 0.5
                                    emptySquare.origin = emptySquare.position
                                    emptySquare.tileSprite = sprite
                                    emptySquare.addChild(sprite)
                                    emptySquare.animateDropTileSprite(sprite, originalPoint: emptySquare.position, completion: nil)
                                //})
                                index++
                            }
                        }
                        
                        self?.completeMove(withTiles: automatedTiles)
                        self?.game.nextPlayer()
                    } else {
                        assert(false)
                    }
                })*/
            }
        } catch let err as ValidationError {
            switch err {
            case .Center(let o, let w):
                squareSprites.filter{ $0.square.offset == o }
                    .map{ $0.warningGlow() }
                sprites(w.tiles).map{ $0.warningGlow() }
            case .Arrangement(let tiles):
                sprites(tiles).map{ $0.warningGlow() }
            case .Invalid(let w):
                sprites(w.tiles).map{ $0.warningGlow() }
            case .Intersection(let w):
                sprites(w.tiles).map{ $0.warningGlow() }
                tileSprites.filter{ Tile.match($0.tile.placement, unassociatedPlacement: .Fixed) }
                    .map{ $0.warningGlow() }
            case .Message(let s):
                throw ValidationError.Message(s)
            case .Undefined(let s):
                throw ValidationError.Message("Undefined word:\n\(s)")
            case .NoTiles:
                print("Silent failure")
            }
            throw err
        }
    }
    
    /// Handle game state changes.
    func changedState(state: Papyrus.State) {
        switch state {
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
        let rackSprites = tileSprites.filter{ game.tiles.inRack(game.player).contains($0.tile) }
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
}