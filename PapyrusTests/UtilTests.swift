//
//  UtilTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import Papyrus

class UtilTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExtensions() {
        XCTAssert([1,2,3,nil].mapFilter{ $0 }.count == 3, "Nil should be filtered")
    }
    

}
