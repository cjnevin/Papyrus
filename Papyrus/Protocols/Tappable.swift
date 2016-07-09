//
//  Tappable.swift
//  Papyrus
//
//  Created by Chris Nevin on 9/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Tappable {
    func makeTappable(selector: Selector)
    func makeUntappable()
}

extension Tappable where Self: UIView {
    func makeTappable(selector: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        addGestureRecognizer(tapGesture)
    }
    
    func makeUntappable() {
        gestureRecognizers?.forEach { if $0 is UITapGestureRecognizer { removeGestureRecognizer($0) } }
    }
}
