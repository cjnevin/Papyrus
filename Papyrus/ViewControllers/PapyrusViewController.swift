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
    
    @IBOutlet var draggableView: DraggableView!
    @IBOutlet var boardView: BoardView!
    let watchdog = Watchdog(threshold: 0.2)
    var submit: UIBarButtonItem?
    var shuffle: UIBarButtonItem?
    var swap: UIBarButtonItem?
    var restart: UIBarButtonItem?
    
    var game: Papyrus!
    var unsubmittedMove: Move?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Papyrus"
        
        game = Papyrus(callback: lifecycleChanged)
        game.newGame()
        boardView.game = game
       
        submit = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: "submit:")
        restart = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "restart:")
        shuffle = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "shuffle:")
        swap = UIBarButtonItem(title: "Swap", style: .Plain, target: self, action: "swap:")
        
        shuffle?.enabled = false
        swap?.enabled = false
        restart?.enabled = false
        
        navigationItem.leftBarButtonItems = [shuffle!, swap!]
        navigationItem.rightBarButtonItems = [submit!, restart!]
    }
    
    func newGame() {
        lifecycleChanged(.Preparing)
        if Papyrus.dawg == nil {
            //Papyrus.operationQueue.addOperationWithBlock { () -> Void in
            //    Papyrus.dawg = Dawg.load(NSBundle.mainBundle().pathForResource("sowpods", ofType: "bin")!)!
            //    NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] () -> Void in
            //        self?.game.newGame()
            //        })
            //}
            //return
        }
        game.newGame()
    }
    
    func lifecycleChanged(lifecycle: Lifecycle) {
        enableButtons(false)
        switch (lifecycle) {
        case .NoGame:
            title = "Cleanup"
            
        case .Preparing:
            title = "Loading..."
        
        case .Ready:
            title = "Papyrus"
        
        case .EndedTurn(let move):
            title = "Ended Turn \(move)"
            if game.player?.difficulty == .Human {
                replaceRack()
            }
            
        case .ChangedPlayer:
            title = "Next Turn"
            print("Changed player \(game.playerIndex)")
            
        default:
            title = "Game Over"
            game.players.forEach { print("- \($0.difficulty) score: \($0.score)") }
            print("Winning score: \(game.players.map({$0.score}).maxElement())")
        }
    }
    
    func enableButtons(enabled: Bool) {
        let isHuman = game.player?.difficulty == .Human
        submit?.enabled = isHuman && enabled
        swap?.enabled = isHuman
        shuffle?.enabled = isHuman
        var gameOver = false
        if case .GameOver = game.lifecycle {
            gameOver = true
        }
        restart?.enabled = isHuman || gameOver
    }
    
    func replaceRack() {
        
    }
    
    func createBoard() {
        
    }
    
    // MARK: - Buttons
    
    func swap(sender: UIBarButtonItem) {
        guard let player = game.player else { return }
        player.returnTiles(player.rackTiles)
        game.draw(player)
    }
    
    func shuffle(sender: UIBarButtonItem) {
        
    }
    
    func restart(sender: UIBarButtonItem) {
        game.newGame()
    }
    
    func submit(sender: UIBarButtonItem) {
        guard let move = unsubmittedMove else { return }
        game.submitMove(move)
    }
    
}