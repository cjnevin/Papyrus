//
//  PapyrusRun.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    /// An array of tuples containing offset and tile.
    typealias Run2 = (offset: Offset, tile: Tile?)
    typealias Run = [(offset: Offset, tile: Tile?)]
    /// An array containing Run.
    typealias Runs = [Run]
    
    typealias AxisRun = [Int: Set<Offset>]
    typealias OrientationAxisRun = [Orientation: [Int: Set<Offset>]]
    
    /// - Returns: An array of runs for the current player or nil.
    func currentRuns() -> Runs? {
        guard let player = player else { return nil }
        return runs(withTiles: tiles.inRack(player))
    }
    
    func iterate(f: OffsetOrientationFunction, orientation: Orientation, offset: Offset, count: Int, inout output: Offsets) {
        if let next = f(offset)(o: orientation) where count > 0 {
            output.append(next)
            iterate(f, orientation: orientation, offset: next, count: count-1, output: &output)
        }
    }
    
    func groupRunsByRow(runs: [Run2], orientation: Orientation) {
        // Now group by items in same row
        let horiz = orientation == .Horizontal
        let offsets = runs.map({$0.0})
        guard let minAxis = offsets.minElement({ horiz ? $0.x < $1.x : $0.y < $1.y }),
            maxAxis = offsets.maxElement({ horiz ? $0.x > $1.x : $0.y > $1.y }) else {
                return
        }
        
        let range = horiz ? minAxis.x...maxAxis.x : minAxis.y...maxAxis.y
        var run = Run()
        for a in range {
            if horiz {
                offsets.filter({$0.x == a})
            }
        }
        
        
    }
    
    func fasterRuns(withTiles userTiles: [Tile]) -> OrientationAxisRun {
        return [.Horizontal: fasterRuns(withTiles: userTiles, orientation: .Horizontal),
            .Vertical: fasterRuns(withTiles: userTiles, orientation: .Vertical)]
    }
    
    func fasterRuns(withTiles userTiles: [Tile], orientation: Orientation) -> AxisRun {
        let fixed = tiles.onBoardFixed()
        let count = userTiles.count
        var axis = [Int: Set<Offset>]()
        for f in fixed {
            if let offset = f.square?.offset {
                let a = orientation == .Horizontal ? offset.y : offset.x
                var offsets = Offsets()
                iterate(Offset.next, orientation: orientation, offset: offset, count: count, output: &offsets)
                iterate(Offset.prev, orientation: orientation, offset: offset, count: count, output: &offsets)
                if axis[a] != nil {
                    axis[a]?.union(offsets)
                } else {
                    axis[a] = Set(offsets)
                }
            }
        }
        return axis
        //return offsets.map({ offset in (offset, fixed.filter({ $0.square?.offset == offset }).first)})
    }
    
    /*func fasterRuns(withTiles userTiles: [Tile]) -> [Run2] {
        // There may be a faster way to do this. Simply get all of the fixed tiles on the board. Then
        // iterate in both directions. Removing tiles as you go. Then grouping by x,y
        let fixed = tiles.onBoardFixed()
        let count = userTiles.count
        var horizontal = Set<Offset>()
        var vertical = Set<Offset>()
        //var offsets = Set<Offset>()
        for f in fixed {
            if let offset = f.square?.offset {
                iterate(Offset.next, orientation: .Horizontal, offset: offset, count: count, output: &horizontal)
                iterate(Offset.prev, orientation: .Horizontal, offset: offset, count: count, output: &horizontal)
                iterate(Offset.next, orientation: .Vertical, offset: offset, count: count, output: &vertical)
                iterate(Offset.prev, orientation: .Vertical, offset: offset, count: count, output: &vertical)
            }
        }
        return horizontal.map({ offset in (offset, fixed.filter({ $0.square?.offset == offset }).first)})
    }*/
    
    /// - Returns: An array of `runs` surrounding tiles played on the board.
    func runs(withTiles userTiles: [Tile]) -> Runs {
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
            } else {
                let count = run.mapFilter({ $0.1 }).filter({ fixed.contains($0) }).count
                let diff = run.count - count
                if count > 0 && diff > 0 && diff <= rackAmount {
                    runs.append(run)
                }
            }
        }
        func checkOffset(offset: Offset?) {
            if let o = offset {
                buffer.append((o, fixed.filter({ $0.square?.offset == o }).first))
                validateRun(buffer)
                (1..<buffer.count).map({
                    validateRun(Array(buffer[$0..<buffer.count]))
                })
            }
        }
        
        // TODO: Add tiles immediately left and right of a valid offset.
        let range = 1...PapyrusDimensions
        for x in range {
            buffer = Run()
            range.map{ y in checkOffset(Offset(x: x, y: y)) }
        }
        for y in range {
            buffer = Run()
            range.map{ x in checkOffset(Offset(x: x, y: y)) }
        }
        return runs
    }
}