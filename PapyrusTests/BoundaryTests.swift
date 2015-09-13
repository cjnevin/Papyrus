//
//  BoundaryTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import Papyrus

class BoundaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBoundary() {
        XCTAssert(Position(horizontal: true, iterable: 20, fixed: 20) == nil, "Expected invalid position")
        XCTAssert(Position(horizontal: false, iterable: -1, fixed: -1) == nil, "Expected invalid position")
        XCTAssert(Position(horizontal: true, row: 20, col: 20) == nil, "Expected invalid position")
        XCTAssert(Position(horizontal: false, row: -1, col: -1) == nil, "Expected invalid position")
        
        let start = Position(horizontal: true, iterable: 1, fixed: 1)!
        var end = Position(horizontal: true, iterable: 3, fixed: 1)!
        var boundary = Boundary(start: start, end: end)!
        XCTAssert(boundary.contains(start), "Boundary should encompass first iterable")
        XCTAssert(boundary.contains(end), "Boundary should encompass last iterable")
        XCTAssert(boundary.length == boundary.iterableRange.endIndex - boundary.iterableRange.startIndex)
        XCTAssert(boundary.horizontal, "Start is horizontal")
        XCTAssert(end.horizontal != end.positionWithHorizontal(!end.horizontal)!.horizontal, "Direction should be different")
        
        let lastEnd = end
        end.nextInPlace()
        XCTAssert(lastEnd.next() == end, "New position should return one plus")
        boundary.stretchInPlace(start, newEnd: end)
        XCTAssert(boundary.contains(end), "Boundary should include new end")
        
        var newStart = start.previous()!
        XCTAssert(start.previous() == newStart, "New position should return one previous")
        boundary.stretchInPlace(newStart, newEnd: end)
        XCTAssert(boundary.contains(newStart), "Boundary should include newStart")
        
        newStart.previousInPlace()
        XCTAssert(newStart == boundary.start, "Start should not be stretchable outside of board boundary")
        
        end.nextInPlace()
        let stretchedBoundary = boundary.stretch(boundary.start, newEnd: end)
        let stretchedIterableBoundary = boundary.stretch(boundary.start.iterable, endIterable: end.iterable)
        boundary.stretchInPlace(boundary.start, newEnd: end)
        XCTAssert(boundary.contains(end), "Boundary should include end.newPosition")
        XCTAssert(boundary == stretchedBoundary, "Boundary should equal stretched boundary")
        XCTAssert(boundary == stretchedIterableBoundary, "Boundary should equal stretched iterable boundary")
        
        XCTAssert(boundary.shrink(boundary.start, newEnd: boundary.end) == boundary, "Boundary should not change")
        XCTAssert(boundary.shrink(boundary.start.iterable, endIterable: boundary.end.iterable) == boundary, "Boundary should not change")
        let shrunkBoundary = boundary.shrink(boundary.start.iterable + 1, endIterable: boundary.end.iterable - 1)
        let manuallyShrunkBoundary = Boundary(
            start: boundary.start.positionWithIterable(boundary.start.iterable + 1),
            end: boundary.end.positionWithIterable(boundary.end.iterable - 1))
        boundary.shrinkInPlace(boundary.start.iterable + 1, endIterable: boundary.end.iterable - 1)
        XCTAssert(boundary == shrunkBoundary, "Boundary should equal shrunk boundary")
        XCTAssert(boundary == manuallyShrunkBoundary, "Boundary should equal new boundary")
        boundary.stretchInPlace(boundary.start.iterable - 1, endIterable: boundary.end.iterable + 1)
        let shrunkPositionBoundary = boundary.shrink(boundary.start.positionWithIterable(boundary.start.iterable + 1)!, newEnd: boundary.end)
        boundary.shrinkInPlace(boundary.start.positionWithIterable(boundary.start.iterable + 1)!,
            newEnd: boundary.end)
        XCTAssert(shrunkPositionBoundary == boundary, "Boundaries should match")
        boundary.stretchInPlace(boundary.start.positionWithIterable(boundary.start.iterable - 1)!,
            newEnd: boundary.end)
        
