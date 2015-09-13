//
//  PapyrusGameTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import Papyrus

class PapyrusGameTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlayer() {
        XCTAssert(Player(score: 10).score == 10)
        XCTAssert(Player().score == 0)
    }
    
    func testSquares() {
        XCTAssert(Square.createSquares().flatten().count == PapyrusDimensions * PapyrusDimensions)
    }
    
    func testTiles() {
        let totalTiles = TileConfiguration.map({$0.0}).reduce(0, combine: +)
        XCTAssert(Tile.createTiles().count == totalTiles)
    }
    
    func bagRackTests(instance: Papyrus) {
        let totalTiles = TileConfiguration.map({$0.0}).reduce(0, combine: +)
        XCTAssert(instance.tiles.count == totalTiles)
        instance.createPlayer()
        XCTAssert(instance.bagTiles.count == totalTiles - PapyrusRackAmount)
        XCTAssert(instance.tileIndex == PapyrusRackAmount)
        
        let player = instance.player!
        XCTAssert(player.rackTiles.count == PapyrusRackAmount)
        XCTAssert(player.currentPlayTiles.count == 0)
        XCTAssert(player.heldTile == nil)
        XCTAssert(player.tiles.count == player.rackTiles.count)
        
        instance.createPlayer()
        
        instance.nextPlayer()
        
        let player2 = instance.player!
        XCTAssert(player != player2)
        XCTAssert(player2.rackTiles.count == PapyrusRackAmount)
        XCTAssert(player2.tiles.count == player2.rackTiles.count)
        XCTAssert(instance.bagTiles.count == totalTiles - (PapyrusRackAmount * 2))
        XCTAssert(instance.tileIndex == (PapyrusRackAmount * 2))
        
        player2.rackTiles.forEach({player2.moveTile($0, to: Placement.Bag)})
        XCTAssert(player2.tiles.count == 0, "Expected tiles to be empty")
        XCTAssert(player2.rackTiles.count == 0, "Expected rack to be empty")
        XCTAssert(instance.bagTiles.count == totalTiles - PapyrusRackAmount, "Expected bag to be missing first players rack tiles")
        
        instance.replenishRack(player2)
        XCTAssert(player2.rackTiles.count == PapyrusRackAmount, "Expected rack to contain default amount")
        XCTAssert(instance.bagTiles.count == totalTiles - (PapyrusRackAmount * 2), "Expected bag to be missing both players rack tiles")
        
        instance.nextPlayer()
        XCTAssert(instance.player == player, "Expected to return to first player")
    }
    
    func boundaryTests(instance: Papyrus) {
        XCTAssert(instance.previousWhileEmpty(Position(horizontal: true, iterable: 5, fixed: 5))?.iterable == 0)
        XCTAssert(instance.nextWhileEmpty(Position(horizontal: true, iterable: 5, fixed: 5))?.iterable == PapyrusDimensions - 1)
        XCTAssert(instance.previousWhileFilled(Position(horizontal: true, iterable: 5, fixed: 5)) == nil)
        XCTAssert(instance.nextWhileFilled(Position(horizontal: true, iterable: 5, fixed: 5)) == nil)
        
        let tile = instance.bagTiles.first
        let pos = Position(horizontal: true, iterable: 5, fixed: 5)
        tile?.placement = Placement.Board
        instance.squareAt(pos)?.tile = tile
        XCTAssert(instance.nextWhileFilled(pos) == pos)
        XCTAssert(instance.nextWhileEmpty(pos) == nil)
        XCTAssert(instance.nextWhileEmpty(pos?.positionWithIterable(1))?.iterable == 4)
        
        let tile2 = instance.bagTiles.first
        let pos2 = Position(horizontal: true, iterable: 4, fixed: 5)
        tile?.placement = Placement.Board
        let emptyPos = pos2?.positionWithIterable(3)
        instance.squareAt(pos2)?.tile = tile2
        XCTAssert(instance.nextWhileFilled(pos2) == pos)
        XCTAssert(instance.nextWhileEmpty(emptyPos) == emptyPos)
        XCTAssert(instance.previousWhileFilled(pos) == pos2)
        
        // Reset tiles
        tile2?.placement = Placement.Bag
        tile?.placement = Placement.Bag
        instance.squareAt(pos2)?.tile = nil
        instance.squareAt(pos)?.tile = nil
    }
    
    func whileTests(instance: Papyrus) {
        XCTAssert(instance.player?.rackTiles.count == 7, "Expected 7 rack tiles")
        XCTAssert(instance.previousWhileTilesInRack(Position(horizontal: true, row: 7, col: 7)!)?.iterable == 1, "Expected (7)-7 to land on square 1")
        XCTAssert(instance.nextWhileTilesInRack(Position(horizontal: true, row: 7, col: 7)!)?.iterable == PapyrusDimensions - 2, "Expected (7)+7 to land on square 13")
    }
    
    func playableBoundariesTest(instance: Papyrus) {
        XCTAssert(instance.player?.rackTiles.count == 7, "Expected 7 rack tiles")
        XCTAssert(PapyrusDimensions == 15, "Expected 15")
        
        let expectations = [7, 14, 20, 25, 29, 32, 34, 35,
            34, 32, 29, 25, 20, 14, 7]
        
        (0..<PapyrusDimensions).forEach { (index) -> () in
            let position = Position(horizontal: true, iterable: index, fixed: 7)!
            let tile = Tile("T", 1)
            let boundary = Boundary(start: position, end: position)!
            instance.squareAt(position)!.tile = tile
            
            let boundaries = instance.playableBoundaries(forBoundary: boundary)!
            print(boundaries.count)
            XCTAssert(boundaries.count == expectations[index], "Expected \(expectations[index]) boundaries")
            
            instance.squareAt(position)!.tile = nil
        }
        /*
        let word: [(char: Character, position: Position)] = [
            ("T", Position(horizontal: true, iterable: 0, fixed: 7)!),
            ("E", Position(horizontal: true, iterable: 5, fixed: 7)!),
            ("S", Position(horizontal: true, iterable: 6, fixed: 7)!),
            ("T", Position(horizontal: true, iterable: 7, fixed: 7)!)]
        let boundary = Boundary(start: word.first?.position, end: word.last?.position)!
        word.forEach({ instance.squareAt($0.position)!.tile = Tile($0.char, 1) })
        
        let boundaries = instance.playableBoundaries(forBoundary: boundary)!
        print(boundaries.count)
        XCTAssert(boundaries.count == 54, "Expected 39 boundaries")
        
        var start = PapyrusDimensions, end = 0
        for boundary in boundaries {
            start = min(start, boundary.start.iterable)
            end = max(end, boundary.end.iterable)
        }
        XCTAssert(start == 0, "Expected start to be 0")
        XCTAssert(end == PapyrusDimensions - 1, "Expected end to be 14")
        
        print(instance.playableBoundaries(forBoundary: boundary))*/
    }
    
    func placementTests(instance: Papyrus) {
        
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
            start: Position(horizontal: true, iterable: 5, fixed: 7),
            end: Position(horizontal: true, iterable: 11, fixed: 7))!)
        // DEAD
        playedBoundaries.append(Boundary(
            start: Position(horizontal: true, iterable: 4, fixed: 10),
            end: Position(horizontal: true, iterable: 9, fixed: 10))!)
        // CARD
        playedBoundaries.append(Boundary(
            start: Position(horizontal: false, iterable: 7, fixed: 7),
            end: Position(horizontal: false, iterable: 10, fixed: 7))!)
        // ARIE
        playedBoundaries.append(Boundary(
            start: Position(horizontal: false, iterable: 7, fixed: 5),
            end: Position(horizontal: false, iterable: 10, fixed: 5))!)
        // RESUME
        playedBoundaries.append(Boundary(
            start: Position(horizontal: false, iterable: 2, fixed: 9),
            end: Position(horizontal: false, iterable: 8, fixed: 9))!)
        
        let playableBoundaries = instance.findPlayableBoundaries(playedBoundaries)
        
        // Now determine playable boundaries
        for row in 0..<PapyrusDimensions {
            var line = [Character]()
            for col in 0..<PapyrusDimensions {
                var letter: Character = "_"
                for boundary in playableBoundaries {
                    let position = Position(horizontal: boundary.horizontal, row: row, col: col)!
                    if boundary.contains(position) {
                        letter = instance.letterAt(position) ?? "#"
                        break
                    }
                }
                line.append(letter)
            }
            print(line)
        }
        print(playableBoundaries.count)
        
        //XCTAssert(playableBoundaries.count == 100)
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
                
                self.bagRackTests(instance)
                self.boundaryTests(instance)
                self.whileTests(instance)
                self.playableBoundariesTest(instance)
                self.placementTests(instance)
                
                /*
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
