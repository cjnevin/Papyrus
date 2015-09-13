//
//  SquareTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import Papyrus

class SquareTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSquares() {
        let squares = Square.createSquares()
        XCTAssert(squares.flatten().count == PapyrusDimensions * PapyrusDimensions)
        
        let corner = squares.first!.first!
        XCTAssert(corner.debugDescription == "_")
        XCTAssert(corner == squares[0][0], "Equality should succeed")
        XCTAssert(corner.type == Square.Modifier.Wordx3, "Expected x3 for corner")
        XCTAssert(corner.type.wordMultiplier == 3, "Expected x3 for corner")
        XCTAssert(corner.wordMultiplier == 0, "Expected zero when no tile is there")
        corner.tile = Tile("T", 2)
        corner.tile?.placement = Placement.Board
        XCTAssert(corner.debugDescription == "T")
        XCTAssert(corner.wordMultiplier == 3, "Expected x3 when tile is there")
        XCTAssert(corner.letterValue == 2, "Expected 2 for letter value")
        corner.tile?.placement = Placement.Fixed
        XCTAssert(corner.wordMultiplier == 1, "Expected x1 when tile is there but fixed")
        corner.tile = nil
        
        let letterx2 = squares.first![3]
        XCTAssert(letterx2.type == Square.Modifier.Letterx2, "Expected x2")
        XCTAssert(letterx2.type.letterMultiplier == 2, "Expected x2")
        XCTAssert(letterx2.letterValue == 0, "Expected zero when no tile is there")
        letterx2.tile = Tile("Z", 10)
        letterx2.tile?.placement = Placement.Board
        XCTAssert(letterx2.wordMultiplier == 1, "Expected x1")
        XCTAssert(letterx2.letterValue == 20, "Expected 20")
        letterx2.tile?.placement = Placement.Fixed
        XCTAssert(letterx2.letterValue == 10, "Expected 10 when fixed")
        letterx2.tile = nil
        
        let wordx2 = squares[1][1]
        XCTAssert(wordx2.type == Square.Modifier.Wordx2, "Expected x2 for corner")
        XCTAssert(wordx2.type.wordMultiplier == 2, "Expected x2 for corner")
        XCTAssert(wordx2.wordMultiplier == 0, "Expected zero when no tile is there")
        wordx2.tile = Tile("T", 2)
        wordx2.tile?.placement = Placement.Board
        XCTAssert(wordx2.wordMultiplier == 2, "Expected x2 when tile is there")
        XCTAssert(wordx2.letterValue == 2, "Expected 2 for letter value")
        wordx2.tile?.placement = Placement.Fixed
        XCTAssert(wordx2.wordMultiplier == 1, "Expected x1 when tile is there but fixed")
        wordx2.tile = nil
        
        let letterx3 = squares[1][5]
        XCTAssert(letterx3.type == Square.Modifier.Letterx3, "Expected x3")
        XCTAssert(letterx3.type.letterMultiplier == 3, "Expected x3")
        XCTAssert(letterx3.letterValue == 0, "Expected zero when no tile is there")
        letterx3.tile = Tile("Z", 10)
        letterx3.tile?.placement = Placement.Board
        XCTAssert(letterx3.wordMultiplier == 1, "Expected x1")
        XCTAssert(letterx3.letterValue == 30, "Expected 30")
        letterx3.tile?.placement = Placement.Fixed
        XCTAssert(letterx3.letterValue == 10, "Expected 10 when fixed")
        letterx3.tile = nil
        
        let center = squares[7][7]
        XCTAssert(center.type == Square.Modifier.Center, "Expected x2 for corner")
        XCTAssert(center.type.wordMultiplier == 2, "Expected x2 for corner")
        XCTAssert(center.wordMultiplier == 0, "Expected zero when no tile is there")
        center.tile = Tile("T", 2)
        center.tile?.placement = Placement.Board
        XCTAssert(center.wordMultiplier == 2, "Expected x2 when tile is there")
        XCTAssert(center.letterValue == 2, "Expected 2 for letter value")
        center.tile?.placement = Placement.Fixed
        XCTAssert(center.wordMultiplier == 1, "Expected x1 when tile is there but fixed")
        center.tile = nil
        
        // Test operator
        XCTAssert(center != letterx2, "Equality should fail")
    }
}
