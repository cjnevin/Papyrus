//
//  Gesturable.swift
//  Papyrus
//
//  Created by Chris Nevin on 24/9/16.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Gesturable {
    @discardableResult func register(gestureType: UIGestureRecognizer.Type, selector: Selector) -> UIGestureRecognizer
    func unregister(gestureType: UIGestureRecognizer.Type)
    func hasGesture(ofType gestureType: UIGestureRecognizer.Type) -> Bool
}

extension Gesturable where Self: UIView {
    @discardableResult func register(gestureType: UIGestureRecognizer.Type, selector: Selector) -> UIGestureRecognizer {
        let gesture = gestureType.init(target: self, action: selector)
        gesture.delegate = self as? UIGestureRecognizerDelegate
        addGestureRecognizer(gesture)
        return gesture
    }
    
    func unregister(gestureType: UIGestureRecognizer.Type) {
        gestureRecognizers?.forEach { if type(of: $0) == gestureType { removeGestureRecognizer($0) } }
    }
    
    func hasGesture(ofType gestureType: UIGestureRecognizer.Type) -> Bool {
        return (gestureRecognizers?.filter { type(of: $0) == gestureType }.count ?? 0) > 0
    }
}
