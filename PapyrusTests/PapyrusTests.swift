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
        instance.createPlayer()
        XCTAssert(instance.tiles.inBag().count == totalTiles - PapyrusRackAmount)
        XCTAssert(instance.tileIndex == PapyrusRackAmount)
        XCTAssert(instance.tiles.inRack(instance.player).count == PapyrusRackAmount)
        XCTAssert(instance.tiles.onBoard(instance.player).count == 0)
        let tile = instance.tiles.inRack(instance.player).first!
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
            let placement = Tile.Placement.Rack(instance.player!)
            return instance.tiles.filter({$0.letter == letter})
                .filter({$0.placement == .Bag || $0.placement == placement}).first!
        }
        
        func assertEmptyWordFailure(instance: Papyrus) {
            do {
                let tiles = [Tile]()
                try instance.move(tiles)
                XCTAssert(false)
            }
            catch {
                XCTAssert(true)
            }
        }
        
        func assertTilePlacementFailure(instance: Papyrus) {
            // Fail for not intersecting center
            let a = Offset(x: 1, y: 1)!
            let fail = [
                (getTile(withLetter: "F"), a),
                (getTile(withLetter: "A"), a.advance(.Vertical, amount: 1)!),
                (getTile(withLetter: "I"), a.advance(.Vertical, amount: 2)!),
                (getTile(withLetter: "L"), a.advance(.Vertical, amount: 3)!)
            ]
            dropEm(fail)
            do {
                // Must fail
                let _ = try instance.move(fail.map({$0.0}))
                XCTAssert(false)
            } catch {
                XCTAssert(true)
                for f in fail {
                    f.0.placement = .Bag
                }
            }
        }
        
        func assertTilePlacementLineFailure(instance: Papyrus) {
            // Fail for not intersecting center
            let a = Offset(x: 1, y: 1)!
            let fail = [
                (getTile(withLetter: "F"), a),
                (getTile(withLetter: "A"), a.advance(.Vertical, amount: 1)!),
                (getTile(withLetter: "I"), a.advance(.Horizontal, amount: 2)!),
                (getTile(withLetter: "L"), a.advance(.Vertical, amount: 3)!)
            ]
            dropEm(fail)
            do {
                // Must fail
                let _ = try instance.move(fail.map({$0.0}))
                XCTAssert(false)
            } catch {
                XCTAssert(true)
                for f in fail {
                    f.0.placement = .Bag
                }
            }
        }
        
        func dropEm(tiles: [(Tile, Offset)]) {
            for (t, p) in tiles {
                guard let square = instance.squares.at(p) else {
                    XCTAssert(false)
                    break
                }
                t.placement = Tile.Placement.Board(instance.player!, square)
            }
        }
        
        assertEmptyWordFailure(instance)
        assertTilePlacementFailure(instance)
        assertTilePlacementLineFailure(instance)
        
        do {
            let o = PapyrusMiddleOffset!
            
            // NOTE: Cant use same tile twice without playing, limitation of 'getTile' method.
            // Add 'batcher' intersecting middle square
            let cat = [
                (getTile(withLetter: "B"), o.prev(.Vertical)!),
                (getTile(withLetter: "A"), o),
                (getTile(withLetter: "T"), o.next(.Vertical)!),
                (getTile(withLetter: "C"), o.advance(.Vertical, amount: 2)!),
                (getTile(withLetter: "H"), o.advance(.Vertical, amount: 3)!),
                (getTile(withLetter: "E"), o.advance(.Vertical, amount: 4)!),
                (getTile(withLetter: "R"), o.advance(.Vertical, amount: 5)!)]
            dropEm(cat)
            
            // Need to split out move logic, so we can test it easier...
            let words = try instance.move(cat.map({$0.0}))
            
            assertTilePlacementFailure(instance)
            
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
            
            XCTAssert(instance.tiles.onBoardFixed().count == (ha.count + cat.count + z.count))
            let totalTiles = Papyrus.TileConfiguration.map({$0.0}).reduce(0, combine: +)
            XCTAssert(totalTiles - (instance.tiles.inBag().count + instance.tiles.inRack(instance.player).count) == (ha.count + cat.count + z.count))
            
        } catch {
            XCTAssert(false)
        }
        
        // Fake rack being empty
        for t in instance.tiles.inRack(instance.player) {
            t.placement = .Bag
        }
        XCTAssert(true)
        // Create opponent, take some tiles
        let player = instance.createPlayer()
        instance.players.append(player)
        instance.completeGameIfNoTilesInRack()
    }
    
    func runTileErrorTests(instance: Papyrus) {
        let tile = instance.tiles.inRack(instance.player).first!
        XCTAssert(tile.letterValue == 0)
        XCTAssert(tile.wordMultiplier == 1)
    }
    
    func runRunsTests(instance: Papyrus) {
        XCTAssert(54 == instance.currentRuns()?.array.count)
    }
    
    func runSquareTests(instance: Papyrus) {
        XCTAssert(instance.squares.count == PapyrusDimensions * PapyrusDimensions)
        
        let sq = instance.squares.at(Offset((1,1))!)
        XCTAssert(sq?.hashValue == "\(sq!.offset.x),\(sq!.offset.y)".hashValue)
        XCTAssert(sq == sq)
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
        XCTAssert(Offset((1,1))!.at(x: 3, y: 3) != nil)
        XCTAssert(Offset((1,1))!.at(x: -1, y: -1) == nil)
        XCTAssert(Offset((1,1))!.at(x: PapyrusDimensions + 1, y: PapyrusDimensions) == nil)
    }
    
    func testExtensions() {
        XCTAssert(minMax([1,2,3]).min == 1, "Min should return 1")
        XCTAssert(minMax([1,2,3]).max == 3, "Max should return 3")
        XCTAssert(minEqualsMax(minMax([1,1])) == 1, "Minmax should return 1")
        XCTAssert(minEqualsMax(minMax([1,2])) == nil, "Minmax should fail, both don't match")
        var count: Int = 0
        iterate([1,2,3], start: 0, callback: { (value) -> () in
            count += value
        })
        XCTAssert(count == [1,2,3].reduce(0, combine: +), "Count should equal reduce function's test")
        XCTAssert([1,2,3,nil].mapFilter{ $0 }.count == 3, "Nil should be filtered")
        
        // <~> operator
        let r = (0, 5)
        XCTAssert(1 == (1 <~> r), "1 should be inside of r range")
        XCTAssert(((1,6) <~> r) == nil, "End of range should be outside of r range")
        XCTAssert(((-1, 4) <~> r) == nil, "Start of range should be outside of r range")
        let a = (1,2) <~> r
        XCTAssert(a?.0 == 1 && a?.1 == 2, "1,2 should be within r range")
        XCTAssert(((0,6) <~> r) == nil, "0,6 should return nil")
        XCTAssert(((-1,4) <~> r) == nil, "-1,4 should return nil")
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
