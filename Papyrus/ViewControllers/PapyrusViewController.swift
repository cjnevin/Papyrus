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

class PapyrusViewController: UIViewController, PapyrusDelegate {
    
    @IBOutlet weak var gameView: GameView!

    let watchdog = Watchdog(threshold: 0.2)
    var submit: UIBarButtonItem?
    var shuffle: UIBarButtonItem?
    var swap: UIBarButtonItem?
    var restart: UIBarButtonItem?
    
    var firstRun: Bool = false
    
    var game: Papyrus!
    var unsubmittedMove: Move?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Papyrus"
        
        game = Papyrus(delegate: self)
        gameView.game = game
        
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
            gameView.game = game
            newGame()
            
            firstRun = true
        }
    }
    
    func newGame() {
        enableButtons(false)
        title = "Learning Words..."
        if Papyrus.dawg == nil {
            game.operationQueue.addOperationWithBlock { () -> Void in
                Papyrus.dawg = Dawg.load(NSBundle.mainBundle().pathForResource("sowpods", ofType: "bin")!)!
                
                NSOperationQueue.mainQueue().addOperationWithBlock() { [weak self] in
                    self?.game.newGame()
                }
            }
            return
        }
        game.newGame()
    }
    
    func enableButtons(enabled: Bool) {
        let isHuman = game.player?.difficulty == .Human
        submit?.enabled = isHuman && enabled
        swap?.enabled = isHuman
        shuffle?.enabled = isHuman
        restart?.enabled = isHuman || game.gameOver
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
    
    // MARK:- Papyrus Delegate
    
    func gameBegan(papyrus: Papyrus) {
        enableButtons(true)
        title = "Papyrus"
        game.createPlayer()
        gameView.replaceRackTiles()
    }
    
    func gameEnded(papyrus: Papyrus) {
        enableButtons(true)
        title = "Game Over"
        print("Winner \(papyrus.winner)")
        print("Winning score: \(game.players.map({$0.score}).maxElement())")
        game.players.forEach { print("- \($0.difficulty) score: \($0.score)") }
    }
    
    func gameLoading(papyrus: Papyrus) {
        enableButtons(false)
        title = "Loading..."
    }
    
    func turnBegan(papyrus: Papyrus) {
        enableButtons(true)
        print("Changed player \(game.playerIndex)")
    }
    
    func turnEnded(move: Move, papyrus: Papyrus) {
        print("Turn ended \(game.playerIndex)")
        if game.player?.difficulty == .Human {
            gameView.replaceRackTiles()
        }
    }
    
    func turnSkipped(papyrus: Papyrus) {
        enableButtons(true)
        print("Turn skipped \(game.playerIndex)")
    }
    
    func tileDropped(square: Square, papyrus: Papyrus) {
        
    }
    
    func tileRemoved(square: Square, papyrus: Papyrus) {
        enableButtons(true)
    }
    
    func movePossible(move: Move, papyrus: Papyrus) {
        enableButtons(true)
    }
    
    /*
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
    }*/
}