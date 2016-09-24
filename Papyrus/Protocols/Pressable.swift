//
//  Pressable.swift
//  Papyrus
//
//  Created by Chris Nevin on 9/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

@objc protocol ObjCPressable {
    func pressed(with gesture: UILongPressGestureRecognizer)
}

protocol Pressable: Gesturable, ObjCPressable {
    var pressable: Bool { get set }
}

extension Pressable where Self: UIView {
    var pressable: Bool {
        get {
            return hasGesture(ofType: UILongPressGestureRecognizer.self)
        }
        set {
            if newValue {
                let longPress = register(gestureType: UILongPressGestureRecognizer.self, selector: #selector(pressed)) as! UILongPressGestureRecognizer
                longPress.minimumPressDuration = 0.001
            } else {
                unregister(gestureType: UILongPressGestureRecognizer.self)
            }
        }
    }
}
