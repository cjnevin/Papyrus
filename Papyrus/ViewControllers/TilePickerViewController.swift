//
//  TilePickerViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 29/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class TilePickerViewController : UIViewController, TileViewDelegate {
    
    private var renderer = TileDistributionRenderer()
    
    var completionHandler: ((Character) -> ())? = nil
    
    func prepareForPresentation(of bagType: Bag.Type) {
        renderer.render(inView: view, characters: bagType.letterPoints.map({ $0.0 }), delegate: self)
        renderer.tileViews?.forEach({ $0.tappable = true })
    }
    
    func tapped(tileView: TileView) {
        completionHandler?(tileView.tile)
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
}
