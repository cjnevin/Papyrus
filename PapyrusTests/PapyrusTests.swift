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
    
    /*
    
    
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
            let x1 = try instance.tileOrientation(cat.map({$0.0})).0 == .Vertical
            XCTAssert(x1)
            if let tiles = try instance.move(cat.mapFilter({$0.0})) {
                XCTAssert(tiles.count == 7)
            }
            
            let hat = [
                (getTile(withLetter: "B"), o.prev(.Horizontal)!),
                //(cat[1].0, o),
                (getTile(withLetter: "T"), o.next(.Horizontal)!),
                (getTile(withLetter: "C"), o.advance(.Horizontal, amount: 2)!),
                (getTile(withLetter: "H"), o.advance(.Horizontal, amount: 3)!),
                (getTile(withLetter: "E"), o.advance(.Horizontal, amount: 4)!),
                (getTile(withLetter: "R"), o.advance(.Horizontal, amount: 5)!)]
            dropEm(hat)
            let x2 = try instance.tileOrientation(hat.map({$0.0})).0 == .Horizontal
            XCTAssert(x2)
            if let tiles = try instance.move(hat.mapFilter({$0.0})) {
                XCTAssert(tiles.count == 14)
            }
            
            // Add 'za' to existing 't' to form 'zat' on the perpendicular
            let za = [(getTile(withLetter: "Z"), o.next(.Vertical)!.prev(.Horizontal)!.prev(.Horizontal)!),
                (getTile(withLetter: "I"), o.next(.Vertical)!.prev(.Horizontal)!)]
            dropEm(za)
            let x3 = try instance.tileOrientation(za.mapFilter({$0.0})).0 == .Horizontal
            XCTAssert(x3)
            if let tiles = try instance.move(za.mapFilter({$0.0})) {
                XCTAssert(tiles.count == 12)
            }
            
            
            
            //dropEm(cat)
            
            
            // Need to split out move logic, so we can test it easier...
            /*if let words = try instance.move(cat.map({$0.0})), firstWord = words.first {
                
                assertTilePlacementFailure(instance)
                
                // Validate word
                XCTAssert(firstWord == firstWord)
                XCTAssert(firstWord.points == 0) // Immutable can't have points
                XCTAssert(firstWord.bonus == 0)
                XCTAssert(firstWord.immutable == true)
            }
            
            // Add 'ha' to existing 't' to form 'hat' on the perpendicular
            let ha = [(getTile(withLetter: "H"), o.next(.Vertical)!.prev(.Horizontal)!.prev(.Horizontal)!),
                (getTile(withLetter: "A"), o.next(.Vertical)!.prev(.Horizontal)!)]
            dropEm(ha)

            XCTAssert(Papyrus.sharedInstance.tileOrientation(ha.map({$0.0})).0 == .Horizontal)
            
            let haWords = try instance.move(ha.map({$0.0}))
            XCTAssert(haWords!.count == 1)
            XCTAssert(haWords!.first?.length == 3)
            XCTAssert(haWords!.first?.value == "HAT")
            
            let z = [(getTile(withLetter: "Z"), o.next(.Vertical)!.prev(.Horizontal)!.prev(.Vertical)!)]
            dropEm(z)
            
            let zWords = try instance.move(z.map({$0.0}))
            print(zWords.count)
            print(zWords)
            
            XCTAssert(instance.tiles.onBoardFixed().count == (ha.count + cat.count + z.count))
            let totalTiles = Papyrus.TileConfiguration.map({$0.0}).reduce(0, combine: +)
            XCTAssert(totalTiles - (instance.tiles.inBag().count + instance.tiles.inRack(instance.player).count) == (ha.count + cat.count + z.count))*/
            
        } catch let err as ValidationError {
            switch err {
            case .Arrangement(let tiles): print("Arrangement err: \(tiles)")
            case .Intersection(let word): print("Intersection err: \(word)")
            case .Invalid(let word): print("Invalid err: \(word)")
            case .Message(let str): print(str)
            case .Undefined(let str): print("Undefined \(str)")
            case .NoTiles: print("No tiles")
            case .Center(_, let word): print("Center missing: \(word)")
            }
            
            XCTAssert(false)
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
        //XCTAssert(54 == instance.currentRuns()?.array.count)
    }
    
    */
}
