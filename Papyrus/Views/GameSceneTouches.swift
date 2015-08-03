//
//  GameSceneTouches.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    // MARK: - Touches
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        do { try pickup(atPoint: point(inTouches: touches)) }
        catch { print("Error picking up sprite") }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let point = point(inTouches: touches) else { return }
        heldTile?.resetPosition(point)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        do { try drop(atPoint: point(inTouches: touches)) }
        catch { print("Error dropping sprite") }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        do { try dropInRack(false, atPoint: heldOrigin ?? point(inTouches: touches)) }
        catch { print("Error dropping in rack") }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // MARK: - Helpers
    
    var heldOrigin: CGPoint? {
        return heldTile?.origin
    }
    
    private func point(inTouches touches: Set<UITouch>?) -> CGPoint? {
        return touches?.first?.locationInNode(self)
    }
    
    private func intersectedSquareSprite(point: CGPoint) -> SquareSprite? {
        // Check if we are holding a tile, if not return
        guard let tileSprite = heldTile else { return nil }
        // Function to calculate intersection
        func intersection(item: SquareSprite) -> CGFloat {
            let intersection = CGRectIntersection(item.frame, tileSprite.frame)
            return CGRectGetHeight(intersection) + CGRectGetWidth(intersection)
        }
        // Filter empty squares that intersect our tile
        let s = squareSprites.filter({ $0.isEmpty() && $0.intersectsNode(tileSprite) })
        if s.count == 0 { return nil }
        return s.filter({ $0.frame.contains(point) }).first ??
            s.maxElement({ return intersection($0) < intersection($1) })
    }
    
    private func dropInRack(animated: Bool? = true, atPoint point: CGPoint?) throws {
        guard let point = point, tile = heldTile else { return }
        animated == true ? tile.animateDropToRack(point) : tile.resetPosition(point)
        try tile.tile.place(.Rack)
    }
    
    private func pickup(atPoint point: CGPoint?) throws {
        guard let point = point else { return }
        if let s = squareSprites.filter({ $0.containsPoint(point) && $0.tileSprite != nil }).first, t = s.pickupTileSprite() {
            // Pickup from board
            t.origin = s.origin
            try t.tile.place(.Held)
            t.animateGrow()
            addChild(t)
        } else if let t = tileSprites.filter({ $0.containsPoint(point) && !$0.hasActions() }).first {
            // Pickup from rack
            t.origin = t.position
            try t.tile.place(.Held)
            t.animatePickupFromRack(point)
        }
    }
    
    private func drop(atPoint point: CGPoint?) throws {
        guard let point = point, tile = heldTile, origin = heldOrigin else { return }
        guard let emptySquare = intersectedSquareSprite(point) else {
            try dropInRack(atPoint: origin)
            return
        }
        // Drop on board
        emptySquare.animateDropTileSprite(tile, originalPoint: origin, completion: nil)
        try tile.tile.place(.Board, owner: nil, square: emptySquare.square)
    }
}