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
    func dropRect(for tileView: TileView) -> CGRect
    func dropped(tileView: TileView)
    func lifted(tileView: TileView)
    func tapped(tileView: TileView)
}

class TileView: UIView {
    var draggable: Bool = false {
        didSet {
            if draggable {
                makePressable(selector: #selector(pressed))
                makeMovable(selector: #selector(moved))
            } else {
                makeUnpressable()
                makeImmovable()
            }
        }
    }
    
    var tappable: Bool = false {
        didSet {
            tappable ? makeTappable(selector: #selector(tapped)) : makeUntappable()
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

extension TileView: Movable {
    func moved(with gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: superview)
    }
}

extension TileView: Pressable {
    func pressed(with gesture: UILongPressGestureRecognizer) {
        let shrunkScale: CGFloat = 0.9
        let normalScale: CGFloat = 1.0
        let animationDuration: TimeInterval = 0.1
        switch gesture.state {
        case .began:
            delegate?.lifted(tileView: self)
            let center = self.center
            UIView.animate(withDuration: animationDuration, animations: {
                self.bounds = self.initialFrame
                self.center = center
                self.superview?.bringSubview(toFront: self)
                self.transform = CGAffineTransform(scaleX: shrunkScale, y: shrunkScale)
            })
        case .cancelled, .ended, .failed:
            guard let newFrame = delegate?.dropRect(for: self) else {
                return
            }
            UIView.animate(withDuration: animationDuration, animations: {
                self.transform = CGAffineTransform(scaleX: normalScale, y: normalScale)
                self.center = CGPoint(x: newFrame.midX, y: newFrame.midY)
                self.bounds = newFrame
                }, completion: { (complete) in
                    self.delegate?.dropped(tileView: self)
            })
        default:
            break
        }
    }
}

extension TileView: Tappable {
    func tapped(with gesture: UITapGestureRecognizer) {
        delegate?.tapped(tileView: self)
    }
}

extension TileView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizers?.contains(gestureRecognizer) == true &&
            gestureRecognizers?.contains(otherGestureRecognizer) == true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
