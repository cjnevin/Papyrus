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

class PapyrusViewController: UIViewController {
    
    @IBOutlet weak var gameView: GameView!

    let gameQueue = NSOperationQueue()
    
    let watchdog = Watchdog(threshold: 0.2)
    var submit: UIBarButtonItem?
    var shuffle: UIBarButtonItem?
    var swap: UIBarButtonItem?
    var restart: UIBarButtonItem?
    
    var firstRun: Bool = false
    
    var dictionary: Dawg!
    var game: Game?
    var gameOver: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameQueue.maxConcurrentOperationCount = 1
        gameQueue.addOperationWithBlock { [weak self] in
            self?.dictionary = Dawg.load(NSBundle.mainBundle().pathForResource("sowpods", ofType: "bin")!)!
        }
        
        title = "Papyrus"
        
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
    
    func handleEvent(event: GameEvent) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            switch event {
            case .Over(_):
                self.gameOver = true
                self.title = "Game Over"
            case .TurnEnded:
                self.gameView.game = self.game
                if self.game?.player is Human {
                    self.gameView.replaceRackTiles()
                }
            default:
                break
            }
        }
    }
    
    func newGame() {
        enableButtons(false)
        title = "Starting..."
        if dictionary == nil {
            gameQueue.addOperationWithBlock { [weak self] in
                self?.dictionary = Dawg.load(NSBundle.mainBundle().pathForResource("sowpods", ofType: "bin")!)!
            }
        }
        gameQueue.addOperationWithBlock { [weak self] in
            guard let strongSelf = self else { return }
            let computer = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
            let computer2 = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
            //let human = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
            strongSelf.game = Game.newGame(strongSelf.dictionary, bag: Bag(withBlanks: false), players: [computer, computer2], eventHandler: strongSelf.handleEvent)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                strongSelf.gameView.game = strongSelf.game
                strongSelf.title = "Started"
                strongSelf.gameQueue.addOperationWithBlock {
                    strongSelf.game?.start()
                }
            }
        }
    }
    
    func enableButtons(enabled: Bool) {
        let isHuman = game?.player is Human
        submit?.enabled = isHuman && enabled
        swap?.enabled = isHuman
        shuffle?.enabled = isHuman
        restart?.enabled = isHuman || gameOver
    }
    
    // MARK: - Buttons
    
    func swap(sender: UIBarButtonItem) {
        gameQueue.addOperationWithBlock { [weak self] in
            guard let game = self?.game else {
                return
            }
            self!.game!.swapTiles(game.player.rack)
        }
    }
    
    func shuffle(sender: UIBarButtonItem) {
        
    }
    
    func restart(sender: UIBarButtonItem) {
        newGame()
    }
    
    func submit(sender: UIBarButtonItem) {
        //guard let move = unsubmittedMove else { return }
        //game.submitMove(move)
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