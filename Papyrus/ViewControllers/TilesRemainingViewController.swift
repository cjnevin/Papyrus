//
//  TilesRemainingViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class TilesRemainingViewController : UIViewController {
    
    private var distributionRenderer = TileDistributionRenderer()
    private var remainingRenderer = TilesRemainingRenderer()
    
    var completionHandler: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tap)
    }
    
    func tapped(gesture: UITapGestureRecognizer) {
        completionHandler?()
    }
    
    func prepareForPresentation(of bag: Bag, players: [Player]? = nil) {
        distributionRenderer.render(inView: view, filterBlank: false, characters: bag.dynamicType.letterPoints.map({ $0.0 }))
        remainingRenderer.render(inView: view, tileViews: distributionRenderer.tileViews, bag: bag, players: players)
    }
}
