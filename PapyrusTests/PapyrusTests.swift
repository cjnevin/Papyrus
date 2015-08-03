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
    
    func runPlayerTests(instance: Papyrus) {
        XCTAssert(Player(score: 10).score == 10)
        XCTAssert(Player().score == 0)
    }
    
    func runTileTests(instance: Papyrus) {
        let totalTiles = Papyrus.TileConfiguration.map({$0.0}).reduce(0, combine: +)
        XCTAssert(instance.tiles.count == totalTiles)
        try! instance.createPlayer()
        XCTAssert(instance.tiles.placedCount(.Bag) == totalTiles - PapyrusRackAmount)
        XCTAssert(instance.tileIndex == PapyrusRackAmount)
        XCTAssert(instance.rackTiles.count == PapyrusRackAmount)
        XCTAssert(instance.droppedTiles.count == 0)
        let tile = instance.rackTiles.first!
        XCTAssert(String(tile.letter) == tile.debugDescription)
    }
    
    func runTileErrorTests(instance: Papyrus) {
        let tile = instance.rackTiles.first!
        let placement = tile.placement
        // Test bag with owner error
        do {
            try tile.place(.Bag, owner: instance.player!)
        } catch {
            XCTAssert(tile.placed(placement) == tile)
        }
        // Test rack with no owner error
        do {
            tile.owner = nil
            try tile.place(.Rack, owner: nil)
        } catch {
            XCTAssert(tile.placed(placement) == tile)
        }
        // Test board with no square error
        do {
            tile.owner = nil
            try tile.place(.Board, owner: nil, square: nil)
        } catch {
            XCTAssert(tile.placed(placement) == tile)
        }
        // Test held with square error
        do {
            try tile.place(.Held, owner: nil, square: instance.squares[0][0])
        } catch {
            XCTAssert(tile.placed(placement) == tile)
        }
    }
    
    func runRunsTests(instance: Papyrus) {
        XCTAssert(54 == instance.currentRuns().array.count)
    }
    
    func runSquareTests(instance: Papyrus) {
        let sqs = instance.squares
        
        XCTAssert(sqs.flatMap{$0}.count == PapyrusDimensions * PapyrusDimensions)
        
        let sq = sqs[0][0]
        XCTAssert(sq.at(x: 2, y: 2, inArray: sqs) != nil)
        XCTAssert(sq.at(x: PapyrusDimensions + 1, y: 0, inArray: sqs) == nil)
        XCTAssert(sq.at(x: 0, y: PapyrusDimensions + 1, inArray: sqs) == nil)
        XCTAssert(sq.at(x: -1, y: 0, inArray: sqs) == nil)
        XCTAssert(sq.at(x: 0, y: -1, inArray: sqs) == nil)
        XCTAssert(sq == sq)
        /*
        TODO: Fix next/prev methods
        XCTAssert(sqs[2][1] == sq.next(.Horizontal, inArray: sqs))
        XCTAssert(sqs[1][2] == sq.next(.Vertical, inArray: sqs))
        XCTAssert(sqs[2][1] == sq.advance(.Horizontal, amount: 1, inArray: sqs))
        XCTAssert(sqs[1][2] == sq.advance(.Vertical, amount: 1, inArray: sqs))
        
        let sq2 = sqs[1][1]
        XCTAssert(sqs[1][0] == sq2.prev(.Horizontal, inArray: sqs))
        
        XCTAssert(sq.at(x: 0, y: 1, inArray: sqs) == sq.prev(.Horizontal, inArray: sqs))
        XCTAssert(sq.at(x: 1, y: 0, inArray: sqs) == sq.prev(.Vertical, inArray: sqs))
        XCTAssert(sq.at(x: 0, y: 1, inArray: sqs) == sq.advance(.Horizontal, amount: -1, inArray: sqs))
        XCTAssert(sq.at(x: 1, y: 0, inArray: sqs) == sq.advance(.Vertical, amount: -1, inArray: sqs))
        */
        let first = sq.offset
        XCTAssert(first.advance(.Horizontal, amount: PapyrusDimensions - 1)?.x == PapyrusDimensions)
        XCTAssert(first.advance(.Horizontal, amount: PapyrusDimensions) == nil)
        XCTAssert(first.advance(.Vertical, amount: PapyrusDimensions - 1)?.y == PapyrusDimensions)
        XCTAssert(first.advance(.Vertical, amount: PapyrusDimensions) == nil)
    }
    
    func runOffsetTests() {
        XCTAssert([(1,1)].toOffsets().count == 1)
        XCTAssert([(0,-1)].toOffsets().count == 0)
        XCTAssert([(-1,0)].toOffsets().count == 0)
        XCTAssert([(0,0)].toOffsets().count == 1)
        XCTAssert([(PapyrusDimensions + 1,PapyrusDimensions)].toOffsets().count == 0)
        XCTAssert([(PapyrusDimensions,PapyrusDimensions + 1)].toOffsets().count == 0)
        XCTAssert(Offset(x: 1, y: 1) < Offset(x : 2, y : 2))
        XCTAssert(Offset(x: 3, y: 3) > Offset(x : 2, y : 2))
        XCTAssert(Offset(x: 1, y: 1) == Offset(x : 1, y : 1))
        XCTAssert(Offset(x: 1, y: 1)?.next(.Vertical) == Offset(x: 1, y: 2))
        XCTAssert(Offset(x: 1, y: 1)?.prev(.Vertical) == Offset(x: 1, y: 0))
        XCTAssert(Offset(x: 1, y: 1)?.next(.Horizontal) == Offset(x: 2, y: 1))
        XCTAssert(Offset(x: 1, y: 1)?.prev(.Horizontal) == Offset(x: 0, y: 1))
        XCTAssert(Offset(x: -1, y: -1) == nil)
        XCTAssert(Offset((-1, -1)) == nil)
        XCTAssert(Offset((1, 1)) != nil)
        XCTAssert(Offset(x: 1, y: 1)!.hashValue == "(\(1),\(1))".hashValue)
    }
    
    func testExtensions() {
        XCTAssert(minMax([1,2,3]).min == 1)
        XCTAssert(minMax([1,2,3]).max == 3)
        XCTAssert(minEqualsMax(minMax([1,1])) == 1)
        XCTAssert(minEqualsMax(minMax([1,2])) == nil)
        var count: Int = 0
        iterate([1,2,3], start: 0, callback: { (value) -> () in
            count += value
        })
        XCTAssert(count == [1,2,3].reduce(0, combine: +))
        XCTAssert([1,2,3,nil].mapFilter{ $0 }.count == 3)
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
                self.runSquareTests(instance)
                self.runOffsetTests()
                self.runTileTests(instance)
                self.runPlayerTests(instance)
                self.runRunsTests(instance)
                self.runTileErrorTests(instance)
                
            case .Completed:
                print("Completed")
            }
        }
    }
    
}
