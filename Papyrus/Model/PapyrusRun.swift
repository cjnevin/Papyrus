//
//  PapyrusRun.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    /// An dictionary containing axis and offsets.
    typealias Run = [Int: Set<Offset>]
    /// A dictionary containing keyed by Axis with Run value.
    typealias AxisRun = [Axis: Run]
    
    private func iterate(f: OffsetAxisFunction, axis: Axis, offset: Offset, count: Int, inout output: Offsets) {
        if let next = f(offset)(axis: axis) where count > 0 {
            output.append(next)
            iterate(f, axis: axis, offset: next, count: count-1, output: &output)
        }
    }
    
    /// - Returns: An array of `runs` surrounding tiles played on the board.
    func axisRuns(distance: Int) -> AxisRun {
        return [
            .Horizontal: runs(.Horizontal, distance: distance),
            .Vertical: runs(.Vertical, distance: distance)
        ]
    }
    
    /// - Returns: An array of `Run` objects for a particular `Axis`.
    func runs(axis: Axis, distance: Int) -> Run {
        var run = Run()
        let count = distance
        for offset in tiles.onBoardFixed().mapFilter({$0.square?.offset}) {
            let a = axis == .Horizontal ? offset.y : offset.x
            var offsets = Offsets()
            iterate(Offset.next, axis: axis, offset: offset, count: count, output: &offsets)
            iterate(Offset.prev, axis: axis, offset: offset, count: count, output: &offsets)
            if run[a] != nil {
                run[a]?.unionInPlace(offsets)
            } else {
                run[a] = Set(offsets)
            }
        }
        return run
    }
}