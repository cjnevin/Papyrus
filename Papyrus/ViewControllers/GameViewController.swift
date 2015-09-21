//
//  GameViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/07/2015.
//  Copyright (c) 2015 CJNevin. All rights reserved.
//

import UIKit
import SpriteKit
import PapyrusCore

class GameViewController: UIViewController, GameSceneDelegate, UITextFieldDelegate {
    @IBOutlet var skView: SKView?
    var scene: GameScene?
    var unsubmittedMove: Move?
    var submit: UIBarButtonItem?
    var shuffle: UIBarButtonItem?
    var swap: UIBarButtonItem?
    var restart: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            scene
        }
        if let view = skView, gscene = GameScene(fileNamed:"GameScene") {
            gscene.scaleMode = SKSceneScaleMode.ResizeFill
            view.showsFPS = false
            view.showsNodeCount = false
            view.ignoresSiblingOrder = false //true is faster
            view.presentScene(gscene)
            scene = gscene
            gscene.actionDelegate = self
        }
        title = "Papyrus"
        
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if scene?.game.inProgress == false {
            newGame()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Game
    
    func setup() {
        guard let scene = scene else { return }
        enableButtons(false)
        scene.game.newGame { [weak self] (lifecycle, game) -> () in
            guard let this = self, scene = this.scene else { return }
            this.enableButtons(false)
            switch (lifecycle) {
            case .Cleanup:
                this.title = "Cleanup"
            case .Preparing:
                this.title = "Loading..."
            case .Ready:
                this.title = "Papyrus"
                this.enableButtons(false)
                game.createPlayer() // Me
                game.createPlayer(Difficulty.Champion) // AI
            case .EndedTurn:
                this.title = "Ended Turn"
            case .ChangedPlayer:
                this.title = "Next Turn"
            default:
                this.title = "Complete"
            }
            scene.changed(lifecycle)
        }
    }
    
    func newGame() {
        enableButtons(false)
        if Papyrus.dawg == nil {
            GameScene.operationQueue.addOperationWithBlock { () -> Void in
                Papyrus.dawg = Dawg.load(NSBundle.mainBundle().pathForResource("output", ofType: "json")!)!
                NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] () -> Void in
                    self?.setup()
                })
            }
        } else {
            setup()
        }
    }
    
    func enableButtons(enabled: Bool) {
        submit?.enabled = enabled
        swap?.enabled = scene?.game.playerIndex == 0
        shuffle?.enabled = scene?.game.playerIndex == 0
        restart?.enabled = scene?.game.playerIndex == 0
    }
    
    func swap(sender: UIBarButtonItem) {
        guard let player = scene?.game.player, tiles = scene?.game.player?.rackTiles else { return }
        player.returnTiles(tiles)
        scene?.game.draw(player)
    }
    
    func shuffle(sender: UIBarButtonItem) {
        
    }
    
    func restart(sender: UIBarButtonItem) {
        newGame()
    }
    
    func submit(sender: UIBarButtonItem) {
        guard let move = unsubmittedMove else { return }
        scene?.submit(move)
    }
    
    
    // MARK:- Action Delegate
    
    func invalidMove(error: ErrorType?) {
        enableButtons(false)
        unsubmittedMove = nil
    }
    
    func validMove(move: Move) {
        enableButtons(move.total > 0)
        unsubmittedMove = move
    }
    
    func pickLetter(completion: (Character) -> ()) {
        let alertController = UIAlertController(title: "Enter Replacement Letter", message: nil, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            if let letter = alertController.textFields?.first?.text?.lowercaseString.characters.first {
                completion(letter)
            }
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
            textField.delegate = self
        }
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Filter alphabet, allow only one character
        let charSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").invertedSet
        let filtered = string.componentsSeparatedByCharactersInSet(charSet).joinWithSeparator("")
        let current: NSString = textField.text ?? ""
        let newLength = current.stringByReplacingCharactersInRange(range, withString: string).lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        return filtered == string && (newLength == 0 || newLength == 1)
    }
}
