//
//  PapyrusSquareSpriteAnimations.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

extension SquareSprite {
    
    /// Glow a different color to signify an error.
    override func warningGlow() {
        self.warningGlow()
    }
    
    /// Initial placement, no shrink animation
    internal func placeTileSprite(t: TileSprite) {
        if tileSprite != nil { return }
        origin = CGPointZero
        t.removeFromParent()
        t.setScale(0.5)
        addChild(t)
        tileSprite = t
        square.tile = t.tile
    }
    
    /// Drop tile with a shrinking animation
    func animateDropTileSprite(t: TileSprite, originalPoint point: CGPoint, completion: (() -> ())?) {
        if tileSprite != nil { return }
        origin = point
        t.cancelAnimations()
        t.removeFromParent()
        addChild(t)
        tileSprite = t
        square.tile = t.tile
        t.animateShrink(completion)
    }
    
    /// Pickup tile, no animation.
    func pickupTileSprite() -> TileSprite? {
        guard let t = self.tileSprite where t.movable else { return nil }
        t.cancelAnimations()
        t.removeFromParent()
        t.position = position
        square.tile = nil
        tileSprite = nil
        return t
    }
}
