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
    func pickLetter(completion: (Character) -> ())    // FIXME: Character
}

class GameScene: SKScene {
    var actionDelegate: GameSceneProtocol?
    var game: Papyrus?
    lazy var tileSprites = [TileSprite]()
    lazy var squareSprites = [SquareSprite]()
    
    func submitPlay() throws {
        // Reset position of any held tile (edge case).
        if let tile = heldTile, origin = heldOrigin {
            tile.resetPosition(origin)
        }
        if let g = game, dropped = game?.droppedTiles, racked = game?.rackTiles {
            do {
                let moveWords = try g.move(dropped)
                // Light up the words we touched...
                let moveTiles = moveWords.flatMap({$0.tiles})
                let moveTileSprites = tileSprites.filter({moveTiles.contains($0.tile)})
                tileSprites.map({$0.deilluminate()})
                moveTileSprites.map({$0.illuminate()})
                // Fix all tiles that we dropped on the board.
                dropped.map({$0.placement = Tile.Placement.Fixed})
                // Remove existing rack sprites.
                let rackSprites = tileSprites.filter({racked.contains($0.tile)})
                tileSprites = tileSprites.filter({!rackSprites.contains($0)})
                rackSprites.map({$0.removeFromParent()})
                // Create new sprites in new positions.
                createTileSprites(g)
                print("Sprites: \(tileSprites.count)")
            } catch (let err) {
                throw err
            }
        }
    }
    
    func createTileSprites(g: Papyrus) {
        let boardSize = CGRectGetWidth(frame) / CGFloat(PapyrusDimensions) * CGFloat(PapyrusDimensions + 1)
        let newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - boardSize)
        tileSprites.extend(Papyrus.createRackSprites(forGame: g, frame: newFrame))
        tileSprites.filter({$0.parent == nil}).map({self.addChild($0)})
    }
    
    func resetGame() {
        // Clear state.
        self.squareSprites.map({$0.removeFromParent()})
        self.tileSprites.map({$0.removeFromParent()})
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
                self.squareSprites.filter({$0.parent == nil}).map({self.addChild($0)})
                createTileSprites(g)
            case .Completed:
                print("Completed")
            }
        }
    }
}