        XCTAssert(boundary.previous()?.start.fixed == boundary.start.fixed - 1, "Previous should return previous line")
        XCTAssert(boundary.next()?.start.fixed == boundary.start.fixed + 1, "Next should return next line")
        
        let containedBoundary = Boundary(start: Position(horizontal: true, iterable: 1, fixed: 1)!,
            end: Position(horizontal: true, iterable: 3, fixed: 1)!)!
        XCTAssert(containedBoundary.containedIn(boundary), "Boundary should contain containedBoundary")
        XCTAssert(boundary.contains(containedBoundary), "Boundary should contain containedBoundary")
        XCTAssert(containedBoundary.contains(containedBoundary.start), "Boundary should contain start")
        XCTAssert(!containedBoundary.contains(end), "Boundary should not contain end")
        XCTAssert(boundary.contains(end.positionWithHorizontal(false)!), "Boundary should contain end even if axis is switched")
            
        end.nextInPlaceWhile { (position) -> Bool in
            position.iterable < 7
        }
        XCTAssert(end.iterable == 6, "End should be 6")
        
        // Adjacent check
        let adjacentBoundary = Boundary(start: start.positionWithFixed(2), end: end.positionWithFixed(2))!
        XCTAssert(adjacentBoundary.adjacentTo(boundary), "Boundary should be adjacent")
        XCTAssert(boundary.adjacentTo(adjacentBoundary), "Boundary should be adjacent")
        XCTAssert(boundary.adjacentTo(containedBoundary) == false, "Boundary should not be adjacent")
        XCTAssert(boundary.contains(adjacentBoundary) == false, "Boundary should not be contained")
        
        
        // Should intersect
        print(end)
        let invertedBoundary = Boundary(
            start: start.positionWithHorizontal(!start.horizontal),
            end: start.positionWithHorizontal(!start.horizontal)?.positionWithIterable(6))!
        XCTAssert(invertedBoundary.horizontal != boundary.horizontal, "Boundary should be vertical")
        XCTAssert(!invertedBoundary.horizontal, "Boudnary should be vertical")
        XCTAssert(invertedBoundary.intersects(boundary), "Boundary should intersect")
        XCTAssert(!boundary.intersects(containedBoundary), "Boundary should not intersect")
        XCTAssert(!boundary.intersects(Boundary(start: Position(horizontal: true, iterable: 4, fixed: 9),
            end: Position(horizontal: true, iterable: 7, fixed: 9))!), "Boundary should not intersect")
        
        // Should not intersect
        let verticalBoundary = Boundary(start: Position(horizontal: false, iterable: 7, fixed: 1),
            end: Position(horizontal: false, iterable: 9, fixed: 1))!
        XCTAssert(!verticalBoundary.intersects(boundary), "Boundary should not intersect")
        
        // Test optionals
        XCTAssert(start.positionWithHorizontal(true)! == start, "Horizontal should be false")
        XCTAssert(end.positionWithHorizontal(true)! == end, "Horizontal should be false")
        XCTAssert(start.positionWithHorizontal(false)!.horizontal == false, "Horizontal should be false")
        XCTAssert(end.positionWithHorizontal(false)!.horizontal == false, "Horizontal should be false")
        XCTAssert(start.positionWithHorizontal(false)! == start, "Expected true, some position just different axis")
        XCTAssert(end.positionWithHorizontal(false)! == end, "Expected true, some position just different axis")
        XCTAssert(start.positionWithIterable(12)! != start, "Iterable should be 12")
        XCTAssert(start.positionWithFixed(12)! != start, "Fixed should be 12")
        XCTAssert(start.positionWithFixed(start.fixed)! == start, "Expected same object")
        XCTAssert(start.positionWithFixed(20) == nil, "Expected nil")
        
        XCTAssert(Boundary(start: end, end: start) == nil, "Expected nil")
        XCTAssert(Boundary(start: start, end: verticalBoundary.end) == nil, "Expected nil")
        
        var a = Position(horizontal: true, iterable: 5, fixed: 6)!
        let b = Position(horizontal: false, iterable: 6, fixed: 5)!
        XCTAssert(a == b, "Positions should match if on opposite axis but same fixed")
        
        a.previousInPlaceWhile({$0.iterable > 3})
        XCTAssert(a.iterable == 4)
    }
}

