//
//  GameScene.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 Alive Mobile Group. All rights reserved.
//

import SpriteKit
import SceneKit

class GameScene: SKScene {
    var logicController: GameLogicController?
    var draggedSprite: TileSprite?
    var originalPoint: CGPoint?
    
    override func didMoveToView(view: SKView) {
        self.logicController = GameLogicController(view: view, node: self)
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            self.logicController?.touchStarted(atPoint:point);
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            self.logicController?.touchMoved(toPoint: point)
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = touches.anyObject().locationInNode?(self) {
            self.logicController?.touchEnded(atPoint: point, successful: true)
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if let point = self.originalPoint {
            self.logicController?.touchEnded(atPoint: point, successful: false)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
