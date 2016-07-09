//
//  TileSwapperViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class TileSwapperViewController : UIViewController, TileViewDelegate {
    
    private var renderer = TileDistributionRenderer()
    
    func prepareForPresentation(of rack: [RackTile]) {
        renderer.render(inView: view, filterBlank: false, characters: rack.map({$0.letter}), delegate: self)
        renderer.tileViews?.forEach({ $0.tappable = true; $0.onBoard = true })
    }
    
    func toSwap() -> [Character]? {
        return renderer.tileViews?.filter({ $0.highlighted }).map({ $0.tile })
    }
    
    func tapped(tileView: TileView) {
        tileView.highlighted = !tileView.highlighted
        // Use onBoard to indicate selection
        tileView.onBoard = !tileView.highlighted
    }
    
    func dropRect(for tileView: TileView) -> CGRect {
        fatalError()
    }
    
    func dropped(tileView: TileView) {
        fatalError()
    }
    
    func lifted(tileView: TileView) {
        fatalError()
    }
    
    func rearrange(tileView: TileView) -> Bool {
        fatalError()
    }
}
