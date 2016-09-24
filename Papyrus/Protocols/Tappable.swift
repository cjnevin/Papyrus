//
//  Tappable.swift
//  Papyrus
//
//  Created by Chris Nevin on 9/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

@objc protocol ObjCTappable {
    func tapped(with gesture: UITapGestureRecognizer)
}

protocol Tappable: Gesturable, ObjCTappable {
    var tappable: Bool { get set }
}

extension Tappable where Self: UIView {
    var tappable: Bool {
        get {
            return hasGesture(ofType: UITapGestureRecognizer.self)
        }
        set {
            if newValue {
                register(gestureType: UITapGestureRecognizer.self, selector: #selector(tapped))
            } else {
                unregister(gestureType: UITapGestureRecognizer.self)
            }
        }
    }
}
