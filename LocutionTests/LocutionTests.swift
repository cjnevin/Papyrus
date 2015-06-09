//
//  LocutionTests.swift
//  LocutionTests
//
//  Created by Chris Nevin on 22/08/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import UIKit
import XCTest

class LocutionTests: XCTestCase {
    
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
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
	
	func testGame() {
		var game: Game?
		self.measureBlock() {
			// Starting a game can take a while to create the dictionary (should background)
			game = Game()
		}
		if let g = game {
			// Test squares
			XCTAssert(g.board.squares.count == g.board.dimensions * g.board.dimensions, "Invalid square count")
			// Test player one
			XCTAssert(g.players.count == 1, "Invalid player count")
			// Test rack
			XCTAssert(g.rack?.amount == 7, "Invalid rack amount")
			// Test bag
			XCTAssert(g.bag.total - 7 == g.bag.remaining, "Invalid bag remaining")
			// Add player
			game?.addPlayer()
			XCTAssert(g.players.count == 2, "Invalid player count")
			game?.currentPlayer = g.players.last
			// Test rack
			XCTAssert(g.rack?.amount == 7, "Invalid rack amount")
			// Test bag
			XCTAssert(g.bag.total - 14 == g.bag.remaining, "Invalid bag remaining")
			// Add AI
			game?.addAI(Game.AIPlayer.Intelligence.Master)
			XCTAssert(g.players.count == 3, "Invalid player count")
			game?.currentPlayer = g.players.last
			// Test rack
			XCTAssert(g.rack?.amount == 7, "Invalid rack amount")
			// Test bag
			XCTAssert(g.bag.total - 21 == g.bag.remaining, "Invalid bag remaining")
			// Test dictionary (not initialized yet)
			XCTAssert(g.dictionary.defined("KITTY").0, "Invalid dictionary entry")
		}
	}
    
}
