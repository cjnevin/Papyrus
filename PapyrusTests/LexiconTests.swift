//
//  LexiconTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import Papyrus

class LexiconTests: XCTestCase {

    let lexicon: Lexicon = Lexicon.sharedInstance
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAnagrams() {
        var fixedLetters: [(Int, Character)] = []
        var results = [String]()
        lexicon.anagramsOf("CAT", length: 3, prefix: "",
            fixedLetters: fixedLetters, fixedCount: 0, source: lexicon.dictionary!, results: &results)
        XCTAssert(results.sort() == ["ACT", "CAT"])
        
        fixedLetters.append((2, "R"))
        results = [String]()
        lexicon.anagramsOf("TAC", length: 4, prefix: "",
            fixedLetters: fixedLetters, fixedCount: 1, source: lexicon.dictionary!, results: &results)
        XCTAssert(results == ["CART"])
        
        results = [String]()
        lexicon.anagramsOf("TACPOSW", length: 3, prefix: "",
            fixedLetters: fixedLetters, fixedCount: 1, source: lexicon.dictionary!, results: &results)
        XCTAssert(results.sort() == ["CAR", "COR", "OAR", "PAR", "SAR", "TAR", "TOR", "WAR"])
        
        results = [String]()
        lexicon.anagramsOf("PATIERS", length: 8, prefix: "",
            fixedLetters: fixedLetters, fixedCount: 1, source: lexicon.dictionary!, results: &results)
        XCTAssert(results == ["PARTIERS"])
        
        results = [String]()
        fixedLetters.append((0, "C"))
        lexicon.anagramsOf("AEIOU", length: 3, prefix: "",
            fixedLetters: fixedLetters, fixedCount: 1, source: lexicon.dictionary!, results: &results)
        XCTAssert(results.sort() == ["CAR", "COR", "CUR"])
    }

}
