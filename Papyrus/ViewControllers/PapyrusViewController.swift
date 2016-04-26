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
}