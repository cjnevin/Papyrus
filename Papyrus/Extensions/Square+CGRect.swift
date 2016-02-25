//
//  Square+CGRect.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

extension Square {
    func rectWithEdge(edge: CGFloat) -> CGRect {
        return CGRect(
            origin: CGPoint(x: edge * CGFloat(column), y: edge * CGFloat(row)),
            size: CGSize(width: edge, height: edge))
    }
}
