//
//  SpriteKitExtensions.swift
//  Papyrus
//
//  Created by Chris Nevin on 17/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import SpriteKit

protocol Glowable {
    func glow(color: UIColor)
    func glow(start: UIColor, end: UIColor)
    func glow(start: UIColor, end: UIColor, duration: NSTimeInterval)
    func glow(start: UIColor, end: UIColor, duration: NSTimeInterval, count: Int)
    func warningGlow()
}

extension SKSpriteNode: Glowable {
    func warningGlow() {
        self.glow(self.color, end: UIColor.redColor(), duration: 0.5, count: 1)
    }
    func glow(start: UIColor, end: UIColor, duration: NSTimeInterval, count: Int) {
        if self.hasActions() { return }
        let defaultColor = SKAction.colorizeWithColor(start, colorBlendFactor: 0.5, duration: duration / NSTimeInterval(count))
        let newColor = SKAction.colorizeWithColor(end, colorBlendFactor: 0.5, duration: duration / NSTimeInterval(count))
        let action = SKAction.repeatAction(SKAction.sequence([newColor, defaultColor]), count: count)
        runAction(action)
    }
    
    func glow(start: UIColor, end: UIColor, duration: NSTimeInterval) {
        glow(start, end: end, duration: duration, count: 3)
    }
    
    func glow(start: UIColor, end: UIColor) {
        glow(start, end: end, duration: 0.25)
    }
    
    func glow(color: UIColor) {
        glow(self.color, end: color)
    }
}