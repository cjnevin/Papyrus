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
    let gameManager = GameManager.sharedInstance
    var presenter: GamePresenter?
    var firstRun: Bool = false
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !firstRun {
            gameView.tileViewDelegate = self
            presenter = GamePresenter(view: gameView)
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
    
    func spring(animations: () -> ()) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: animations, completion: nil)
    }
    
    func updatePresenter() {
        guard let game = gameManager.game else { return }
        presenter?.refresh(in: gameView, with: game)
    }
}


// MARK: GameEvents
extension PapyrusViewController {
    func prepareGame() {
        submitButton.isEnabled = false
        resetButton.isEnabled = false
        
        // Try to restore a cached game first
        gameManager.restoreGame(eventHandler: process) { [weak self] success in
            guard let strongSelf = self else { return }
            guard success else {
                // If unsuccessful, create a new game
                strongSelf.newGame()
                return
            }
            strongSelf.title = "Starting..."
            if let word = strongSelf.gameManager.game?.lastMove?.word {
                strongSelf.definition(for: word)
            }
            strongSelf.gameManager.start()
        }
    }
    
    func newGame() {
        submitButton.isEnabled = false
        resetButton.isEnabled = false
        
        gameManager.newGame(eventHandler: process) { [weak self] in
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
        let message = "The winning score was \(winner.score).\nTheir best word was \(bestMove.word.uppercased()) scoring \(bestMove.score) points!"
        let alertController = UIAlertController(title: "Player \(playerIndex + 1) won!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func definition(for word: String, prefix: String? = nil) {
        WordplaysLookup.find(word: word) { [weak self] definition in
            guard let definition = definition else {
                return
            }
            print(definition)
            if definition.substring(to: word.endIndex) != word {
                self?.presenter?.definitionLabel.text = word + " -- " + definition
            } else {
                self?.presenter?.definitionLabel.text = definition
            }
        }
    }
    
    func process(event: GameEvent) {
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
            submitButton.isEnabled = false
            resetButton.isEnabled = false
            gameOver(with: winner)
        case .turnBegan(_):
            updatePresenter()
            turnUpdated()
            submitButton.isEnabled = false
            resetButton.isEnabled = false
        case .turnEnded(_):
            updatePresenter()
            turnUpdated()
            submitButton.isEnabled = false
            resetButton.isEnabled = false
            if tilesRemainingContainerView.alpha == 1.0 {
                updateShownTiles()
            }
        case let .move(_, solution):
            definition(for: solution.word)
        case let .drewTiles(_, letters):
            print("Drew Tiles \(letters)")
        case .swappedTiles(_):
            print("Swapped Tiles")
        }
    }
}


// MARK: GamePresenter
extension PapyrusViewController {
    func handle(blank tileView: TileView) {
        guard let bagType = gameManager.game?.bag.dynamicType else {
            return
        }
        tilePickerViewController.prepareForPresentation(of: bagType)
        tilePickerViewController.completionHandler = { letter in
            tileView.tile = letter
            self.validate()
            self.fade(out: true)
        }
        fade(out: false, allExcept: tilePickerContainerView)
    }
    
    func validate() {
        guard let tiles = gameView?.placedTiles, blanks = gameView?.blanks else {
            return
        }
        resetButton.isEnabled = gameManager.game?.player is Human && tiles.count > 0
        gameManager.validate(tiles: tiles, blanks: blanks) { [weak self] (solution) in
            self?.submitButton.isEnabled = solution != nil
        }
    }
}


// MARK: Buttons
extension PapyrusViewController {
    func updateShownTiles() {
        guard let game = gameManager.game else { return }
        tilesRemainingViewController.prepareForPresentation(of: game.bag, players: showingUnplayed ? game.players : nil)
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
        spring() {
            self.gameView?.tileViews?.forEach({
                $0.frame = $0.initialFrame
                $0.onBoard = false
            })
        }
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        guard let tiles = gameView?.placedTiles, blanks = gameView?.blanks else {
            return
        }
        gameManager.validate(tiles: tiles, blanks: blanks) { [weak self] (solution) in
            guard let solution = solution else { return }
            self?.gameManager.play(solution: solution)
        }
    }
    
    func doSwap(_ sender: UIBarButtonItem) {
        guard let letters = tileSwapperViewController.toSwap() else { return }
        fade(out: true)
        gameManager.swap(tiles: letters)
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
        performSegue(withIdentifier: PreferencesNavigationController.segueIdentifier, sender: self)
    }
    
