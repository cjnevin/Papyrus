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
        XCTAssert(instance.bagTiles.count == totalTiles - PapyrusRackAmount)
        XCTAssert(instance.tileIndex == PapyrusRackAmount)
        XCTAssert(instance.player?.rackTiles.count == PapyrusRackAmount)
    }
    
    func runPlacementTests(instance: Papyrus) {
        instance.squares[2][9].tile = Tile("R", 1)
        instance.squares[3][9].tile = Tile("E", 1)
        instance.squares[4][9].tile = Tile("S", 1)
        instance.squares[5][9].tile = Tile("U", 1)
        instance.squares[6][9].tile = Tile("M", 3)
        instance.squares[8][9].tile = Tile("S", 1)
        
        instance.squares[7][5].tile = Tile("A", 1)
        instance.squares[7][6].tile = Tile("R", 1)
        instance.squares[7][7].tile = Tile("C", 3)
        instance.squares[7][8].tile = Tile("H", 4)
        instance.squares[7][9].tile = Tile("E", 1)
        instance.squares[7][10].tile = Tile("R", 1)
        instance.squares[7][11].tile = Tile("S", 1)
        
        instance.squares[8][7].tile = Tile("A", 1)
        instance.squares[9][7].tile = Tile("R", 1)
        instance.squares[10][7].tile = Tile("D", 2)
        
        instance.squares[10][6].tile = Tile("A", 1)
        instance.squares[10][5].tile = Tile("E", 1)
        instance.squares[10][4].tile = Tile("D", 2)
        instance.squares[10][8].tile = Tile("E", 1)
        instance.squares[10][9].tile = Tile("R", 1)
        
        instance.squares[8][5].tile = Tile("R", 1)
        instance.squares[9][5].tile = Tile("I", 1)
        
        var playedBoundaries = Boundaries()
        // ARCHERS
        playedBoundaries.append(Boundary(
            start: Position(axis: .Horizontal(.Prev), iterable: 5, fixed: 7),
            end: Position(axis: .Horizontal(.Next), iterable: 11, fixed: 7)))
        // DEAD
        playedBoundaries.append(Boundary(
            start: Position(axis: .Horizontal(.Prev), iterable: 4, fixed: 10),
            end: Position(axis: .Horizontal(.Next), iterable: 9, fixed: 10)))
        // CARD
        playedBoundaries.append(Boundary(start:
            Position(axis: .Vertical(.Prev), iterable: 7, fixed: 7), end:
            Position(axis: .Vertical(.Next), iterable: 10, fixed: 7)))
        // ARIE
        playedBoundaries.append(Boundary(start:
            Position(axis: .Vertical(.Prev), iterable: 7, fixed: 5), end:
            Position(axis: .Vertical(.Next), iterable: 10, fixed: 5)))
        // RESUME
        playedBoundaries.append(Boundary(start:
            Position(axis: .Vertical(.Prev), iterable: 2, fixed: 9), end:
            Position(axis: .Vertical(.Next), iterable: 8, fixed: 9)))
        
        let playableBoundaries = instance.findPlayableBoundaries(playedBoundaries)
        
        // Now determine playable boundaries
        for row in 0..<PapyrusDimensions {
            var line = [Character]()
            for col in 0..<PapyrusDimensions {
                var letter: Character = "_"
                for boundary in playableBoundaries {
                    if boundary.encompasses(row, column: col) {
                        letter = instance.letterAt(row, col) ?? "#"
                        break
                    }
                }
                line.append(letter)
            }
            print(line)
        }
        XCTAssert(playableBoundaries.count == 100)
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
    }
    */
    func testExtensions() {
        XCTAssert([1,2,3,nil].mapFilter{ $0 }.count == 3, "Nil should be filtered")
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
                //self.runSquareTests(instance)
                //self.runOffsetTests()
                self.runPlacementTests(instance)
                self.runTileTests(instance)
                self.runPlayerTests(instance)/*
                self.runRunsTests(instance)
                self.runTileErrorTests(instance)
                self.runTilePlacementTests(instance)
            */
            case .ChangedPlayer:
                print("Player changed")
                
            case .Completed:
                print("Completed")
            }
        }
    }
    
}
