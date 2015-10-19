//
//  PapyrusSpriteAnimations.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

extension TileSprite {
    
    func cancelAnimations() {
        if hasActions() {
            removeAllActions()
            if let point = animationPoint {
                position = point
            }
        }
    }
    
    private func animateMoveTo(point: CGPoint, completion: (() -> ())?) {
        cancelAnimations()
        animationPoint = point
        let move = SKAction.sequence([
            SKAction.scaleTo(1.0, duration: 0.1),
            SKAction.moveTo(point, duration: 0.1),
            SKAction.runBlock({
                self.animationPoint = nil
                completion?()
            })
        ])
        runAction(move)
    }
    
    func resetPosition(point: CGPoint) {
        cancelAnimations()
        if xScale != 1.0 { setScale(1.0) }
        position = point
    }
    
    func animatePickupFromRack(point: CGPoint) {
        zPosition = 100
        animateMoveTo(point, completion: nil)
    }
    
    func animateDropToRack(point: CGPoint) {
        if tile.value == 0 { tile.changeLetter("?") } // Reset letter
        animateMoveTo(point, completion: { () -> () in
            self.zPosition = 0
        })
    }
    
    func animateIllumination(illuminate: Bool) {
        let glow = SKAction.sequence([
            SKAction.colorizeWithColor(illuminate ? UIColor.Papyrus_TileIlluminated :
                UIColor.Papyrus_Tile, colorBlendFactor: 1.0, duration: 0.25)
        ])
        background.removeAllActions()
        background.runAction(glow)
    }
    
    func animateShrink(completion: (() -> ())? = nil) {
        position = CGPointZero
        zPosition = 100
        let drop = SKAction.sequence([
            SKAction.scaleTo(0.5, duration: 0.1),
            SKAction.scaleTo(0.45, duration: 0.05),
            SKAction.scaleTo(0.5, duration: 0.05),
            SKAction.runBlock({
                self.zPosition = 0
                completion?()
            })
        ])
        runAction(drop)
    }
    
    func animateGrow() {
        zPosition = 100
        let pickup = SKAction.sequence([
            SKAction.scaleTo(1.0, duration: 0.05),
            SKAction.scaleTo(1.1, duration: 0.025),
            SKAction.scaleTo(1.0, duration: 0.025),
        ])
        runAction(pickup)
    }
}
    