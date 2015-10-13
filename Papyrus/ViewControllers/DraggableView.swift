//
//  DraggableView.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit

class DraggableView: UIView {
    
    @IBOutlet var boardView: BoardView!
    var tileViews = [TileView]()
    var held: TileView?
    
    func tileView(atPoint point: CGPoint?) -> TileView? {
        if point == nil { return nil }
        return tileViews.filter({ $0.frame.contains(point!) }).first
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let point = getPoint(inTouches: touches), tile = tileView(atPoint: point) else { return }
        if boardView.frame.contains(point) {
            // Grow tile first
            tile.layer.contentsScale = 1.0
        }
        held = tile
        tile.center = point
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let point = getPoint(inTouches: touches), tile = held else { return }
        tile.center = point
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let point = getPoint(inTouches: touches), tile = held else { return }
        tile.center = point
        if boardView.frame.contains(point) {
            tile.layer.contentsScale = 0.5
        }
        held = nil
    }
    
    /// - returns: First point in touches set
    private func getPoint(inTouches touches: Set<UITouch>) -> CGPoint? {
        return touches.first?.locationInView(self)
    }
    
}