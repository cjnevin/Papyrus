//
//  GameScene.swift
//  Papyrus
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import SpriteKit
import SceneKit

protocol GameSceneProtocol {
    func pickLetter(completion: (Character) -> ())
}

class GameScene: SKScene {
    var actionDelegate: GameSceneProtocol?
    var game: Papyrus?
    lazy var squareSprites = [SquareSprite]()
    lazy var tileSprites = [TileSprite]()
    
    func sprites(s: [Square]) -> [SquareSprite] {
        return squareSprites.filter{ s.contains($0.square) }
    }
    
    func sprites(t: [Tile]) -> [TileSprite] {
        return tileSprites.filter{ t.contains($0.tile) }
    }
    
    func submitPlay() throws {
        // Reset position of any held tile (edge case).
        if let tile = heldTile, origin = heldOrigin {
            tile.resetPosition(origin)
        }
        if let g = game, dropped = game?.droppedTiles, racked = game?.rackTiles {
            do {
                let moveTiles = try g.move(dropped).flatMap{ $0.tiles }
                // Light up the words we touched...
                tileSprites.map{ $0.deilluminate() }
                tileSprites.filter{ moveTiles.contains($0.tile) }.map{ $0.illuminate() }
                // Remove existing rack sprites.
                let rackSprites = tileSprites.filter{ racked.contains($0.tile) }
                tileSprites = tileSprites.filter{ !rackSprites.contains($0) }
                rackSprites.map{ $0.removeFromParent() }
                // Create new sprites in new positions.
                createTileSprites(g)
                print("Sprites: \(tileSprites.count)")
            } catch let err as ValidationError {
                switch err {
                case .Center(let o, let w):
                    squareSprites.filter{ $0.square.offset == o }.map{ $0.warningGlow() }
                    sprites(w.tiles).map{ $0.warningGlow() }
                case .Arrangement(let tiles):
                    sprites(tiles).map{ $0.warningGlow() }
                case .Invalid(let w):
                    sprites(w.tiles).map{ $0.warningGlow() }
                case .Intersection(let w):
                    sprites(w.tiles).map{ $0.warningGlow() }
                    tileSprites.filter{ $0.tile.placement == Tile.Placement.Fixed }.map{ $0.warningGlow() }
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
    }
    
    func createTileSprites(g: Papyrus) {
        let boardSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions) * CGFloat(PapyrusDimensions + 1)
        let newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - boardSize)
        tileSprites.extend(Papyrus.createRackSprites(forGame: g, frame: newFrame))
        tileSprites.filter{ $0.parent == nil }.map{ self.addChild($0) }
    }
    
    func resetGame() {
        self.squareSprites.map{ $0.removeFromParent() }
        self.tileSprites.map{ $0.removeFromParent() }
        self.squareSprites.removeAll()
        self.tileSprites.removeAll()
    }
    
    func changedGameState(state: Papyrus.State, game: Papyrus?) {
        self.game = game
        if let g = self.game {
            switch state {
            case .Preparing:
                print("Preparing")
            case .Ready:
                print("Ready")
                self.squareSprites.extend(Papyrus.createSquareSprites(forGame: g, frame: self.frame))
                self.squareSprites.filter{ $0.parent == nil }.map{ self.addChild($0) }
                createTileSprites(g)
            case .Completed:
                print("Completed")
            }
        }
    }
}