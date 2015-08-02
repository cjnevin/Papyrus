//
//  PapyrusSquareSpriteAnimations.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

extension SquareSprite {
    override func warningGlow() {
        background.warningGlow()
    }
    
    private func placeTileSprite(t: TileSprite) {
        // Initial placement, no animation
        if tileSprite == nil {
            origin = CGPointZero
            t.removeFromParent()
            t.setScale(0.5)
            addChild(t)
            tileSprite = t
        }
    }
    
    func animateDropTileSprite(t: TileSprite, originalPoint point: CGPoint, completion: (() -> ())?) {
        if tileSprite == nil {
            origin = point
            t.cancelAnimations()
            t.removeFromParent()
            addChild(t)
            tileSprite = t
            t.animateShrink(completion)
        }
    }
    
    func pickupTileSprite() -> TileSprite? {
        guard let t = self.tileSprite where t.movable else {
            return nil
        }
        t.cancelAnimations()
        t.removeFromParent()
        t.position = position
        tileSprite = nil
        return t
    }
}
