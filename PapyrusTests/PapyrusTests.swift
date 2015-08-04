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
    
    func runTilePlacementTests(instance: Papyrus) {
        XCTAssert(Orientation.both == [Orientation.Horizontal, Orientation.Vertical])
        XCTAssert(Orientation.Horizontal.invert == Orientation.Vertical)
        XCTAssert(Orientation.Vertical.invert == Orientation.Horizontal)
        
        do {
            let def = try Lexicon.sharedInstance.defined("tca")
            XCTAssert(false)
        } catch {
            // Expected an error
        }
        
        do {
            let def = try Lexicon.sharedInstance.defined("")
            XCTAssert(false)
        } catch {
            // Expected an error
        }
        
        do {
            let def = try Lexicon.sharedInstance.defined("a$")
            XCTAssert(false)
        } catch {
            // Expected an error
        }
        
        do {
            let def = try Lexicon.sharedInstance.defined("cat")
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
        
        func getTile(withLetter letter: Character) -> Tile {
            return instance.tiles.filter({ ($0.letter == letter && ($0.placement == .Bag || $0.placement == .Rack)) }).first!
        }
        
        func dropEm(tiles: [(Tile, Offset)]) {
            do {
                for (t, p) in tiles {
                    guard let square = instance.squares.at(p) else {
                        XCTAssert(false)
                        break
                    }
                    try t.place(.Board, owner: instance.player, square: square)
                    XCTAssert(t.placed(.Board) == t)
                }
            } catch {
                XCTAssert(false)
            }
        }
        
        do {
            let o = PapyrusMiddleOffset!
            
            // Add 'cat' intersecting middle square
            let cat = [(getTile(withLetter: "C"), o.prev(.Vertical)!),
                (getTile(withLetter: "A"), o),
                (getTile(withLetter: "T"), o.next(.Vertical)!)]
            dropEm(cat)
            
            // Need to split out move logic, so we can test it easier...
            let words = try instance.move(cat.map({$0.0}))
            
            // Validate word
            XCTAssert(words.first == words.first)
            XCTAssert(words.first?.points == 0) // Immutable can't have points
            XCTAssert(words.first?.bonus == 0)
            XCTAssert(words.first?.immutable == true)
            
            // Add 'ha' to existing 't' to form 'hat' on the perpendicular
            let ha = [(getTile(withLetter: "H"), o.next(.Vertical)!.prev(.Horizontal)!.prev(.Horizontal)!),
                (getTile(withLetter: "A"), o.next(.Vertical)!.prev(.Horizontal)!)]
            dropEm(ha)
            
            let haWords = try instance.move(ha.map({$0.0}))
            XCTAssert(haWords.count == 1)
            XCTAssert(haWords.first?.length == 3)
            XCTAssert(haWords.first?.value == "HAT")
            
            let z = [(getTile(withLetter: "Z"), o.next(.Vertical)!.prev(.Horizontal)!.prev(.Vertical)!)]
            dropEm(z)
            
            let zWords = try instance.move(z.map({$0.0}))
            print(zWords.count)
            print(zWords)
            
        } catch {
            XCTAssert(false)
        }
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
            try tile.place(.Held, owner: nil, square: instance.squares.at(Offset((0,0))!))
        } catch {
            XCTAssert(tile.placed(placement) == tile)
        }
    }
    
    func runRunsTests(instance: Papyrus) {
        XCTAssert(54 == instance.currentRuns().array.count)
    }
    
    func runSquareTests(instance: Papyrus) {
        XCTAssert(instance.squares.count == PapyrusDimensions * PapyrusDimensions)
        
        let sq = instance.squares.at(Offset((1,1))!)
        XCTAssert(sq?.hashValue == "\(sq!.offset.x),\(sq!.offset.y)".hashValue)
        /*XCTAssert(sq.at(x: 2, y: 2, inArray: sqs) != nil)
        XCTAssert(sq.at(x: PapyrusDimensions + 1, y: 0, inArray: sqs) == nil)
        XCTAssert(sq.at(x: 0, y: PapyrusDimensions + 1, inArray: sqs) == nil)
        XCTAssert(sq.at(x: -1, y: 0, inArray: sqs) == nil)
        XCTAssert(sq.at(x: 0, y: -1, inArray: sqs) == nil)*/
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
                self.runTilePlacementTests(instance)
                
            case .Completed:
                print("Completed")
            }
        }
    }
    
}
