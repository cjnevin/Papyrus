//
//  TilesRemainingRenderer.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

struct TilesRemainingRenderer {
    
    var countLabels: [UILabel]?
    var originalColor: UIColor?
    
    mutating func render(inView view: UIView, tileViews: [TileView]?, bag: Bag, players: [Player]? = nil) {
        countLabels?.forEach({ $0.removeFromSuperview() })
        countLabels = []
        tileViews?.forEach({ tileView in
            let char = tileView.tile
            var count = bag.remaining.filter({ $0 == char }).count
            players?.forEach({ player in
                count += player.rack.filter({ $0.letter == char || ($0.isBlank == true && char == Game.blankLetter) }).count
            })
            let countLabel = UILabel(frame: CGRect(x: tileView.frame.origin.x + tileView.frame.size.width - 15, y: tileView.frame.origin.y + tileView.frame.size.height - 15, width: 20, height: 20))
            countLabel.text = "\(count)"
            countLabel.font = .boldSystemFont(ofSize: 10)
            countLabel.textColor = count == 0 ? .red : .black
            countLabel.textAlignment = .center
            countLabel.backgroundColor = .white
            countLabel.clipsToBounds = true
            countLabel.layer.cornerRadius = 10
            countLabel.layer.borderColor = UIColor.lightGray.cgColor
            countLabel.layer.borderWidth = 1
            view.addSubview(countLabel)
            countLabels?.append(countLabel)
        })
    }
    
}
