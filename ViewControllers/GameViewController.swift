//
//  GameViewController.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

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
		self.title = "Locution"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: "submit:")
    }

	func submit(sender: UIBarButtonItem) {
		if let (success, errors) = scene?.gameState?.submit() {
			if (!success) {
				// TODO: Refactor this
				// Present error (should pass this through a delegate?)
				var errorString = join("\n", errors)
				var alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
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
