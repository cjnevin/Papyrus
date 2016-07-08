//
//  PapyrusViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore
import WordplaysLookup

class PapyrusViewController: UIViewController {
    let watchdog = Watchdog(threshold: 0.2)
    let gameManager = GameManager.sharedInstance
    var presenter: GamePresenter?
    var firstRun: Bool = false
    
    var definitionLabel: UILabel!
    
    var showingUnplayed: Bool = false
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
        if let viewController: TilePickerViewController = segue.inferredDestinationViewController() {
            tilePickerViewController = viewController
        } else if let viewController: TileSwapperViewController = segue.inferredDestinationViewController() {
            tileSwapperViewController = viewController
        } else if let viewController: TilesRemainingViewController = segue.inferredDestinationViewController() {
            tilesRemainingViewController = viewController
            tilesRemainingViewController.completionHandler = { [weak self] in self?.fade(out: true) }
        } else if let navigationController: PreferencesNavigationController = segue.inferredDestinationViewController() {
            navigationController.preferencesViewController.saveHandler = { [weak self] in self?.newGame() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Learning..."
        
        let padding = CGFloat(8)
        
        // TODO: Double tap rack could restore all tiles
        // TODO: Make presenters UIViews, we can then create them in UIStoryboard
        
        var rackRect = gameView.bounds
        rackRect.size.height = RackPresenter.calculateHeight(forRect: gameView.frame)
        rackRect.origin.y = gameView.bounds.height - rackRect.height
        
        var boardRect = gameView.bounds
        boardRect.origin.x = padding
        boardRect.size.width = boardRect.width - (boardRect.origin.x * 2)
        boardRect.size.height = boardRect.width
        boardRect.origin.y = rackRect.origin.y - boardRect.height
        
        let boardPresenter = BoardPresenter(rect: boardRect, onPlacement: validate, onBlank: handleBlank)
        let rackPresenter = RackPresenter(rect: rackRect, delegate: boardPresenter)
        
        let offset = UIApplication.shared().statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0)
        let scoreRect = CGRect(origin: CGPoint(x: 0, y: offset), size: CGSize(width: gameView.bounds.width, height: 80))
        let scoreLayout = ScoreLayout(rect: scoreRect)
        let scorePresenter = ScorePresenter(layout: scoreLayout)
        
        definitionLabel = UILabel(frame: CGRect(x: padding,
                                                y: scoreRect.origin.y + scoreRect.height,
                                                width: gameView.bounds.width - (padding * 2),
                                                height: boardRect.origin.y - (scoreRect.origin.y + scoreRect.height)))
        definitionLabel.numberOfLines = 4
        definitionLabel.textAlignment = .center
        definitionLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        view.addSubview(definitionLabel)
        
        presenter = GamePresenter(board: boardPresenter, rack: rackPresenter, score: scorePresenter)
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
        presenter?.refresh(in: gameView, with: game)
    }
}


// MARK: GameEvents
extension PapyrusViewController {
    func prepareGame() {
        enableButtons()
        
        // Try to restore a cached game first
        gameManager.restoreGame(eventHandler: handleEvent) { [weak self] success in
            guard let strongSelf = self else { return }
            guard success else {
                // If unsuccessful, create a new game
                strongSelf.newGame()
                return
            }
            strongSelf.title = "Starting..."
            strongSelf.gameManager.start()
        }
    }
    
    func newGame() {
        enableButtons()
        gameManager.newGame(eventHandler: handleEvent) { [weak self] in
            self?.title = "Starting..."
            self?.gameManager.start()
        }
    }
    
    func gameOver(with winner: Player?) {
        title = "Game Over"
        if tilesRemainingContainerView.alpha == 1.0 {
            updateShownTiles()
        }
        guard let winner = winner,
            playerIndex = gameManager.game?.index(of: winner),
            bestMove = winner.solves.sorted(isOrderedBefore: { $0.score > $1.score }).first else {
                return
        }
        define(word: bestMove.word)
        let message = "The winning score was \(winner.score).\nTheir best word was \(bestMove.word.uppercased()) scoring \(bestMove.score) points!"
        let alertController = UIAlertController(title: "Player \(playerIndex + 1) won!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func define(word: String, prefix: String? = nil) {
        WordplaysLookup.find(word: word) { [weak self] definition in
            guard let definition = definition else {
                return
            }
            print(definition)
            if definition.substring(to: word.endIndex) != word {
                self?.definitionLabel.text = word + " -- " + definition
            } else {
                self?.definitionLabel.text = definition
            }
        }
    }
    
    func handleEvent(_ event: GameEvent) {
        func turnUpdated() {
            guard let player = gameManager.game?.player else { return }
            if player is Human {
                title = "Your Turn"
            } else {
                title = "Thinking..."
            }
        }
        
        switch event {
        case let .over(_, winner):
            updatePresenter()
            enableButtons()
            gameOver(with: winner)
        case .turnBegan(_):
            updatePresenter()
            turnUpdated()
            enableButtons()
        case .turnEnded(_):
            updatePresenter()
            turnUpdated()
            if tilesRemainingContainerView.alpha == 1.0 {
                updateShownTiles()
            }
        case let .move(_, solution):
            define(word: solution.word)
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
        guard let tiles = presenter?.board.tiles, blanks = presenter?.board.blanks else {
            return
        }
        enableButtons(reset: gameManager.game?.player is Human && tiles.count > 0)
        gameManager.validate(tiles: tiles, blanks: blanks) { [weak self] (solution) in
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
        if gameManager.game?.ended == false {
            actionSheet.addAction(UIAlertAction(title: "Bag Tiles", style: .default, handler: showBagTiles))
            actionSheet.addAction(UIAlertAction(title: "Unplayed Tiles", style: .default, handler: showUnplayedTiles))
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
        actionSheet.addAction(UIAlertAction(title: gameManager.game?.ended == true ? "New Game" : "Restart", style: .destructive, handler: restart))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func reset(_ sender: UIBarButtonItem) {
        updatePresenter()
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        guard let tiles = presenter?.board.tiles, blanks = presenter?.board.blanks else {
            return
        }
        gameManager.validate(tiles: tiles, blanks: blanks) { [weak self] (solution) in
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
        performSegue(withIdentifier: PreferencesViewController.segueIdentifier, sender: self)
    }
}
