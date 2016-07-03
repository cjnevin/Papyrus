//
//  PapyrusViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import AnagramDictionary
import PapyrusCore

class PapyrusViewController: UIViewController, GamePresenterDelegate {
    enum SegueId: String {
        case PreferencesSegue
        case TilePickerSegue
        case TilesRemainingSegue
        case TileSwapperSegue
    }
    
    @IBOutlet weak var gameView: GameView!
    @IBOutlet var submitButton: UIBarButtonItem!
    @IBOutlet var resetButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!

    let gameQueue = OperationQueue()
    
    let watchdog = Watchdog(threshold: 0.2)
    
    var firstRun: Bool = false
    var game: Game?
    var presenter = GamePresenter()
    var lastMove: Solution?
    var gameOver: Bool = true
    var dictionary: Lookup!
    
    var startTime: Date? = nil
    
    var showingUnplayed: Bool = false
    var showingSwapper: Bool = false
    var tilePickerViewController: TilePickerViewController!
    var tileSwapperViewController: TileSwapperViewController!
    var tilesRemainingViewController: TilesRemainingViewController!
    @IBOutlet var tileContainerViews: [UIView]!
    @IBOutlet weak var tilePickerContainerView: UIView!
    @IBOutlet weak var tilesRemainingContainerView: UIView!
    @IBOutlet weak var tilesSwapperContainerView: UIView!
    @IBOutlet weak var blackoutView: UIView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueId.TilePickerSegue.rawValue {
            tilePickerViewController = segue.destinationViewController as! TilePickerViewController
        } else if segue.identifier == SegueId.TileSwapperSegue.rawValue {
            tileSwapperViewController = segue.destinationViewController as! TileSwapperViewController
        } else if segue.identifier == SegueId.TilesRemainingSegue.rawValue {
            tilesRemainingViewController = segue.destinationViewController as! TilesRemainingViewController
            tilesRemainingViewController.completionHandler = {
                self.fade(out: true)
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
    
    func gameOver(with winner: Player?) {
        print("Time Taken: \(Date().timeIntervalSince(startTime!))")
        startTime = nil
        gameOver = true
        title = "Game Over"
        if tilesRemainingContainerView.alpha == 1.0 {
            updateShownTiles()
        }
        guard let winner = winner, game = game,
            (index, player) = game.players.enumerated().filter({ $1.id == winner.id }).first,
            bestMove = player.solves.sorted(isOrderedBefore: { $0.score > $1.score }).first else {
                return
        }
        let message = "The winning score was \(player.score).\nTheir best word was \(bestMove.word.uppercased()) scoring \(bestMove.score) points!"
        let alertController = UIAlertController(title: "Player \(index + 1) won!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
   
    func turnUpdated() {
        guard let game = game else { return }
        presenter.updateGame(game, move: lastMove)
        guard let (index, player) = game.players.enumerated().filter({ $1.id == game.player.id }).first else { return }
        title = "Player \(index + 1) (\(player.score))"
    }
    
    func turnStarted() {
        turnUpdated()
        startTime = startTime ?? Date()
        resetButton.isEnabled = false
        submitButton.isEnabled = false
    }
    
    func turnEnded() {
        turnUpdated()
        if tilesRemainingContainerView.alpha == 1.0 {
            updateShownTiles()
        }
    }
    
    func handleEvent(_ event: GameEvent) {
        DispatchQueue.main.async() {
            switch event {
            case let .over(winner):
                self.gameOver(with: winner)
            case .turnStarted:
                self.turnStarted()
            case .turnEnded:
                self.turnEnded()
            case let .move(solution):
                print("Played \(solution)")
                self.lastMove = solution
            case let .drewTiles(letters):
                print("Drew Tiles \(letters)")
            case .swappedTiles:
                print("Swapped Tiles")
            }
        }
    }
    
    func newGame() {
        submitButton.isEnabled = false
        resetButton.isEnabled = false
        gameOver = false
        title = "Starting..."
        
        if dictionary == nil {
            gameQueue.addOperation { [weak self] in
                self?.dictionary = AnagramDictionary(filename: Preferences.sharedInstance.dictionary)!
            }
        }
        
        func makePlayers(_ count: Int, f: () -> (Player)) -> [Player] {
            return (0..<count).map({ _ in f() })
        }
        
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self else { return }
            
            let prefs = Preferences.sharedInstance
            let players = (makePlayers(prefs.opponents, f: { Computer(difficulty: prefs.difficulty) }) +
                makePlayers(prefs.humans, f: { Human() })).shuffled()
            
            assert(players.count > 0)
            
            strongSelf.game = Game(
                gameType: Preferences.sharedInstance.gameType,
                dictionary: strongSelf.dictionary,
                players: players,
                eventHandler: strongSelf.handleEvent)
            
            DispatchQueue.main.async() {
                strongSelf.title = "Started"
                strongSelf.gameQueue.addOperation {
                    strongSelf.game?.start()
                }
            }
        }
    }
    
    // MARK: - GamePresenterDelegate
    
    func fade(out: Bool, allExcept: UIView? = nil) {
        defer {
            UIView.animate(withDuration: 0.25) {
                self.blackoutView.alpha = out ? 0.0 : 0.4
                self.tileContainerViews.forEach({ $0.alpha = (out == false && $0 == allExcept) ? 1.0 : 0.0 })
            }
        }
        
        guard out else {
            navigationItem.setLeftBarButtonItems([actionButton, resetButton], animated: true)
            navigationItem.setRightBarButton(submitButton, animated: true)
            return
        }
        
        navigationItem.setLeftBarButtonItems(nil, animated: true)
        navigationItem.setRightBarButton(allExcept == tilesSwapperContainerView ? UIBarButtonItem(title: "Swap", style: .done, target: self, action: #selector(doSwap)) : nil, animated: true)
        view.bringSubview(toFront: self.blackoutView)
        if let fadeInView = allExcept {
            view.bringSubview(toFront: fadeInView)
        }
    }
    
    func handleBlank(_ tileView: TileView, presenter: GamePresenter) {
        tilePickerViewController.prepareForPresentation(game!.bag.dynamicType)
        tilePickerViewController.completionHandler = { letter in
            tileView.tile = letter
            let _ = self.validate()
            self.fade(out: true)
        }
        fade(out: false, allExcept: tilePickerContainerView)
    }
    
    func handlePlacement(_ presenter: GamePresenter) {
        let _ = validate()
    }
    
    func validate() -> Solution? {
        submitButton.isEnabled = false
        guard let game = game where gameOver == false else { return nil }
        if game.player is Human {
            let placed = presenter.placedTiles()
            let blanks = presenter.blankTiles()
            resetButton.isEnabled = placed.count > 0
            
            let result = game.validate(points: placed, blanks: blanks)
            switch result {
            case let .valid(solution):
                submitButton.isEnabled = true
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
    
    func swapAll(_ sender: UIAlertAction) {
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self where strongSelf.game?.player != nil else { return }
            let _ = strongSelf.game!.swap(tiles: strongSelf.game!.player.rack.map({ $0.letter }))
        }
    }
    
    func swap(_ sender: UIAlertAction) {
        tileSwapperViewController.prepareForPresentation(game!.player.rack)
        fade(out: false, allExcept: tilesSwapperContainerView)
    }
    
    func doSwap(_ sender: UIBarButtonItem) {
        guard let letters = tileSwapperViewController.toSwap() else {
            return
        }
        fade(out: true)
        if letters.count == 0 {
            return
        }
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self where strongSelf.game?.player != nil else { return }
            let _ = strongSelf.game!.swap(tiles: letters)
        }
    }
    
    func shuffle(_ sender: UIAlertAction) {
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.game?.shuffleRack()
            DispatchQueue.main.async() {
                strongSelf.presenter.updateGame(strongSelf.game!, move: strongSelf.lastMove)
            }
        }
    }
    
    func skip(_ sender: UIAlertAction) {
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.game?.skip()
        }
    }
    
    func hint(_ sender: UIAlertAction) {
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.game?.getHint() { solution in
                DispatchQueue.main.async() {
                    var message = ""
                    if let solution = solution {
                        message = "\((solution.horizontal ? "horizontal" : "vertical")) word '\(solution.word.uppercased())' can be placed \(solution.y + 1) down and \(solution.x + 1) across for a total score of \(solution.score)"
                    } else {
                        message = "Could not find any solutions, perhaps skip or swap letters?"
                    }
                    let alert = UIAlertController(title: "Hint", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func restart(_ sender: UIAlertAction) {
        newGame()
    }
    
    func showPreferences(_ sender: UIAlertAction) {
        performSegue(withIdentifier: SegueId.PreferencesSegue.rawValue, sender: self)
    }
    
    func updateShownTiles() {
        if showingUnplayed {
            tilesRemainingViewController.prepareForPresentation(game!.bag, players: game!.players)
        } else {
            tilesRemainingViewController.prepareForPresentation(game!.bag)
        }
    }
    
    func showBagTiles(_ sender: UIAlertAction) {
        showingUnplayed = false
        updateShownTiles()
        fade(out: false, allExcept: tilesRemainingContainerView)
    }
    
    func showUnplayedTiles(_ sender: UIAlertAction) {
        showingUnplayed = true
        updateShownTiles()
        fade(out: false, allExcept: tilesRemainingContainerView)
    }
    
    @IBAction func action(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Preferences", style: .default, handler: showPreferences))
        if game != nil {
            actionSheet.addAction(UIAlertAction(title: "Bag Tiles", style: .default, handler: showBagTiles))
            actionSheet.addAction(UIAlertAction(title: "Unplayed Tiles", style: .default, handler: showUnplayedTiles))
        }
        if game?.player is Human && !gameOver {
            actionSheet.addAction(UIAlertAction(title: "Shuffle", style: .default, handler: shuffle))
            actionSheet.addAction(UIAlertAction(title: "Swap All Tiles", style: .default, handler: swapAll))
            actionSheet.addAction(UIAlertAction(title: "Swap Tiles", style: .default, handler: swap))
            actionSheet.addAction(UIAlertAction(title: "Skip", style: .default, handler: skip))
            actionSheet.addAction(UIAlertAction(title: "Hint", style: .default, handler: hint))
        }
        actionSheet.addAction(UIAlertAction(title: gameOver ? "New Game" : "Restart", style: .destructive, handler: restart))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    private func play(solution: Solution) {
        gameQueue.addOperation { [weak self] in
            self?.game?.play(solution: solution)
            self?.game?.nextTurn()
        }
    }
    
    @IBAction func reset(_ sender: UIBarButtonItem) {
        presenter.updateGame(self.game!, move: lastMove)
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        guard let solution = validate() else {
            return
        }
        play(solution: solution)
    }
}
