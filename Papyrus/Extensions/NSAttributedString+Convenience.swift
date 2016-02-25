//
//  NSAttributedString+Convenience.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

extension NSAttributedString {
    convenience init(string: String, font: UIFont) {
        self.init(string: string, attributes: [NSFontAttributeName: font])
    }
}