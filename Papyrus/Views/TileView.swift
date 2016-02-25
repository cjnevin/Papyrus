//
//  TileView.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

protocol TileViewDelegate {
    func pickedUp(tileView: TileView)
    func frameForDropping(tileView: TileView) -> CGRect
}

class TileView: UIView {
    var draggable: Bool = false {
        didSet {
            draggable ? makeDraggable() : makeUndraggable()
        }
    }
    
    var initialFrame: CGRect!
    var initialPoint: CGPoint!
    var delegate: TileViewDelegate!
    weak var tile: Tile!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialPoint = center
        initialFrame = frame
    }
    
    init(frame: CGRect, tile: Tile, delegate: TileViewDelegate) {
        self.delegate = delegate
        self.tile = tile
        super.init(frame: frame)
        initialPoint = center
        initialFrame = frame
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        draggable = superview != nil
        contentMode = .Redraw
    }
    
    override func drawRect(rect: CGRect) {
        guard let tile = tile, context = UIGraphicsGetCurrentContext() else {
            return
        }
        let drawable = TileDrawable(tile: tile, rect: rect)
        drawable.draw(context)
    }
}

// MARK: - UIGestures

extension TileView : UIGestureRecognizerDelegate {
    func makeDraggable() {
        let panGesture = UIPanGestureRecognizer(target: self, action: "didPan:")
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        let pressGesture = UILongPressGestureRecognizer(target: self, action: "didPress:")
        pressGesture.minimumPressDuration = 0.001
        pressGesture.delegate = self
        addGestureRecognizer(pressGesture)
    }
    
    func makeUndraggable() {
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizers?.contains(gestureRecognizer) == true &&
            gestureRecognizers?.contains(otherGestureRecognizer) == true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    func didPress(pressGesture: UILongPressGestureRecognizer) {
        switch pressGesture.state {
        case .Began:
            self.delegate.pickedUp(self)
            let center = self.center
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.bounds = self.initialFrame
                self.center = center
                self.superview?.bringSubviewToFront(self)
                self.transform = CGAffineTransformMakeScale(0.9, 0.9)
            })
        case .Cancelled, .Ended, .Failed:
            let newFrame = self.delegate.frameForDropping(self)
            UIView.animateWithDuration(0.1, animations: {
                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.center = CGPoint(x: CGRectGetMidX(newFrame), y: CGRectGetMidY(newFrame))
                self.bounds = newFrame
            }, completion: { (complete) in
            })
        default:
            break
        }
    }
    
    func didPan(panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translationInView(superview)
        center = CGPointMake(center.x + translation.x, center.y + translation.y)
        panGesture.setTranslation(CGPointZero, inView: superview)
    }
}