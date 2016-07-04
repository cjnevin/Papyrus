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

class RackPresenter: Presenter {
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
        view.tileViews = game.player is Computer ? nil : tiles(for: game.player.rack, letterPoints: game.bag.dynamicType.letterPoints)
    }
    
    func tiles(for rack: [RackTile], letterPoints: [Character: Int]) -> [TileView] {
        let width = RackPresenter.calculateTileWidth(forRect: rect, layout: layout)
        return rack.enumerated().map ({ (index, tile) in
            let x = layout.inset + ((layout.spacing + width) * CGFloat(index))
            let tileRect = CGRect(origin: rackPoint(x: x, y: 0), size: CGSize(width: width, height: width))
            let points = tile.isBlank ? 0 : letterPoints[tile.letter] ?? 0
            let tileView = TileView(frame: tileRect, tile: tile.letter, points: points, onBoard: false, delegate: delegate)
            tileView.draggable = true
            return tileView
        })
    }
}
