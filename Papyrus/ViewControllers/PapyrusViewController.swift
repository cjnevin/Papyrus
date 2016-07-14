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
    class ButtonState {
        var skipEnabled: Bool = false
        var submitEnabled: Bool = false
        var swapping: Bool = false
        var tilesDropped: Bool = false
        var showingUnplayed: Bool = false
        var faded: Bool = false
    }

    let buttonState = ButtonState()
    
    let gameManager = GameManager.sharedInstance
    var presenter: GamePresenter?
    var firstRun: Bool = false
    
    var tilePickerViewController: TilePickerViewController!
    var tilesRemainingViewController: TilesRemainingViewController!
    
    @IBOutlet var tileContainerViews: [UIView]!
    @IBOutlet weak var tilePickerContainerView: UIView!
    @IBOutlet weak var tilesRemainingContainerView: UIView!
    @IBOutlet weak var blackoutView: UIView!
    
    @IBOutlet weak var gameView: GameView!
    @IBOutlet var submitButton: UIBarButtonItem!
    @IBOutlet var skipButton: UIBarButtonItem!
    @IBOutlet var swapButton: UIBarButtonItem!
    @IBOutlet var actionButton: UIBarButtonItem!
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController: TilePickerViewController = segue.inferredDestinationViewController() {
            tilePickerViewController = viewController
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
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTappedRack))
            doubleTap.numberOfTapsRequired = 2
            gameView.addGestureRecognizer(doubleTap)
            prepareGame()
            firstRun = true
        }
    }
    
    func doubleTappedRack(gesture: UITapGestureRecognizer) {
        if presenter?.rackPresenter.rect.contains(gesture.location(in: gameView)) == true {
            reset()
        }
    }
    
    func configureTitle() {
        if buttonState.swapping {
            let count = gameView.tileViews?.filter({ $0.highlighted }).count ?? 0
            title = count > 0 ? "\(count) Tile\(count > 1 ? "s" : "")" : "Choose Tiles"
        } else {
            if gameManager.game?.ended == true {
                title = "Game Over"
                return
            }
            guard let player = gameManager.game?.player else { return }
            if player is Human {
                title = "Your Turn"
            } else {
                title = "Thinking..."
            }
        }
    }
    
    func configureActions() {
        buttonState.skipEnabled = gameManager.game?.player is Human
        swapButton.isEnabled = buttonState.skipEnabled
        skipButton.isEnabled = buttonState.skipEnabled
        submitButton.isEnabled = buttonState.submitEnabled
        
        if buttonState.swapping {
            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItems = [swapButton]
            return
        }
        if buttonState.faded {
            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItems = nil
            return
        }
        navigationItem.leftBarButtonItems = [actionButton]
        if buttonState.tilesDropped {
            navigationItem.rightBarButtonItems = [submitButton]
        } else {
            navigationItem.rightBarButtonItems = [skipButton, swapButton]
        }
    }
    
    func fade(out: Bool, allExcept: [UIView]? = nil) {
        buttonState.faded = !out
        defer {
            UIView.animate(withDuration: 0.25) {
                self.blackoutView.alpha = out ? 0.0 : 0.4
                self.tileContainerViews.forEach({ $0.alpha = (out == false && allExcept?.contains($0) == true) ? 1.0 : 0.0 })
            }
        }
        defer {
            configureActions()
            configureTitle()
        }
        guard !out else {
            return
        }
        gameView.bringSubview(toFront: self.blackoutView)
        if let views = allExcept {
            views.forEach({ $0.superview?.bringSubview(toFront: $0) })
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
        configureActions()
        
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
        configureActions()
        
        gameManager.newGame(eventHandler: process) { [weak self] in
            self?.title = "Starting..."
            self?.gameManager.start()
        }
    }
    
    func gameOver(with winner: Player?) {
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
        switch event {
        case let .over(_, winner):
            updatePresenter()
            configureTitle()
            configureActions()
            gameOver(with: winner)
        case .turnBegan(_):
            updatePresenter()
            configureTitle()
            configureActions()
        case .turnEnded(_):
            updatePresenter()
            configureTitle()
            configureActions()
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
        fade(out: false, allExcept: [tilePickerContainerView])
    }
    
    func validate() {
        guard let tiles = gameView?.placedTiles, blanks = gameView?.blanks where tiles.count > 0 else {
            buttonState.submitEnabled = false
            buttonState.tilesDropped = false
            configureActions()
            return
        }
        buttonState.tilesDropped = true
        gameManager.validate(tiles: tiles, blanks: blanks) { [weak self] (solution) in
            self?.buttonState.submitEnabled = solution != nil
            self?.configureActions()
        }
    }
}


// MARK: Buttons
extension PapyrusViewController {
    func updateShownTiles() {
        guard let game = gameManager.game else { return }
        tilesRemainingViewController.prepareForPresentation(of: game.bag, players: buttonState.showingUnplayed ? game.players : nil)
    }
    
    func showBagTiles(_ sender: UIAlertAction) {
        buttonState.showingUnplayed = false
        updateShownTiles()
        fade(out: false, allExcept: [tilesRemainingContainerView])
    }
    
    func showUnplayedTiles(_ sender: UIAlertAction) {
        buttonState.showingUnplayed = true
        updateShownTiles()
        fade(out: false, allExcept: [tilesRemainingContainerView])
    }
    
    @IBAction func action(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Preferences", style: .default, handler: showPreferences))
        if gameManager.game?.ended == false {
            actionSheet.addAction(UIAlertAction(title: "Bag Tiles", style: .default, handler: showBagTiles))
            actionSheet.addAction(UIAlertAction(title: "Unplayed Tiles", style: .default, handler: showUnplayedTiles))
            if gameManager.game?.player is Human {
                actionSheet.addAction(UIAlertAction(title: "Shuffle", style: .default, handler: shuffle))
                actionSheet.addAction(UIAlertAction(title: "Hint", style: .default, handler: hint))
            }
        }
        actionSheet.addAction(UIAlertAction(title: gameManager.game?.ended == true ? "New Game" : "Restart", style: .destructive, handler: restart))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func skip(_ sender: UIBarButtonItem) {
        gameManager.skip()
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        guard let tiles = gameView?.placedTiles, blanks = gameView?.blanks where tiles.count > 0 else {
            return
        }
        gameManager.validate(tiles: tiles, blanks: blanks) { [weak self] (solution) in
            guard let solution = solution else { return }
            self?.gameManager.play(solution: solution)
        }
    }
    
    func hint(_ sender: UIAlertAction) {
        gameManager.hint { [weak self] (solution) in
            guard let strongSelf = self else { return }
            var message = ""
            if let solution = solution {
                message = "\((solution.horizontal ? "Horizontal" : "Vertical")) word '\(solution.word.uppercased())' can be placed \(solution.y + 1) down and \(solution.x + 1) across for a total score of \(solution.score)"
            } else {
                message = "Could not find any solutions, perhaps skip or swap letters?"
            }
            let alert = UIAlertController(title: "Hint", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            strongSelf.present(alert, animated: true, completion: nil)
        }
    }
    
    func reset() {
        spring() {
            self.gameView?.tileViews?.forEach({
                $0.frame = $0.initialFrame
                $0.x = nil
                $0.y = nil
                $0.onBoard = false
                if $0.isBlank {
                    $0.tile = Game.blankLetter
                }
            })
        }
        buttonState.tilesDropped = false
        buttonState.submitEnabled = false
        configureActions()
        configureTitle()
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
    
    @IBAction func swap(_ sender: UIBarButtonItem) {
        guard buttonState.swapping == false else {
            defer {
                buttonState.swapping = false
                fade(out: true)
                gameView.tileViews?.forEach({ (tileView) in
                    tileView.tappable = false
                    tileView.draggable = true
                })
            }
            guard let toSwap = gameView.tileViews?.filter({ $0.highlighted }).flatMap({ $0.tile }) where toSwap.count > 0 else {
                return
            }
            let _ = gameManager.game?.swap(tiles: toSwap)
            return
        }
        guard gameManager.game?.player is Human else {
            return
        }
        reset()
        buttonState.swapping = true
        fade(out: false, allExcept: gameView.tileViews)
        gameView.tileViews?.forEach({ (tileView) in
            tileView.tappable = true
            tileView.draggable = false
        })
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
                if tileViews[index].isBlank {
                    tileViews[index].tile = Game.blankLetter
                }
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
        if let intersected = gameView?.tileViews?.filter({ $0 != tileView && $0.initialFrame.intersects(tileView.frame) }),
            closest = intersected.min(isOrderedBefore: { abs($0.initialFrame.midX - tileView.initialFrame.midX) < abs($1.initialFrame.midX - tileView.initialFrame.midX) }),
            closestIndex = gameView?.tileViews?.index(of: closest),
            tileIndex = gameView?.tileViews?.index(of: tileView),
            startIndex = gameView?.tileViews?.startIndex {
            let current = startIndex.distance(to: tileIndex)
            let new = startIndex.distance(to: closestIndex)
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
        tileView.highlighted = !tileView.highlighted
        configureTitle()
    }
}
