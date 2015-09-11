//
//  Enums.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

enum Placement {
    case Bag
    case Rack
    case Held
    case Board
    case Fixed
}

enum ValidationError: ErrorType {
    case UnfilledSquare([Square?])
    case InvalidArrangement
    case InsufficientTiles
    case NoCenterIntersection
    case NoIntersection
    case UndefinedWord(String)
    case Message(String)
    case NoBoundary
    case NoPlayer
    case NoOptions
}