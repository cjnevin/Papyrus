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

class PapyrusViewController: UIViewController, GamePresenterDelegate {
    @IBOutlet weak var gameView: GameView!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!

    let gameQueue = NSOperationQueue()
    
    let watchdog = Watchdog(threshold: 0.2)
    
    var firstRun: Bool = false
    
    var dictionary: Dawg!
    var game: Game?
    var presenter = GamePresenter()
    var gameOver: Bool = true
    var tilePickerViewController: TilePickerViewController!
    @IBOutlet weak var tilePickerContainerView: UIView!
    @IBOutlet weak var blackoutView: UIView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TilePickerSegue" {
            tilePickerViewController = segue.destinationViewController as! TilePickerViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.gameView = gameView
        presenter.delegate = self
        
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
                self.resetButton.enabled = false
                self.submitButton.enabled = false
                self.title = (self.game!.player is Human ? "Human " : "Computer ") + "\(self.game!.player.score)"
                self.presenter.game = self.game!
            case .TurnEnded:
                self.title = (self.game!.player is Human ? "Human " : "Computer ") + "\(self.game!.player.score)"
                self.presenter.game = self.game!
            case let .Move(solution):
                print("Played \(solution)")
            case .DrewTiles(_):
                print("Drew new tiles")
            case .SwappedTiles:
                print("Swapped tiles")
            }
        }
    }
    
    func newGame() {
        submitButton.enabled = false
        resetButton.enabled = false
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
            strongSelf.game = Game.newGame(strongSelf.dictionary, bag: Bag(withBlanks: true), players: [computer, computer2, human], eventHandler: strongSelf.handleEvent)
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
    
    // MARK: - GamePresenterDelegate
    
    func handleBlank(tileView: TileView, presenter: GamePresenter) {
        tilePickerViewController.completionHandler = { letter in
            tileView.tile = letter
            self.validate()
            UIView.animateWithDuration(0.25) {
                self.tilePickerContainerView.alpha = 0.0
                self.blackoutView.alpha = 0.0
            }
        }
        view.bringSubviewToFront(self.blackoutView)
        view.bringSubviewToFront(self.tilePickerContainerView)
        UIView.animateWithDuration(0.25) {
            self.blackoutView.alpha = 0.4
            self.tilePickerContainerView.alpha = 1.0
        }
    }
    
    func handlePlacement(presenter: GamePresenter) {
        validate()
    }
    
    func validate() -> Solution? {
        submitButton.enabled = false
        guard let game = game where gameOver == false else { return nil }
        if game.player is Human {
            let placed = presenter.placedTiles()
            resetButton.enabled = placed.count > 0
            
            let result = game.validate(placed)
            switch result {
            case let .Valid(solution):
                submitButton.enabled = true
                print(solution)
                return solution
            default:
                break
            }
            print(result)
        }
        return nil
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
    
    func skip(sender: UIAlertAction) {
        gameQueue.addOperationWithBlock { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.game?.skip()
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
            actionSheet.addAction(UIAlertAction(title: "Skip", style: .Default, handler: skip))
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
    
    @IBAction func reset(sender: UIBarButtonItem) {
        presenter.game = self.game!
    }
    
    @IBAction func submit(sender: UIBarButtonItem) {
        guard let solution = validate() else {
            return
        }
        play(solution)
    }
}