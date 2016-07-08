//
//  RackPresenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 4/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

struct RackLayout {
    let spacing: CGFloat
    let inset: CGFloat
    let maximum: CGFloat
}
let defaultRackLayout = RackLayout(spacing: 4, inset: 8, maximum: CGFloat(Game.rackAmount))

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
    private let delegate: TileViewDelegate
    
    init(rect: CGRect, layout: RackLayout = defaultRackLayout, delegate: TileViewDelegate) {
        self.rect = rect
        self.delegate = delegate
        self.layout = layout
    }
    
    func refresh(in view: GameView, with game: Game) {
        var rack = game.player.rack
        if game.player is Computer {
            rack = rack.map({ _ in RackTile(" ", true) })
        }
        view.tileViews = tiles(for: rack, letterPoints: game.bag.dynamicType.letterPoints, draggable: game.player is Human)
    }
    
    func tiles(for rack: [RackTile], letterPoints: [Character: Int], draggable: Bool) -> [TileView] {
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
            let tileView = TileView(frame: tileRect, tile: tile.letter, points: points, onBoard: false, delegate: draggable ? delegate : nil)
            tileView.draggable = draggable
            return tileView
        })
    }
}
