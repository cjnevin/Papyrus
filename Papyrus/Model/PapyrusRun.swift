//
//  PapyrusRun.swift
//  Papyrus
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    typealias Run = [Offset]
    typealias Runs = [Run]
    
    func currentRuns() -> Runs {
        return runs(withTiles: tiles(withPlacement: .Rack, owner: player))
    }
    
    /// Return an array of `runs` surrounding tiles played on the board.
    func runs(withTiles userTiles: [Tile]) -> Runs {
        // Get filled tiles.
        let fixedTiles = tiles(withPlacement: .Fixed, owner: nil)
        
        // If filled tile count is zero, we have an easy situation, must intersect EMPTY center square.
        let fixedOffsets = fixedTiles.count == 0 ? [PapyrusMiddleOffset!] : fixedTiles.filter({$0.square != nil}).map({$0.square!.offset})
        
        let permutes = permutations(userTiles)
        
        // Collect runs:
        // - Check for perpendicular runs intersecting existing words first
        // - moving 7 (or user tile count) in each direction (excluding tiles
        // - that aren't ours) record each stop in each direction.
        //
        // - Next, check intersections in parallel.
        
        var runs = Runs()
        for tileOffset in fixedOffsets {
            func run(orientation: Orientation, count: Int) -> [Offset] {
                var innerOffsets = Run(arrayLiteral: tileOffset)
                func runInDirection(orientation: Orientation, count: Int, amount: Int) {
                    var i = 0
                    var offset = tileOffset
                    while (count < 0 && i > count) || (count > 0 && i < count) {
                        // While next offset is available
                        guard let o = count < 0 ? offset.prev(orientation) : offset.next(orientation) else {
                            break
                        }
                        offset = o
                        innerOffsets.append(o)
                        // Only advance counter if this offset is unfilled.
                        // Otherwise we want to iterate more times until all tiles have been used.
                        i += fixedTiles.filter({$0.square?.offset == o}).count == 0 ? amount : 0
                    }
                }
                runInDirection(orientation, count: count, amount: 1)
                runInDirection(orientation, count: -count, amount: -1)
                // Filter duplicates and return sorted.
                return Set(innerOffsets).sort()
            }
            for o in Orientation.both {
                let ran = run(o, count: userTiles.count - 1)
                // Ignore duplicate paths
                if runs.filter({$0 == ran}).count == 0 {
                    runs.append(ran)
                }
            }
        }
        print(runs)
        for run in runs {
            print(run.map{ tile($0) })
        }
        return runs
    }
}