//
//  TileTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import Papyrus

class TileTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTiles() {
        let totalTiles = TileConfiguration.map({$0.0}).reduce(0, combine: +)
        XCTAssert(Tile.createTiles().count == totalTiles)
    }

}
