//
//  GameViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/07/2015.
//  Copyright (c) 2015 CJNevin. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameSceneProtocol, UITextFieldDelegate {
    @IBOutlet var skView: SKView?
    var scene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: "submit:")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "restart:")
        self.restart(navigationItem.leftBarButtonItem!)
    }
    
    func pickLetter(completion: (Character) -> ()) {
        let alertController = UIAlertController(title: "Enter Replacement Letter", message: nil, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            if let letter = alertController.textFields?.first?.text?.characters.first {
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
        let charSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZ").invertedSet
        let filtered = "".join(string.componentsSeparatedByCharactersInSet(charSet))
        let current: NSString = textField.text ?? ""
        let newLength = current.stringByReplacingCharactersInRange(range, withString: string).lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        return filtered == string && (newLength == 0 || newLength == 1)
    }
    
    func restart(sender: UIBarButtonItem) {
        scene?.resetGame()
        Papyrus.newGame { (state: Papyrus.State, game: Papyrus?) -> () in
            self.scene?.changedGameState(state, game: game)
            switch (state) {
            case .Preparing:
                self.title = "Loading..."
                sender.enabled = false
                self.navigationItem.rightBarButtonItem?.enabled = false
            case .Ready:
                self.title = "Score: 0"
                sender.enabled = true
                self.navigationItem.rightBarButtonItem?.enabled = true
            default:
                self.title = "Complete"
            }
        }
    }
    
    func submit(sender: UIBarButtonItem) {
        do {
            try scene?.submitPlay()
        } catch (let err as ValidationError) {
            let alertController = UIAlertController(title: "Error", message: err.rawValue, preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            presentViewController(alertController, animated: true, completion: nil)
        } catch _ {
            
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
}
