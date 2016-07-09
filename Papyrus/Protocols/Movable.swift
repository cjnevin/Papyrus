//
//  Movable.swift
//  Papyrus
//
//  Created by Chris Nevin on 9/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Movable {
    func makeMovable(selector: Selector)
    func makeImmovable()
}

extension Movable where Self: UIView {
    func makeMovable(selector: Selector) {
        let panGesture = UIPanGestureRecognizer(target: self, action: selector)
        panGesture.delegate = self as? UIGestureRecognizerDelegate
        addGestureRecognizer(panGesture)
    }
    
    func makeImmovable() {
        gestureRecognizers?.forEach { if $0 is UIPanGestureRecognizer { removeGestureRecognizer($0) } }
    }
}
