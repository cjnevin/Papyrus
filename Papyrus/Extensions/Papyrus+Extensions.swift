//
//  Papyrus+Extensions.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import PapyrusCore

extension Papyrus {
    /// - returns: All squares, flattened.
    var flattenedSquares: [Square]? {
        return squares.flatMap{ $0 }
    }
    /// - returns: Dimensions of board.
    var dimensions: Int {
        guard let flattenedSquares = flattenedSquares else {
            return 0
        }
        return Int(sqrt(Double(flattenedSquares.count)))
    }
    // TODO: Change this to Human player only.
    /// - returns: All tiles for current player.
    var rackTiles: [Tile]? {
        return Array(player?.tiles ?? [])
    }
}

