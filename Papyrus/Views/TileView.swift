//
//  TileView.swift
//  Papyrus
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

protocol TileViewDelegate {
    func pickedUp(_ tileView: TileView)
    func frameForDropping(_ tileView: TileView) -> CGRect
    func dropped(_ tileView: TileView)
    func tapped(_ tileView: TileView)
}

class TileView: UIView {
    var draggable: Bool = false {
        didSet {
            draggable ? makeDraggable() : makeUndraggable()
        }
    }
    
    var tappable: Bool = false {
        didSet {
            tappable ? makeTappable() : makeUntappable()
        }
    }
    
    var isPlaced: Bool {
        return x != nil && y != nil
    }
    
    var initialFrame: CGRect!
    var initialPoint: CGPoint!
    var delegate: TileViewDelegate?
    var tile: Character! {
        didSet {
            setNeedsDisplay()
        }
    }
    var points: Int!
    var onBoard: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isBlank: Bool {
        return points == 0
    }
    
    var x: Int?
    var y: Int?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialPoint = center
        initialFrame = frame
    }
    
    init(frame: CGRect, tile: Character, points: Int, onBoard: Bool, delegate: TileViewDelegate? = nil) {
        self.delegate = delegate
        self.tile = tile
        self.points = points
        self.onBoard = onBoard
        super.init(frame: frame)
        initialPoint = center
        initialFrame = frame
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {
        guard let tile = tile, context = UIGraphicsGetCurrentContext() else {
            return
        }
        let drawable = TileDrawable(tile: tile, points: points, rect: rect, onBoard: onBoard, highlighted: highlighted)
        drawable.draw(renderer: context)
    }
}

// MARK: - UIGestures

extension TileView : UIGestureRecognizerDelegate {
    func makeDraggable() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPress))
        pressGesture.minimumPressDuration = 0.001
        pressGesture.delegate = self
        addGestureRecognizer(pressGesture)
    }
    
    func makeUndraggable() {
        gestureRecognizers?.forEach { if $0 is UIPanGestureRecognizer || $0 is UILongPressGestureRecognizer { removeGestureRecognizer($0) } }
    }
    
    func makeTappable() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    func makeUntappable() {
        gestureRecognizers?.forEach { if $0 is UITapGestureRecognizer { removeGestureRecognizer($0) } }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizers?.contains(gestureRecognizer) == true &&
            gestureRecognizers?.contains(otherGestureRecognizer) == true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func didTap(_ tapGesture: UITapGestureRecognizer) {
        delegate?.tapped(self)
    }
    
    func didPress(_ pressGesture: UILongPressGestureRecognizer) {
        switch pressGesture.state {
        case .began:
            delegate?.pickedUp(self)
            let center = self.center
            UIView.animate(withDuration: 0.1, animations: {
                self.bounds = self.initialFrame
                self.center = center
                self.superview?.bringSubview(toFront: self)
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
        case .cancelled, .ended, .failed:
            guard let newFrame = delegate?.frameForDropping(self) else {
                return
            }
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.center = CGPoint(x: newFrame.midX, y: newFrame.midY)
                self.bounds = newFrame
            }, completion: { (complete) in
                self.delegate?.dropped(self)
            })
        default:
            break
        }
    }
    
    func didPan(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        panGesture.setTranslation(CGPoint.zero, in: superview)
    }
}
