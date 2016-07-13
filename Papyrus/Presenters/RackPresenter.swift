//
//  RackPresenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 4/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

struct RackLayout {
    let spacing: CGFloat
    let inset: CGFloat
    let maximum: CGFloat
}
let defaultRackLayout = RackLayout(spacing: 4, inset: 8, maximum: CGFloat(Game.rackAmount))

struct RackedTile {
    let tile: Character
    let points: Int
    let rect: CGRect
    let movable: Bool
}

struct RackPresenter: Presenter {
    private static func calculateTileWidth(forRect rect: CGRect, layout: RackLayout = defaultRackLayout) -> CGFloat {
        let insetWidth = rect.width - layout.inset * 2
        let spacersWidth = layout.spacing * (layout.maximum - 1)
        return (insetWidth - spacersWidth) / layout.maximum
    }
    
    static func calculateHeight(forRect rect: CGRect, layout: RackLayout = defaultRackLayout) -> CGFloat {
        return (layout.inset * 2) + calculateTileWidth(forRect: rect, layout: layout)
    }
    
    private func rackPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: rect.origin.x + x, y: rect.origin.y + y + layout.inset)
    }
    
    private let rect: CGRect
    private let layout: RackLayout
    
    init(rect: CGRect, layout: RackLayout = defaultRackLayout) {
        self.rect = rect
        self.layout = layout
    }
    
    func refresh(in view: GameView, with game: Game) {
        func toBlank(tile: RackTile) -> RackTile {
            return RackTile(letter: " ", isBlank: true)
        }
        let player = game.player
        let rack = player is Computer ? player.rack.map(toBlank) : player.rack
        view.rackedTiles = tiles(for: rack, letterPoints: game.bag.dynamicType.letterPoints, movable: player is Human)
    }
    
    func tiles(for rack: [RackTile], letterPoints: [Character: Int], movable: Bool) -> [RackedTile] {
        let width = RackPresenter.calculateTileWidth(forRect: rect, layout: layout)
        var inset = layout.inset
        if CGFloat(rack.count) < layout.maximum {
            // Offset centred regardless of amount of tiles in rack
            let amount = layout.maximum - CGFloat(rack.count)
            inset += ((layout.spacing + width) * amount) / 2
        }
        return rack.enumerated().map ({ (index, tile) in
            let x = inset + ((layout.spacing + width) * CGFloat(index))
            let tileRect = CGRect(origin: rackPoint(x: x, y: 0), size: CGSize(width: width, height: width))
            let points = tile.isBlank ? 0 : letterPoints[tile.letter] ?? 0
            return RackedTile(tile: tile.letter, points: points, rect: tileRect, movable: movable)
        })
    }
}
