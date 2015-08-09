//
//  PapyrusRun.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

// TODO: Re-document these...

extension Papyrus {
    /// An dictionary containing axis and offsets.
    //typealias Run = [Int: Set<Offset>]
    /// A dictionary containing keyed by Axis with Run value.
    //typealias AxisRun = [Axis: Run]
    //typealias AxisRanges = [Axis: [Int: Range<Int>]]
    
    typealias ZRanges = [Int: Range<Int>]
    typealias AxisZRanges = [Axis: ZRanges]
    
    private func iterate(f: OffsetAxisFunction, axis: Axis, offset: Offset, count: Int, inout output: Offsets) {
        if let next = f(offset)(axis: axis) where count > 0 {
            output.append(next)
            iterate(f, axis: axis, offset: next, count: count-1, output: &output)
        }
    }
    
    private func zRanges(axis: Axis, distance: Int) -> ZRanges {
        let count = distance
        let horiz = axis == .Horizontal
        var zRanges = ZRanges()
        for offset in tiles.onBoardFixed().mapFilter({$0.square?.offset}) {
            let z = horiz ? offset.y : offset.x
            // Collect offsets
            var offsets = Offsets()
            iterate(Offset.next, axis: axis, offset: offset, count: count, output: &offsets)
            iterate(Offset.prev, axis: axis, offset: offset, count: count, output: &offsets)
            // Calculate minimum and maximum offsets
            let sorted = offsets.sort()
            if let minOffset = sorted.first, maxOffset = sorted.last {
                var minZ = horiz ? minOffset.x : minOffset.y
                var maxZ = horiz ? maxOffset.x : maxOffset.y
                // Adjust if range already exists
                if let zRange = zRanges[z] {
                    minZ = min(zRange.startIndex, minZ)
                    maxZ = max(zRange.endIndex, maxZ)
                }
                // Store min/max range for current z (x or y)
                zRanges[z] = minZ...maxZ
            }
        }
        return zRanges
    }
    
    func axisZRanges(distance: Int) -> AxisZRanges {
        return [.Horizontal: zRanges(.Horizontal, distance: distance),
            .Vertical: zRanges(.Vertical, distance: distance)]
    }
    
    
    /*    func runs(withTiles userTiles: [Tile]) -> Runs {
        let fixed = tiles.onBoardFixed()
        let checkCentre = fixed.count == 0
        let rackAmount = userTiles.count
        var runs = Runs()
        var buffer = Run()
        func validateRun(run: Run) {
            if checkCentre {
                if run.count > 1 && run.count <= rackAmount && run.filter({ $0.0 == PapyrusMiddleOffset }).count > 0 {
                    runs.append(run)
                }

-                let count = run.mapFilter({ $0.1 }).filter({ fixed.contains($0) }).count
-                let diff = run.count - count
-                if count > 0 && diff > 0 && diff <= rackAmount {
-                    runs.append(run)
-                }
-            }
-        }
-        func checkOffset(offset: Offset?) {
-            if let o = offset {
-                buffer.append((o, fixed.filter({ $0.square?.offset == o }).first))
-                validateRun(buffer)
-                (1..<buffer.count).map({
-                    validateRun(Array(buffer[$0..<buffer.count]))
-                })
+                run[a] = Set(offsets)
             }
         }
-
-        // TODO: Add tiles immediately left and right of a valid offset.
-        let range = 1...PapyrusDimensions
-        for x in range {
-            buffer = Run()
-            range.map{ y in checkOffset(Offset(x: x, y: y)) }
-        }
-        for y in range {
-            buffer = Run()
-            range.map{ x in checkOffset(Offset(x: x, y: y)) }
-        }
-        return runs

*/
}