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
    func glow(start: UIColor, end: UIColor, duration: NSTimeInterval?, count: Int?)
    func warningGlow()
}

extension SKSpriteNode: Glowable {
    
    /// Glow a different color to signify an error.
    func warningGlow() {
        self.glow(self.color, end: UIColor.redColor(), duration: 0.5, count: 1)
    }
    
    /// Glow from current color to `end` color with default count and duration.
    func glow(end: UIColor) {
        glow(color, end: end)
    }
    
    /// Glow `count` times between `start` and `end` colors for a total of `duration`.
    func glow(start: UIColor, end: UIColor, duration: NSTimeInterval? = 0.25, count: Int? = 3) {
        if hasActions() { return }
        guard let duration = duration, count = count else { return }
        let defaultColor = SKAction.colorizeWithColor(start, colorBlendFactor: 0.5, duration: duration / NSTimeInterval(count))
        let newColor = SKAction.colorizeWithColor(end, colorBlendFactor: 0.5, duration: duration / NSTimeInterval(count))
        let action = SKAction.repeatAction(SKAction.sequence([newColor, defaultColor]), count: count)
        runAction(action)
    }
}