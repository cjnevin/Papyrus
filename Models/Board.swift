//
//  Board.swift
//  Locution
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 Alive Mobile Group. All rights reserved.
//

import Foundation

class Board {
    let dimensions: Int
    let totalTiles: Int
    var rack: [Tile]
    var bagTiles: [Tile]
    let squares: [Square]
    
    class Tile {
        let letter: String
        let value: Int
        init(letter: String, value: Int) {
            self.letter = letter
            self.value = value
        }
    }
    
    class Square {
        enum SquareType {
            case Normal
            case Center
            case DoubleLetter
            case TripleLetter
            case DoubleWord
            case TripleWord
        }
        
        let squareType: SquareType
        let point: (Int, Int)
        var tile: Tile?
        
        init(squareType: SquareType, point: (Int, Int)) {
            self.squareType = squareType
            self.point = point
        }
        
        func fill(tile: Tile?) {
            self.tile = tile
        }
        
        func value() -> Int {
            var multiplier: Int
            switch (squareType) {
            case .DoubleLetter:
                multiplier = 2
            case .TripleLetter:
                multiplier = 3
            default:
                multiplier = 1
            }
            if let value = self.tile?.value {
                return value * multiplier;
            }
            return 0
        }
        
        func wordMultiplier() -> Int {
            switch (squareType) {
            case .Center, .DoubleWord:
                return 2
            case .TripleWord:
                return 3
            default:
                return 1
            }
        }
        
        class func values(accumulator: Int, square: Square) -> Int {
            return square.value() + accumulator;
        }
    }
    
    // MARK: - Lifecycle
    
    init(dimensions: Int) {
        self.dimensions = dimensions;
        
        self.bagTiles = [Tile]()
        self.bagTiles.extend(Array(count: 9, repeatedValue: Tile(letter: "A", value: 1)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "B", value: 3)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "C", value: 3)))
        self.bagTiles.extend(Array(count: 4, repeatedValue: Tile(letter: "D", value: 2)))
        self.bagTiles.extend(Array(count: 12, repeatedValue: Tile(letter: "E", value: 1)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "F", value: 4)))
        self.bagTiles.extend(Array(count: 3, repeatedValue: Tile(letter: "G", value: 2)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "H", value: 4)))
        self.bagTiles.extend(Array(count: 9, repeatedValue: Tile(letter: "I", value: 1)))
        self.bagTiles.extend(Array(count: 1, repeatedValue: Tile(letter: "J", value: 8)))
        self.bagTiles.extend(Array(count: 1, repeatedValue: Tile(letter: "K", value: 5)))
        self.bagTiles.extend(Array(count: 4, repeatedValue: Tile(letter: "L", value: 1)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "M", value: 3)))
        self.bagTiles.extend(Array(count: 6, repeatedValue: Tile(letter: "N", value: 1)))
        self.bagTiles.extend(Array(count: 8, repeatedValue: Tile(letter: "O", value: 1)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "P", value: 3)))
        self.bagTiles.extend(Array(count: 1, repeatedValue: Tile(letter: "Q", value: 10)))
        self.bagTiles.extend(Array(count: 6, repeatedValue: Tile(letter: "R", value: 1)))
        self.bagTiles.extend(Array(count: 4, repeatedValue: Tile(letter: "S", value: 1)))
        self.bagTiles.extend(Array(count: 6, repeatedValue: Tile(letter: "T", value: 1)))
        self.bagTiles.extend(Array(count: 4, repeatedValue: Tile(letter: "U", value: 1)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "V", value: 4)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "W", value: 4)))
        self.bagTiles.extend(Array(count: 1, repeatedValue: Tile(letter: "X", value: 10)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "Y", value: 4)))
        self.bagTiles.extend(Array(count: 1, repeatedValue: Tile(letter: "Z", value: 10)))
        self.bagTiles.extend(Array(count: 2, repeatedValue: Tile(letter: "?", value: 0)))
        self.totalTiles = self.bagTiles.count
        
        self.rack = [Tile]()
        for _ in 1...7 {
            var index = Int(arc4random_uniform(UInt32(self.bagTiles.count)))
            self.rack.append(self.bagTiles[index])
            self.bagTiles.removeAtIndex(index)
        }
        
        self.squares = [Square]()
        var middle = dimensions/2+1
        for row in 1...dimensions {
            for col in 1...dimensions {
                var point = (row, col)
                if symmetrical(point, offset: 0, offset2: 0, middle: middle) {
                    squares.append(Square(squareType: .Center, point: point))
                } else if symmetrical(point, offset: middle - 1, offset2: middle - 1, middle: middle) {
                    squares.append(Square(squareType: .TripleWord, point: point))
                } else if symmetrical(point, offset: 1, offset2: 1, middle: middle) || symmetrical(point, offset: 1, offset2: 5, middle: middle) || symmetrical(point, offset: 0, offset2: 4, middle: middle) || symmetrical(point, offset: middle - 1, offset2: 4, middle: middle) {
                    squares.append(Square(squareType: .DoubleLetter, point: point))
                } else if symmetrical(point, offset: 2, offset2: 6, middle: middle) || symmetrical(point, offset: 2, offset2: 2, middle: middle) {
                    squares.append(Square(squareType: .TripleLetter, point: point))
                } else if symmetrical(point, offset: 3, offset2: 3, middle: middle) || symmetrical(point, offset: 4, offset2: 4, middle: middle) || symmetrical(point, offset: 5, offset2: 5, middle: middle) || symmetrical(point, offset: 6, offset2: 6, middle: middle) {
                    squares.append(Square(squareType: .DoubleWord, point: point))
                }
                else {
                    squares.append(Square(squareType: .Normal, point: point))
                }
            }
        }
    }
    
    func symmetrical(point: (Int, Int), offset: Int, offset2: Int, middle: Int) -> Bool {
        switch (point) {
        case
        (middle - offset, middle - offset2),
        (middle - offset, middle + offset2),
        (middle + offset, middle + offset2),
        (middle + offset, middle - offset2),
        (middle - offset2, middle - offset),
        (middle - offset2, middle + offset),
        (middle + offset2, middle + offset),
        (middle + offset2, middle - offset):
            return true
        default:
            return false
        }
    }
}