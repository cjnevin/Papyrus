//
//  BoardView.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

class BoardView: UIView {
    private static let colorMap: [Modifier: UIColor] = [
        .Center: .Papyrus_Center,
        .Letterx2: .Papyrus_Letterx2,
        .Letterx3: .Papyrus_Letterx3,
        .Wordx2: .Papyrus_Wordx2,
        .Wordx3: .Papyrus_Wordx3,
        .None: .Papyrus_Tile
    ]
    
    var frames: [CGRect]?
    
    let range = 0..<PapyrusDimensions
    var squares: [Square]?
    var squareSize: CGFloat {
        return CGRectGetWidth(frame) / CGFloat(PapyrusDimensions)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.Papyrus_Square
    }
    
    override func layoutSubviews() {
        
    }
    
    func layoutSquares(squares: [Square]) {
        for square in squares.filter({$0.type != .None}) {
            let sublayer = CALayer()
            sublayer.backgroundColor = BoardView.colorMap[square.type]?.CGColor
            sublayer.frame = CGRect(
                x: squareSize * CGFloat(square.column),
                y: squareSize * CGFloat(square.row),
                width: squareSize, height: squareSize)
            layer.addSublayer(sublayer)
        }
        self.squares = squares
        self.frames = calculateFrames()
    }
    
    func calculateFrames() -> [CGRect] {
        let size = squareSize
        return range.flatMap { (row) -> [CGRect] in
            self.range.map { (col) -> CGRect in
                CGRect(x: CGFloat(row) * size,
                    y: CGFloat(col) * size,
                    width: size, height: size)
            }
        }
    }
    
}