//
//  PapyrusTests.swift
//  PapyrusTests
//
//  Created by Chris Nevin on 14/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import Papyrus

class PapyrusTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGame() {
        let instance = Papyrus.sharedInstance
        instance.newGame { (state, game) -> () in
            switch state {
            case .Cleanup:
                print("Cleanup")
            case .Preparing:
                print("Preparing")
            case .Ready:
                print("Ready")
                
                XCTAssert(instance.squares.flatMap{$0}.count == PapyrusDimensions * PapyrusDimensions)
                
                let totalTiles = Papyrus.TileConfiguration.map({$0.0}).reduce(0, combine: +)
                XCTAssert(instance.tiles.count == totalTiles)
                try! instance.createPlayer()
                XCTAssert(instance.tiles.placedCount(.Bag) == totalTiles - PapyrusRackAmount)
                XCTAssert(instance.tileIndex == PapyrusRackAmount)
                XCTAssert(instance.rackTiles.count == PapyrusRackAmount)
                
                XCTAssert(54 == instance.runs(withTiles: instance.rackTiles).array.count)
                
                let first = instance.squares[0][0].offset
                XCTAssert(first.advance(.Horizontal, amount: PapyrusDimensions - 1)?.x == PapyrusDimensions)
                XCTAssert(first.advance(.Horizontal, amount: PapyrusDimensions) == nil)
                XCTAssert(first.advance(.Vertical, amount: PapyrusDimensions - 1)?.y == PapyrusDimensions)
                XCTAssert(first.advance(.Vertical, amount: PapyrusDimensions) == nil)
                
                XCTAssert([(1,1)].toOffsets().count == 1)
                XCTAssert([(0,-1)].toOffsets().count == 0)
                XCTAssert([(-1,0)].toOffsets().count == 0)
                XCTAssert([(0,0)].toOffsets().count == 1)
                XCTAssert([(PapyrusDimensions + 1,PapyrusDimensions)].toOffsets().count == 0)
                XCTAssert([(PapyrusDimensions,PapyrusDimensions + 1)].toOffsets().count == 0)
                
                
            case .Completed:
                print("Completed")
            }
        }
    }
    
}
