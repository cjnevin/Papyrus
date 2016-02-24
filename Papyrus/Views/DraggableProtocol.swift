//
//  Draggable.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Draggable: class {
    var view: UIView { get }
    var initialPoint: CGPoint { get set }
    
    func registerDraggable() -> ()
    func unregisterDraggable() -> ()
    
    func didPress(gesture: UILongPressGestureRecognizer) -> ()
    func didPan(gesture: UIPanGestureRecognizer) -> ()
}

extension Draggable where Self: UIView {
    var view: UIView { return self }
    var parentView: UIView? { return view.superview }
    
    func registerDraggable() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.handler = { self.didPan($0 as! UIPanGestureRecognizer) }
        view.addGestureRecognizer(panGesture)
        let pressGesture = UILongPressGestureRecognizer()
        pressGesture.handler = { self.didPress($0 as! UILongPressGestureRecognizer) }
        pressGesture.minimumPressDuration = 0.001
        view.addGestureRecognizer(pressGesture)
    }
    
    func unregisterDraggable() {
        gestureRecognizers?.forEach{ self.removeGestureRecognizer($0) }
    }
    
    func didPress(pressGesture: UILongPressGestureRecognizer) {
        switch pressGesture.state {
        case .Began:
            initialPoint = view.center
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.parentView?.bringSubviewToFront(self.view)
                self.view.transform = CGAffineTransformMakeScale(0.80, 0.80)
            })
        case .Cancelled, .Ended, .Failed:
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            })
        default:
            break
        }
    }
    
    func didPan(panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translationInView(parentView)
        view.center = CGPointMake(initialPoint.x + translation.x, initialPoint.y + translation.y)
    }
}
