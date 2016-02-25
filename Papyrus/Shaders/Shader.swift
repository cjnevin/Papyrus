//
//  Shader.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol Shader {
    var fillColor: UIColor? { get set }
    var textColor: UIColor? { get set }
    var strokeColor: UIColor? { get set }
    var strokeWidth: CGFloat? { get set }
}