//
//  PapyrusBoundaryTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import Papyrus

class PapyrusBoundaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBoundary() {
        let start = Position(ascending: false, horizontal: true, iterable: 1, fixed: 1)!
        var end = Position(ascending: true, horizontal: true, iterable: 3, fixed: 1)!
        var boundary = Boundary(start: start, end: end)
        XCTAssert(boundary.isValid, "Boundary is valid")
        XCTAssert(boundary.encompasses(1, column: 1), "Boundary should encompass first iterable")
        XCTAssert(boundary.encompasses(1, column: 3), "Boundary should encompass last iterable")
        XCTAssert(boundary.length == boundary.end.iterable - boundary.start.iterable)
        XCTAssert(boundary.horizontal, "Start is horizontal")
        XCTAssert(end.horizontal != end.positionWithHorizontal(!end.horizontal)!.horizontal, "Direction should be different")
        
        let lastEnd = end
        end.nextInPlace()
        XCTAssert(lastEnd.next() == end, "New position should return one plus")
        boundary.stretchInPlace(start, newEnd: end)
        XCTAssert(boundary.encompasses(1, column: 4), "Boundary should include new end")
        
        var newStart = start.next()!
        XCTAssert(start.next() == newStart, "New position should return one previous")
        boundary.stretchInPlace(newStart, newEnd: end)
        XCTAssert(boundary.encompasses(1, column: 0), "Boundary should include newStart")
        
        newStart.nextInPlace()
        XCTAssert(newStart == boundary.start, "Start should not be stretchable outside of board boundary")
        
        end.nextInPlace()
        boundary.stretchInPlace(boundary.start, newEnd: end)
        XCTAssert(boundary.encompasses(1, column: 5), "Boundary should include end.newPosition")
        
        XCTAssert(!newStart.ascending, "Start direction is Prev")
        XCTAssert(end.ascending, "Start direction is Prev")
        
        let containedBoundary = Boundary(start: Position(ascending: false, horizontal: true, iterable: 1, fixed: 1)!,
            end: Position(ascending: true, horizontal: true, iterable: 3, fixed: 1)!)
        XCTAssert(containedBoundary.containedIn(boundary), "Boundary should contain containedBoundary")
        XCTAssert(boundary.contains(containedBoundary), "Boundary should contain containedBoundary")
        
        end.nextInPlaceWhile { (position) -> Bool in
            position.iterable < 7
        }
        XCTAssert(end.iterable == 6, "End should be 6")
        
        // Adjacent check
        let adjacentStart = start.positionWithFixed(2)!
        let adjacentEnd = end.positionWithFixed(2)!
        let adjacentBoundary = Boundary(start: adjacentStart, end: adjacentEnd)
        XCTAssert(adjacentBoundary.adjacentTo(boundary), "Boundary should be adjacent")
        XCTAssert(boundary.adjacentTo(adjacentBoundary), "Boundary should be adjacent")
        
        // Should intersect
        let invertedStart = start.positionWithHorizontal(!start.horizontal)!
        let invertedEnd = end.positionWithHorizontal(!start.horizontal)!
        let invertedBoundary = Boundary(start: invertedStart, end: invertedEnd)
        XCTAssert(invertedBoundary.horizontal != boundary.horizontal, "Boundary should be vertical")
        XCTAssert(!invertedBoundary.horizontal, "Boudnary should be vertical")
        XCTAssert(invertedBoundary.intersects(boundary), "Boundary should intersect")
        
        // Should not intersect
        let verticalStart = Position(ascending: false, horizontal: false, iterable: 7, fixed: 1)!
        let verticalEnd = Position(ascending: true, horizontal: false, iterable: 9, fixed: 1)!
        let verticalBoundary = Boundary(start: verticalStart, end: verticalEnd)
        XCTAssert(!verticalBoundary.intersects(boundary), "Boundary should not intersect")
    }
}