    func shuffle(_ sender: UIAlertAction) {
        guard let oldTiles = gameManager.game?.player.rack, oldTileViews = gameView.tileViews where oldTiles.count > 1 else {
            return
        }
        let zipped = zip(oldTiles, oldTileViews)
        gameManager.shuffle { [weak self] in
            guard let newTiles = self?.gameManager.game?.player.rack else {
                self?.updatePresenter()
                return
            }
            if oldTiles == newTiles {
                self?.shuffle(sender)
                return
            }
            
            let newTileViews = newTiles.map({ zipped.map({ $0.1 })[oldTiles.startIndex.distance(to: oldTiles.index(of: $0)!)] })
            
            self?.spring() {
                let newXs = newTileViews.map({ $0.frame.origin.x }).sorted()
                for (index, newTileView) in newTileViews.enumerated() {
                    var frame = newTileView.frame
                    frame.origin.x = newXs[index]
                    newTileView.frame = frame
                    newTileView.initialFrame = frame
                }
                self?.gameView.tileViews = newTileViews
                self?.gameManager.saveCache()
            }
        }
    }
    
    func skip(_ sender: UIAlertAction) {
        gameManager.skip()
    }
    
    func swap(_ sender: UIAlertAction) {
        guard let rack = gameManager.game?.player.rack else { return }
        tileSwapperViewController.prepareForPresentation(of: rack)
        fade(out: false, allExcept: tilesSwapperContainerView)
    }
    
    func swapAll(_ sender: UIAlertAction) {
        gameManager.swapAll()
    }
}

extension PapyrusViewController: TileViewDelegate {
    func dropRect(for tileView: TileView) -> CGRect {
        if let rect = gameView?.boardDrawable?.rect where tileView.frame.intersects(rect) {
            if let intersection = gameView?.bestIntersection(forRect: tileView.frame) {
                tileView.onBoard = true
                tileView.x = intersection.x
                tileView.y = intersection.y
                return intersection.rect
            }
        }
        // Fallback, return current frame
        return tileView.initialFrame
    }
    
    /// Only use this method for moving a single tile.
    func rearrange(from currentIndex: Int, to newIndex: Int) {
        guard let tileViews = gameView?.tileViews, newRect = tileViews[newIndex].initialFrame where currentIndex != newIndex else { return }
        
        func setFrame(at index: Int, to rect: CGRect) {
            tileViews[index].initialFrame = rect
            if tileViews[index].onBoard == false {
                tileViews[index].frame = rect
            }
        }
        
        if currentIndex > newIndex {
            // move left
            (newIndex..<currentIndex).forEach({ index in
                setFrame(at: index, to: tileViews[index + 1].initialFrame)
            })
        } else {
            // move right
            ((currentIndex + 1)...newIndex).reversed().forEach({ index in
                setFrame(at: index, to: tileViews[index - 1].initialFrame)
            })
        }
        setFrame(at: currentIndex, to: newRect)
        
        let obj = gameView!.tileViews![currentIndex]
        gameView?.tileViews?.remove(at: currentIndex)
        gameView?.tileViews?.insert(obj, at: newIndex)
        gameView?.bringSubview(toFront: obj)
        gameManager.saveCache()
    }
    
    func rearrange(tileView: TileView) -> Bool {
        if let intersected = gameView?.tileViews?.filter({ $0 != tileView && $0.frame.intersects(tileView.frame) }),
            closest = intersected.min(isOrderedBefore: { abs($0.center.x - tileView.center.x) < abs($1.center.x - tileView.center.x) }),
            closestIndex = gameView?.tileViews?.index(of: closest),
            tileIndex = gameView?.tileViews?.index(of: tileView),
            startIndex = gameView?.tileViews?.startIndex {
            let current = startIndex.distance(to: tileIndex)
            let new = current + tileIndex.distance(to: closestIndex)
            gameManager.game?.moveRackTile(from: current, to: new)
            spring() {
                self.rearrange(from: current, to: new)
            }
            return true
        }
        return false
    }
        
    func dropped(tileView: TileView) {
        validate()
        if tileView.tile == Game.blankLetter && tileView.onBoard {
            handle(blank: tileView)
        } else if tileView.isBlank && !tileView.onBoard {
            tileView.tile = Game.blankLetter
        }
    }
    
    func lifted(tileView: TileView) {
        tileView.x = nil
        tileView.y = nil
        tileView.onBoard = false
        validate()
    }
    
    func tapped(tileView: TileView) {
        fatalError()
    }
}
