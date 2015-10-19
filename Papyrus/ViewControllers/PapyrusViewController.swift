//
//  PapyrusViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import SpriteKit
import PapyrusCore

class PapyrusViewController: UIViewController, DragDelegate {
    
    @IBOutlet var boardView: BoardView!
    @IBOutlet var skView: SKView!
    
    /// - returns: All tile sprites in play.
    lazy var tileSprites = [TileSprite]()
    
    var scene: TileScene!
    let watchdog = Watchdog(threshold: 0.2)
    var submit: UIBarButtonItem?
    var shuffle: UIBarButtonItem?
    var swap: UIBarButtonItem?
    var restart: UIBarButtonItem?
    
    var firstRun: Bool = false
    
    var game: Papyrus!
    var unsubmittedMove: Move?
    
    var heldSprite: TileSprite? {
        return tileSprites.filter({$0.tile.placement == .Held}).first
    }
    var heldOrigin: CGPoint? {
        return heldSprite?.origin
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Papyrus"
        
        game = Papyrus(callback: lifecycleChanged)
        
        scene = TileScene(fileNamed:"TileScene")!
        scene.dragDelegate = self
        scene.scaleMode = .ResizeFill
        scene.backgroundColor = UIColor.clearColor()
        
        skView.allowsTransparency = true
        skView.presentScene(scene)
        
        submit = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: "submit:")
        restart = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "restart:")
        shuffle = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "shuffle:")
        swap = UIBarButtonItem(title: "Swap", style: .Plain, target: self, action: "swap:")
        
        shuffle?.enabled = false
        swap?.enabled = false
        restart?.enabled = false
        
        navigationItem.leftBarButtonItems = [shuffle!, swap!]
        navigationItem.rightBarButtonItems = [submit!, restart!]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !firstRun {
            boardView.game = game
            newGame()
            
            firstRun = true
        }
    }
    
    func newGame() {
        lifecycleChanged(.Preparing)
        if Papyrus.dawg == nil {
            game.operationQueue.addOperationWithBlock { () -> Void in
                Papyrus.dawg = Dawg.load(NSBundle.mainBundle().pathForResource("sowpods", ofType: "bin")!)!
                NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] () -> Void in
                    self?.game.newGame()
                    })
            }
            return
        }
        game.newGame()
    }
    
    func lifecycleChanged(lifecycle: Lifecycle) {
        enableButtons(false)
        switch (lifecycle) {
        case .NoGame:
            title = "Cleanup"
            
        case .Preparing:
            title = "Loading..."
        
        case .Ready:
            title = "Papyrus"
            game.createPlayer()
            
            replaceRackSprites()
            
        case .EndedTurn(let move):
            title = "Ended Turn \(move)"
            if game.player?.difficulty == .Human {
                replaceRackSprites()
            }
            
        case .ChangedPlayer:
            title = "Next Turn"
            print("Changed player \(game.playerIndex)")
            
        default:
            title = "Game Over"
            game.players.forEach { print("- \($0.difficulty) score: \($0.score)") }
            print("Winning score: \(game.players.map({$0.score}).maxElement())")
        }
    }
    
    func enableButtons(enabled: Bool) {
        let isHuman = game.player?.difficulty == .Human
        submit?.enabled = isHuman && enabled
        swap?.enabled = isHuman
        shuffle?.enabled = isHuman
        var gameOver = false
        if case .GameOver = game.lifecycle {
            gameOver = true
        }
        restart?.enabled = isHuman || gameOver
    }
    
    // MARK: - Buttons
    
    func swap(sender: UIBarButtonItem) {
        guard let player = game.player else { return }
        player.returnTiles(player.rackTiles)
        game.draw(player)
    }
    
    func shuffle(sender: UIBarButtonItem) {
        
    }
    
    func restart(sender: UIBarButtonItem) {
        game.newGame()
    }
    
    func submit(sender: UIBarButtonItem) {
        guard let move = unsubmittedMove else { return }
        game.submitMove(move)
    }
    
    // MARK: - Tiles
    
    /// Replace rack sprites with newly drawn tiles.
    private func replaceRackSprites() {
        // Remove existing rack sprites.
        let rackSprites = tileSprites.filter({ (game.player?.rackTiles.contains($0.tile)) == true })
        tileSprites = tileSprites.filter{ !rackSprites.contains($0) }
        rackSprites.forEach{ $0.removeFromParent() }
        
        var sprites = [TileSprite]()
        let spacing: CGFloat = 5
        let squareEdge = (CGRectGetWidth(boardView.bounds) - (spacing * 2)) / CGFloat(PapyrusRackAmount)
        var count: CGFloat = 1
        let top = CGRectGetHeight(skView.bounds) - CGRectGetHeight(boardView.bounds)
        game.player?.rackTiles.forEach({ (tile) -> () in
            let sprite = TileSprite(tile: tile, edge: squareEdge, scale: 1.0)
            let point = CGPoint(x: spacing + count * squareEdge - (squareEdge / 2), y: top - (squareEdge / 2) - spacing)
            sprite.position = point
            sprite.origin = point
            sprites.append(sprite)
            count++
        })
        
        tileSprites.appendContentsOf(sprites)
        tileSprites.filter{ $0.parent == nil }.forEach{ scene.addChild($0) }
    }
    
    // MARK:- Drag Delegate
    
    func resetHeld() {
        if let sprite = heldSprite {
            sprite.position = sprite.origin
            sprite.tile.placement = .Rack
            if let square = game.squaresFor([sprite.tile]).first {
                square.tile = nil
            }
        }
    }
    
    func pickup(atPoint point: CGPoint) {
        resetHeld()
        
        if game.player?.difficulty != .Human { return }
        if let square = boardView.squareAtPoint(point) where square.tile != nil {
            // Pickup from board
            guard let tileSprite = tileSprites.filter({$0.tile == square.tile}).first where tileSprite.movable else { return }
            square.tile = nil
            square.tile?.placement = .Held
            tileSprite.position = point
            tileSprite.animateGrow()
        }
        else if let tileSprite = tileSprites.filter({$0.containsPoint(point) && !$0.hasActions()}).first {
            // Pickup from rack
            tileSprite.tile.placement = .Held
            tileSprite.animatePickupFromRack(point)
        }
        // TODO: Check if valid play with tiles left on board
    }
    
    func dropInRack() {
        guard let point = heldOrigin, sprite = heldSprite, tile = heldSprite?.tile else { return }
        sprite.resetPosition(point)
        tile.placement = .Rack
        if tile.value == 0 {
            sprite.changeLetter("?")
        }
        // TODO: Check if valid play with tiles left on board
    }
    
    func drop(atPoint point: CGPoint) {
        guard let sprite = heldSprite else { return }
        let spriteFrame = CGRect(origin: scene.convertPoint(sprite.position, fromNode: sprite),
            size: sprite.frame.size)
        if let (square, destinationFrame) = boardView.bestSquareIntersection(spriteFrame, point: point) {
            
            let destPoint = destinationFrame.origin //scene.convertPoint(destinationFrame.origin, toNode: sprite)
            
            let tile = sprite.tile
            tile.placement = .Board
            square.tile = tile
            
            sprite.animateShrink()
            sprite.position = CGPoint(x: destPoint.x + destinationFrame.size.width / 2,
                y: destPoint.y + destinationFrame.size.height / 2)
            
            if tile.value == 0 && tile.letter == "?" {
                // TODO: Letter selection
            }
        } else {
            // Reset
            dropInRack()
        }
        // TODO: Check if valid play with tiles on board
    }
    
    func move(toPoint point: CGPoint) {
        heldSprite?.position = point
    }
}