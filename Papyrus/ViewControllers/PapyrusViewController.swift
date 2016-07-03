//
//  PapyrusViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class PapyrusViewController: UIViewController {
    enum SegueId: String {
        case PreferencesSegue
        case TilePickerSegue
        case TilesRemainingSegue
        case TileSwapperSegue
    }
    
    let watchdog = Watchdog(threshold: 0.2)
    let gameManager = GameManager.sharedInstance
    let presenter = GamePresenter()
    var firstRun: Bool = false
    
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
    
    @IBOutlet weak var gameView: GameView!
    @IBOutlet var submitButton: UIBarButtonItem!
    @IBOutlet var resetButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let id = segue.identifier, segueId = SegueId(rawValue: id) else {
            return
        }
        func getController<T>(_ controller: UIViewController? = nil) -> T {
            return (controller ?? segue.destinationViewController) as! T
        }
        switch segueId {
        case .TilePickerSegue:
            tilePickerViewController = getController()
        case .TileSwapperSegue:
            tileSwapperViewController = getController()
        case .TilesRemainingSegue:
            tilesRemainingViewController = getController()
            tilesRemainingViewController.completionHandler = { [weak self] in self?.fade(out: true) }
        case .PreferencesSegue:
            let navigationController: UINavigationController = getController()
            let preferencesController: PreferencesViewController = getController(navigationController.viewControllers.first!)
            preferencesController.saveHandler = { [weak self] in self?.newGame() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.gameView = gameView
        presenter.onPlacement = validate
        presenter.onBlank = handleBlank
        
        title = "Papyrus"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !firstRun {
            prepareGame()
            firstRun = true
        }
    }
    
    func fade(out: Bool, allExcept: UIView? = nil) {
        defer {
            UIView.animate(withDuration: 0.25) {
                self.blackoutView.alpha = out ? 0.0 : 0.4
                self.tileContainerViews.forEach({ $0.alpha = (out == false && $0 == allExcept) ? 1.0 : 0.0 })
            }
        }
        
        guard !out else {
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
    
    func updatePresenter() {
        guard let game = gameManager.game else { return }
        presenter.updateGame(game)
    }
}


// MARK: GameEvents
extension PapyrusViewController {
    func prepareGame() {
        enableButtons()
        title = "Starting..."
        
        // Try to restore a cached game first
        gameManager.restoreGame(eventHandler: handleEvent) { [weak self] success in
            guard let strongSelf = self else { return }
            guard success else {
                // If unsuccessful, create a new game
                strongSelf.newGame()
                return
            }
            strongSelf.gameManager.start()
        }
    }
    
    func newGame() {
        enableButtons()
        title = "Starting..."
        gameManager.newGame(eventHandler: handleEvent) { [weak self] in
            self?.title = "Started"
            self?.gameManager.start()
        }
    }
    
    func gameOver(with winner: Player?) {
        title = "Game Over"
        if tilesRemainingContainerView.alpha == 1.0 {
            updateShownTiles()
        }
        guard let winner = winner,
            playerIndex = gameManager.index(of: winner),
            bestMove = winner.solves.sorted(isOrderedBefore: { $0.score > $1.score }).first else {
                return
        }
        let message = "The winning score was \(winner.score).\nTheir best word was \(bestMove.word.uppercased()) scoring \(bestMove.score) points!"
        let alertController = UIAlertController(title: "Player \(playerIndex + 1) won!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func handleEvent(_ event: GameEvent) {
        func turnUpdated() {
            guard let player = gameManager.game?.player, playerIndex = gameManager.index(of: player) else { return }
            title = "Player \(playerIndex + 1) (\(player.score))"
        }
        
        switch event {
        case let .over(_, winner):
            updatePresenter()
            enableButtons()
            gameOver(with: winner)
        case .turnBegan(_):
            turnUpdated()
            enableButtons()
        case .turnEnded(_):
            updatePresenter()
            turnUpdated()
            if tilesRemainingContainerView.alpha == 1.0 {
                updateShownTiles()
            }
        case let .move(_, solution):
            print("Played \(solution)")
        case let .drewTiles(_, letters):
            print("Drew Tiles \(letters)")
        case .swappedTiles(_):
            print("Swapped Tiles")
        }
    }
}


// MARK: GamePresenter
extension PapyrusViewController {
    func handleBlank(_ tileView: TileView) {
        guard let bagType = gameManager.game?.bag.dynamicType else {
            return
        }
        tilePickerViewController.prepareForPresentation(bagType)
        tilePickerViewController.completionHandler = { letter in
            tileView.tile = letter
            self.validate()
            self.fade(out: true)
        }
        fade(out: false, allExcept: tilePickerContainerView)
    }
    
    func validate() {
        enableButtons(reset: gameManager.game?.player is Human && presenter.placedTiles().count > 0)
        gameManager.validate(tiles: presenter.placedTiles(), blanks: presenter.blankTiles()) { [weak self] (solution) in
            self?.enableButtons(submit: solution != nil)
        }
    }
}


// MARK: Buttons
extension PapyrusViewController {
    func enableButtons(submit: Bool = false, reset: Bool = false) {
        submitButton.isEnabled = submit
        resetButton.isEnabled = reset
    }
    
    func updateShownTiles() {
        guard let game = gameManager.game else { return }
        tilesRemainingViewController.prepareForPresentation(game.bag, players: showingUnplayed ? game.players : nil)
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
        if !gameManager.gameOver {
            if gameManager.game != nil {
                actionSheet.addAction(UIAlertAction(title: "Bag Tiles", style: .default, handler: showBagTiles))
                actionSheet.addAction(UIAlertAction(title: "Unplayed Tiles", style: .default, handler: showUnplayedTiles))
            }
            if gameManager.game?.player is Human {
                actionSheet.addAction(UIAlertAction(title: "Shuffle", style: .default, handler: shuffle))
                if gameManager.game?.canSwap == true {
                    actionSheet.addAction(UIAlertAction(title: "Swap All Tiles", style: .default, handler: swapAll))
                    actionSheet.addAction(UIAlertAction(title: "Swap Tiles", style: .default, handler: swap))
                }
                actionSheet.addAction(UIAlertAction(title: "Skip", style: .default, handler: skip))
                actionSheet.addAction(UIAlertAction(title: "Hint", style: .default, handler: hint))
            }
        }
        actionSheet.addAction(UIAlertAction(title: gameManager.gameOver ? "New Game" : "Restart", style: .destructive, handler: restart))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func reset(_ sender: UIBarButtonItem) {
        updatePresenter()
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        gameManager.validate(tiles: presenter.placedTiles(), blanks: presenter.blankTiles()) { [weak self] (solution) in
            guard let solution = solution else { return }
            self?.gameManager.play(solution: solution)
        }
    }

    func swapAll(_ sender: UIAlertAction) {
        gameManager.swapAll()
    }
    
    func swap(_ sender: UIAlertAction) {
        guard let rack = gameManager.game?.player.rack else { return }
        tileSwapperViewController.prepareForPresentation(rack)
        fade(out: false, allExcept: tilesSwapperContainerView)
    }
    
    func doSwap(_ sender: UIBarButtonItem) {
        guard let letters = tileSwapperViewController.toSwap() else { return }
        fade(out: true)
        gameManager.swap(tiles: letters)
    }
    
    func shuffle(_ sender: UIAlertAction) {
        gameManager.shuffle { [weak self] in
            self?.updatePresenter()
        }
    }
    
    func skip(_ sender: UIAlertAction) {
        gameManager.skip()
    }
    
    func hint(_ sender: UIAlertAction) {
        gameManager.hint { [weak self] (solution) in
            guard let strongSelf = self else { return }
            var message = ""
            if let solution = solution {
                message = "\((solution.horizontal ? "horizontal" : "vertical")) word '\(solution.word.uppercased())' can be placed \(solution.y + 1) down and \(solution.x + 1) across for a total score of \(solution.score)"
            } else {
                message = "Could not find any solutions, perhaps skip or swap letters?"
            }
            let alert = UIAlertController(title: "Hint", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            strongSelf.present(alert, animated: true, completion: nil)
        }
    }
    
    func restart(_ sender: UIAlertAction) {
        newGame()
    }
    
    func showPreferences(_ sender: UIAlertAction) {
        performSegue(withIdentifier: SegueId.PreferencesSegue.rawValue, sender: self)
    }
}
