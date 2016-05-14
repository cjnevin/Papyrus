//
//  PapyrusViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class PapyrusViewController: UIViewController, GamePresenterDelegate {
    enum SegueId: String {
        case PreferencesSegue
        case TilePickerSegue
        case TilesRemainingSegue
    }
    
    @IBOutlet weak var gameView: GameView!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!

    let gameQueue = NSOperationQueue()
    
    let watchdog = Watchdog(threshold: 0.2)
    
    var firstRun: Bool = false
    
    var showingUnplayed: Bool = false
    var game: Game?
    var presenter = GamePresenter()
    var lastMove: Solution?
    var gameOver: Bool = true
    var dictionary: Dawg!
    var tilePickerViewController: TilePickerViewController!
    var tilesRemainingViewController: TilesRemainingViewController!
    @IBOutlet weak var tilePickerContainerView: UIView!
    @IBOutlet weak var tilesRemainingContainerView: UIView!
    @IBOutlet weak var blackoutView: UIView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueId.TilePickerSegue.rawValue {
            tilePickerViewController = segue.destinationViewController as! TilePickerViewController
        } else if segue.identifier == SegueId.TilesRemainingSegue.rawValue {
            tilesRemainingViewController = segue.destinationViewController as! TilesRemainingViewController
            tilesRemainingViewController.completionHandler = {
                UIView.animateWithDuration(0.25) {
                    self.tilesRemainingContainerView.alpha = 0.0
                    self.blackoutView.alpha = 0.0
                }
            }
        } else if segue.identifier == SegueId.PreferencesSegue.rawValue {
            let navigationController = segue.destinationViewController as! UINavigationController
            let preferencesController = navigationController.viewControllers.first! as! PreferencesViewController
            preferencesController.saveHandler = {
                self.newGame()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.gameView = gameView
        presenter.delegate = self
        
        gameQueue.maxConcurrentOperationCount = 1

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
            case let .Over(winner):
                self.gameOver = true
                self.title = "Game Over"
                print("Winner: \(winner)")
                if self.tilesRemainingContainerView.alpha == 1.0 {
                    self.updateShownTiles()
                }
            case .TurnStarted:
                self.resetButton.enabled = false
                self.submitButton.enabled = false
                self.title = (self.game!.player is Human ? "Human " : "Computer ") + "\(self.game!.player.score)"
            case .TurnEnded:
                self.title = (self.game!.player is Human ? "Human " : "Computer ") + "\(self.game!.player.score)"
                if self.tilesRemainingContainerView.alpha == 1.0 {
                    self.updateShownTiles()
                }
            case let .Move(solution):
                print("Played \(solution)")
                self.lastMove = solution
                self.presenter.updateGame(self.game!, move: solution)
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
            var players = [Player]()
            for _ in 0..<Preferences.sharedInstance.opponents {
                let difficulty = Preferences.sharedInstance.difficulty
                players.append(Computer(difficulty: difficulty))
            }
            players.append(Human())
            let superScrabble = Preferences.sharedInstance.gameType == .SuperScrabble
            let board = Board(config: superScrabble ? SuperScrabbleBoardConfig() : ScrabbleBoardConfig())
            let bag = Bag(distribution: superScrabble ? SuperScrabbleDistribution() : ScrabbleDistribution())
            strongSelf.game = Game.newGame(strongSelf.dictionary, board: board, bag: bag, players: players, eventHandler: strongSelf.handleEvent)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                strongSelf.title = "Started"
                strongSelf.gameQueue.addOperationWithBlock {
                    strongSelf.game?.start()
                }
            }
        }
    }
    
    // MARK: - GamePresenterDelegate
    
    func handleBlank(tileView: TileView, presenter: GamePresenter) {
        tilePickerViewController.prepareForPresentation(game!.bag.distribution)
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
            let blanks = presenter.blankTiles()
            resetButton.enabled = placed.count > 0
            
            let result = game.validate(placed, blanks: blanks)
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
            strongSelf.game!.swapTiles(strongSelf.game!.player.rack.map({ $0.letter }))
        }
    }
    
    func shuffle(sender: UIAlertAction) {
        gameQueue.addOperationWithBlock { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.game?.shuffleRack()
            NSOperationQueue.mainQueue().addOperationWithBlock {
                strongSelf.presenter.updateGame(strongSelf.game!)
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
    
    func showPreferences(sender: UIAlertAction) {
        performSegueWithIdentifier(SegueId.PreferencesSegue.rawValue, sender: self)
    }
    
    func updateShownTiles() {
        if showingUnplayed {
            tilesRemainingViewController.prepareForPresentation(game!.bag, players: game!.players)
        } else {
            tilesRemainingViewController.prepareForPresentation(game!.bag)
        }
    }
    
    func showBagTiles(sender: UIAlertAction) {
        showingUnplayed = false
        updateShownTiles()
        view.bringSubviewToFront(self.blackoutView)
        view.bringSubviewToFront(self.tilesRemainingContainerView)
        UIView.animateWithDuration(0.25) {
            self.blackoutView.alpha = 0.4
            self.tilesRemainingContainerView.alpha = 1.0
        }
    }
    
    func showUnplayedTiles(sender: UIAlertAction) {
        showingUnplayed = true
        updateShownTiles()
        view.bringSubviewToFront(self.blackoutView)
        view.bringSubviewToFront(self.tilesRemainingContainerView)
        UIView.animateWithDuration(0.25) {
            self.blackoutView.alpha = 0.4
            self.tilesRemainingContainerView.alpha = 1.0
        }
    }
    
    @IBAction func action(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Preferences", style: .Default, handler: showPreferences))
        if game != nil {
            actionSheet.addAction(UIAlertAction(title: "Bag Tiles", style: .Default, handler: showBagTiles))
            actionSheet.addAction(UIAlertAction(title: "Unplayed Tiles", style: .Default, handler: showUnplayedTiles))
        }
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
        presenter.updateGame(self.game!, move: lastMove)
    }
    
    @IBAction func submit(sender: UIBarButtonItem) {
        guard let solution = validate() else {
            return
        }
        play(solution)
    }
}