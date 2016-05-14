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
    
    private var distributionPresenter = TileDistributionPresenter()
    private var countPresenter = TilesRemainingPresenter()
    
    var completionHandler: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tap)
    }
    
    func tapped(tapGesture: UITapGestureRecognizer) {
        completionHandler?()
    }
    
    func prepareForPresentation(bag: Bag, players: [Player]? = nil) {
        distributionPresenter.render(inView: view, filterBlank: false, distribution: bag.distribution)
        countPresenter.render(inView: view, tileViews: distributionPresenter.tileViews, bag: bag, players: players)
    }
}