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
    @IBOutlet var letterLabel: UILabel!
    @IBOutlet var pointLabel: UILabel!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = UIColor.Papyrus_Tile
    }
    
    func setTile(tile: Tile) {
        letterLabel.text = "\(tile.letter)"
        pointLabel.text = "\(tile.value)"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
}