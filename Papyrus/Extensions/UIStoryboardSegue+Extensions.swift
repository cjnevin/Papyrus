//
//  UIStoryboardSegue+Extensions.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Segueable {
    static var segueIdentifier: String { get }
}

extension UIStoryboardSegue {
    func inferredDestinationViewController<T: Segueable>() -> T? {
        if T.segueIdentifier == identifier {
            return destinationViewController as? T
        }
        return nil
    }
}

extension UIViewController: Segueable {
    class var segueIdentifier: String {
        return String(self) + "Segue"
    }
}
