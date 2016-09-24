//
//  Movable.swift
//  Papyrus
//
//  Created by Chris Nevin on 9/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

@objc protocol ObjCMovable {
    func moved(with gesture: UIPanGestureRecognizer)
}

protocol Movable: Gesturable, ObjCMovable {
    var movable: Bool { get set }
}

extension Movable where Self: UIView {
    var movable: Bool {
        get {
            return hasGesture(ofType: UIPanGestureRecognizer.self)
        }
        set {
            if newValue {
                register(gestureType: UIPanGestureRecognizer.self, selector: #selector(moved))
            } else {
                unregister(gestureType: UIPanGestureRecognizer.self)
            }
        }
    }
}
