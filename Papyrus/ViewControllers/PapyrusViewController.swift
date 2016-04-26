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
    var submitButton: UIBarButtonItem!
    var shuffleButton: UIBarButtonItem!
    var swapButton: UIBarButtonItem!
    var restartButton: UIBarButtonItem!
    
    var firstRun: Bool = false
    
    var dictionary: Dawg!
    var game: Game?
    var presenter = GamePresenter()
    var gameOver: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.gameView = gameView
        
        gameQueue.maxConcurrentOperationCount = 1
        gameQueue.addOperationWithBlock { [weak self] in
            self?.dictionary = Dawg.load(NSBundle.mainBundle().pathForResource("sowpods", ofType: "bin")!)!
        }
        
        title = "Papyrus"
        
        submitButton = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: #selector(submit))
        restartButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(restart))
        shuffleButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(shuffle))
        swapButton = UIBarButtonItem(title: "Swap", style: .Plain, target: self, action: #selector(swap))
        
        shuffleButton.enabled = false
        swapButton.enabled = false
        restartButton.enabled = false
        
        navigationItem.leftBarButtonItems = [shuffleButton, swapButton]
        navigationItem.rightBarButtonItems = [submitButton, restartButton]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !firstRun {
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
            case .TurnStarted:
                self.enableButtons(true)
                self.presenter.game = self.game!
            case .TurnEnded:
                self.presenter.game = self.game!
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
            let human = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
            strongSelf.game = Game.newGame(strongSelf.dictionary, bag: Bag(withBlanks: false), players: [computer, computer2, human], eventHandler: strongSelf.handleEvent)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                //strongSelf.gameView.game = strongSelf.game
                strongSelf.title = "Started"
                strongSelf.gameQueue.addOperationWithBlock {
                    strongSelf.game?.start()
                }
            }
        }
    }
    
    func enableButtons(enabled: Bool) {
        let isHuman = game?.player is Human
        submitButton.enabled = isHuman && enabled
        swapButton.enabled = isHuman
        shuffleButton.enabled = isHuman
        restartButton.enabled = isHuman || gameOver
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
    
    private func play(solution: Solution) {
        gameQueue.addOperationWithBlock { [weak self] in
            self?.game?.play(solution)
            self?.game?.nextTurn()
        }
    }
    
    func submit(sender: UIBarButtonItem) {
        let result = game?.validate(presenter.tiles())
        switch result! {
        case let .Valid(solution):
            play(solution)
        case .InvalidArrangement:
            print("Invalid arrangement")
        case let .InvalidWord(_, _, word):
            print("Invalid word \(word)")
        }
        print(result)
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