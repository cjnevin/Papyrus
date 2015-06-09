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
    
	func testGameCreationPerformance() {
		self.measureBlock() {
			// Starting a game can take a while to create the dictionary (should background)
			Game()
		}
	}
	
	func testDictionaryPerformance() {
		var dictionary = Game.Dictionary(language: .English)
		self.measureBlock() {
			println(dictionary.possibleWords(forLetters: ["P","A","R","A","D","I","S","E"]))
		}
	}
	
	func testGame() {
		let g = Game()
		// Test squares
		XCTAssert(g.board.squares.count == g.board.dimensions * g.board.dimensions, "Invalid square count")
		// Test player one
		XCTAssert(g.players.count == 1, "Invalid player count")
		// Test rack
		XCTAssert(g.rack?.amount == 7, "Invalid rack amount")
		// Test bag
		XCTAssert(g.bag.total - 7 == g.bag.remaining, "Invalid bag remaining")
		// Add player
		g.addPlayer()
		XCTAssert(g.players.count == 2, "Invalid player count")
		g.currentPlayer = g.players.last
		// Test rack
		XCTAssert(g.rack?.amount == 7, "Invalid rack amount")
		// Test bag
		XCTAssert(g.bag.total - 14 == g.bag.remaining, "Invalid bag remaining")
		// Add AI
		g.addAI(Game.AIPlayer.Intelligence.Master)
		XCTAssert(g.players.count == 3, "Invalid player count")
		g.currentPlayer = g.players.last
		// Test rack
		XCTAssert(g.rack?.amount == 7, "Invalid rack amount")
		// Test bag
		XCTAssert(g.bag.total - 21 == g.bag.remaining, "Invalid bag remaining")
		// Test dictionary
		XCTAssert(g.dictionary.defined("KITTY").0, "Invalid dictionary entry")
	}
}
