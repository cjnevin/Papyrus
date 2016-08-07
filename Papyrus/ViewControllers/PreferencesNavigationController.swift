//
//  PreferencesNavigationController.swift
//  Papyrus
//
//  Created by Chris Nevin on 8/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

class PreferencesNavigationController: UINavigationController {
    var preferencesViewController: PreferencesViewController! {
        return self.viewControllers.first as! PreferencesViewController
    }
}
