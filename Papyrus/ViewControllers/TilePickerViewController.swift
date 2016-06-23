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
    
    func prepareForPresentation(bagType: Bag.Type) {
        renderer.render(inView: view, characters: bagType.letterPoints.map({ $0.0 }), delegate: self)
        renderer.tileViews?.forEach({ $0.tappable = true })
    }
    
    func tapped(tileView: TileView) {
        completionHandler?(tileView.tile)
    }
    
    func pickedUp(tileView: TileView) { }
    func frameForDropping(tileView: TileView) -> CGRect { return .zero }
    func dropped(tileView: TileView) { }
    
}