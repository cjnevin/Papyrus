//
//  TileView.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class TileView: UIView {
    static let LetterFontSize: CGFloat = 25
    
    var letterLabel: UILabel!
    var pointLabel: UILabel!
    weak var tile: Tile?
    
    init(frame: CGRect, tile: Tile) {
        super.init(frame: frame)
        
        let w = CGRectGetWidth(frame)
        let h = CGRectGetHeight(frame)
        
        self.tile = tile
        letterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
        letterLabel.minimumScaleFactor = 0.5
        letterLabel.font = UIFont.systemFontOfSize(TileView.LetterFontSize)
        letterLabel.text = "\(tile.letter)".uppercaseString
        letterLabel.adjustsFontSizeToFitWidth = true
        letterLabel.textAlignment = .Center
        letterLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        letterLabel.layer.borderWidth = 0.75
        letterLabel.layer.masksToBounds = true
        self.addSubview(letterLabel)
        
        if tile.value > 0 {
            pointLabel = UILabel(frame: CGRect(x: w - 15, y: h - 15, width: 10, height: 10))
            pointLabel.text = "\(tile.value)"
            pointLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            pointLabel.minimumScaleFactor = 0.05
            pointLabel.adjustsFontSizeToFitWidth = true
            pointLabel.textAlignment = .Right
            pointLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            self.addSubview(pointLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layer.borderColor = UIColor.Papyrus_TileBorder.CGColor
        layer.borderWidth = 0.75
        layer.masksToBounds = true
        backgroundColor = UIColor.Papyrus_Tile
    }
    
    func setTile(tile: Tile) {
        letterLabel.text = "\(tile.letter)".uppercaseString
        pointLabel.text = "\(tile.value)"
    }
}