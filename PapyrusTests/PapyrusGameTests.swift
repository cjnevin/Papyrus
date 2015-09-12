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
        XCTAssert(player2.tiles.count == 0)
        XCTAssert(player2.rackTiles.count == 0)
        XCTAssert(instance.bagTiles.count == totalTiles - PapyrusRackAmount)
        
        instance.replenishRack(player2)
        XCTAssert(player2.rackTiles.count == PapyrusRackAmount)
        XCTAssert(instance.bagTiles.count == totalTiles - (PapyrusRackAmount * 2))
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
