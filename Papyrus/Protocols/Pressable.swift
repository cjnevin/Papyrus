//
//  Pressable.swift
//  Papyrus
//
//  Created by Chris Nevin on 9/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Pressable {
    func makePressable(selector: Selector)
    func makeUnpressable()
}

extension Pressable where Self: UIView {
    func makePressable(selector: Selector) {
        let pressGesture = UILongPressGestureRecognizer(target: self, action: selector)
        pressGesture.minimumPressDuration = 0.001
        pressGesture.delegate = self as? UIGestureRecognizerDelegate
        addGestureRecognizer(pressGesture)
    }
    
    func makeUnpressable() {
        gestureRecognizers?.forEach { if $0 is UILongPressGestureRecognizer { removeGestureRecognizer($0) } }
    }
}
