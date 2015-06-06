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

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Pick a size for the scene */
		let scene = GameScene(fileNamed:"GameScene")
		// Configure the view.
		if let skView = self.view as? SKView {
			skView.showsFPS = false
			skView.showsNodeCount = false
			
			/* Sprite Kit applies additional optimizations to improve rendering performance */
			skView.ignoresSiblingOrder = false //true is faster
			
			/* Set the scale mode to scale to fit the window */
			scene.scaleMode = SKSceneScaleMode.ResizeFill
			scene.viewController = self
			
			skView.presentScene(scene)
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
