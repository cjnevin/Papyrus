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
    @IBOutlet weak var submitButton: UIBarButtonItem!

    let gameQueue = NSOperationQueue()
    
    let watchdog = Watchdog(threshold: 0.2)
    
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
        gameOver = false
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
    }
    
    // MARK: - Buttons
    
    func swap(sender: UIAlertAction) {
        gameQueue.addOperationWithBlock { [weak self] in
            guard let strongSelf = self where strongSelf.game?.player != nil else { return }
            strongSelf.game!.swapTiles(strongSelf.game!.player.rack)
        }
    }
    
    func shuffle(sender: UIAlertAction) {
        gameQueue.addOperationWithBlock { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.game?.shuffleRack()
            NSOperationQueue.mainQueue().addOperationWithBlock {
                strongSelf.presenter.game = strongSelf.game
            }
        }
    }
    
    func restart(sender: UIAlertAction) {
        newGame()
    }
    
    @IBAction func action(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if game?.player is Human && !gameOver {
            actionSheet.addAction(UIAlertAction(title: "Shuffle", style: .Default, handler: shuffle))
            actionSheet.addAction(UIAlertAction(title: "Swap", style: .Default, handler: swap))
        }
        actionSheet.addAction(UIAlertAction(title: gameOver ? "New Game" : "Restart", style: .Destructive, handler: restart))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    private func play(solution: Solution) {
        gameQueue.addOperationWithBlock { [weak self] in
            self?.game?.play(solution)
            self?.game?.nextTurn()
        }
    }
    
    @IBAction func submit(sender: UIBarButtonItem) {
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