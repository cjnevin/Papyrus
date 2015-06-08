//
//  GameViewController.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameSceneProtocol, UITextFieldDelegate {
	@IBOutlet var skView: SKView?
	var scene: GameScene?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Pick a size for the scene */
		let gscene = GameScene(fileNamed:"GameScene")
		// Configure the view.
		if let view = skView {
			view.showsFPS = false
			view.showsNodeCount = false
			
			/* Sprite Kit applies additional optimizations to improve rendering performance */
			view.ignoresSiblingOrder = false //true is faster
			
			/* Set the scale mode to scale to fit the window */
			gscene.scaleMode = SKSceneScaleMode.ResizeFill
			view.presentScene(gscene)
		}
		self.scene = gscene
		gscene.actionDelegate = self
		self.title = "Locution"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: "submit:")
	}
	
	func pickLetter(completion: (String) -> ()) {
		let alertController = UIAlertController(title: "Enter Replacement Letter", message: nil, preferredStyle: .Alert)
		let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
			if let textField = alertController.textFields?[0] as? UITextField {
				completion(textField.text)
			}
		}
		alertController.addTextFieldWithConfigurationHandler { (textField) in
			textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
			textField.delegate = self
		}
		alertController.addAction(OKAction)
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		// Filter alphabet, allow only one character
		let charSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZ").invertedSet
		let filtered = join("", string.componentsSeparatedByCharactersInSet(charSet))
		let current: NSString = textField.text
		let newLength = current.stringByReplacingCharactersInRange(range, withString: string).lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
		return filtered == string && (newLength == 0 || newLength == 1)
	}
	
	func submit(sender: UIBarButtonItem) {
		if let (success, errors) = scene?.gameState?.submit() {
			if (!success) {
				// TODO: Refactor this
				// Present error (should pass this through a delegate?)
				var errorString = join("\n", errors)
				var alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
				let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
				}
				alertController.addAction(OKAction)
				self.presentViewController(alertController, animated: true, completion: nil)
			} else {
				self.navigationItem.title = "Score: \(scene!.gameState!.game.currentPlayer!.score)"
			}
		}
	}
	
	
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
