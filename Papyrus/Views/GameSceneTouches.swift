//
//  GameSceneTouches.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

extension GameScene {
    var heldTile: TileSprite? {
        return tileSprites.filter({$0.tile.placement == Tile.Placement.Held}).first
    }
    
    var heldOrigin: CGPoint? {
        return heldTile?.origin
    }
    
    func point(inTouches touches: Set<UITouch>?) -> CGPoint? {
        guard let point = touches?.first?.locationInNode(self) else { return nil }
        return point
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let point = point(inTouches: touches) {
            for child in children {
                if let tileSprite = child as? TileSprite where tileSprite.containsPoint(point) && !tileSprite.hasActions() {
                    tileSprite.origin = tileSprite.position
                    tileSprite.tile.placement = .Held
                    tileSprite.tile.square = nil
                    tileSprite.animatePickupFromRack(point) //resetPosition(point)
                    break
                } else if let squareSprite = child as? SquareSprite where squareSprite.containsPoint(point) {
                    if let tileSprite = squareSprite.pickupTileSprite() {
                        tileSprite.origin = squareSprite.origin
                        tileSprite.tile.placement = .Held
                        tileSprite.tile.square = nil
                        tileSprite.animateGrow()
                        addChild(tileSprite)
                        break
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let point = point(inTouches: touches), tileSprite = heldTile {
            tileSprite.resetPosition(point)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let point = point(inTouches: touches), tileSprite = heldTile, origin = heldOrigin else { return }
        var found = false
        var fallback: (square: SquareSprite?, overlap: CGFloat) = (nil, 0) // Closest square to drop tile if hovered square is filled
        for squareSprite in (children.filter({$0 is SquareSprite}) as! [SquareSprite]).filter({$0.isEmpty() && $0.intersectsNode(tileSprite)}) {
            if squareSprite.frame.contains(point) {
                tileSprite.tile.placement = .Board
                tileSprite.tile.square = squareSprite.square
                squareSprite.animateDropTileSprite(tileSprite, originalPoint: origin, completion: { () -> () in
                    if tileSprite.tile.letter == "?" {
                        self.actionDelegate?.pickLetter({ (letter) -> () in
                            tileSprite.changeLetter(letter)
                        })
                    }
                })
                found = true
                break
            }
            let intersection = CGRectIntersection(squareSprite.frame, tileSprite.frame)
            let overlap = CGRectGetWidth(intersection) + CGRectGetHeight(intersection)
            fallback = overlap > fallback.overlap ? (squareSprite, overlap) : fallback
        }
        if !found {
            if let squareSprite = fallback.square {
                squareSprite.animateDropTileSprite(tileSprite, originalPoint: origin, completion: nil)
                tileSprite.tile.placement = .Board
                tileSprite.tile.square = squareSprite.square
            } else {
                tileSprite.animateDropToRack(origin) //resetPosition(origin)
                tileSprite.tile.placement = .Rack
                tileSprite.tile.square = nil
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let point = point(inTouches: touches), tileSprite = heldTile {
            let origin = heldOrigin ?? point
            tileSprite.resetPosition(origin)
            tileSprite.tile.placement = .Rack
            tileSprite.tile.square = nil
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}