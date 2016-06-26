//
//  UIKitExtensions.swift
//  Papyrus
//
//  Created by Chris Nevin on 16/10/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import UIKit

private func rgba(r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> UIColor {
    return UIColor(red: r, green: g, blue: b, alpha: a)
}

private func irgba(r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1.0) -> UIColor {
    let m: CGFloat = 255
    return rgba(CGFloat(r) / m, CGFloat(g) / m, CGFloat(b) / m, a)
}

enum Color {
    enum Square {
        private static let wordMultiplierColors: [Multiplier: UIColor] = [
            .Double: irgba(255, 182, 193),
            .Triple: irgba(205, 92, 92, 0.8),
            .Quadruple: irgba(65, 225, 65, 0.6)]
        private static let letterMultiplierColors: [Multiplier: UIColor] = [
            .Double: irgba(173, 216, 230),
            .Triple: irgba(65, 105, 225, 0.6),
            .Quadruple: irgba(205, 92, 205, 0.8)]
        
        private enum Multiplier: Int {
            case Double = 2
            case Triple
            case Quadruple
            
            var letterColor: UIColor? {
                return letterMultiplierColors[self]
            }
            
            var wordColor: UIColor? {
                return wordMultiplierColors[self]
            }
        }
        
        static let Default = irgba(255, 255, 235, 0.8)
        static let Center = irgba(170, 100, 170)
        static let Star = Center.multiplyChannels()
        
        static func color(forLetterMultiplier letterMultiplier: Int, wordMultiplier: Int) -> UIColor {
            return (
                Multiplier(rawValue: letterMultiplier)?.letterColor ??
                Multiplier(rawValue: wordMultiplier)?.wordColor ??
                Default)
        }
    }
    enum Tile {
        static let Border = irgba(100, 100, 80)
        static let Default = irgba(240, 240, 200)
        static let Illuminated = UIColor.whiteColor()
    }
}

extension UIColor {
    func multiplyChannels(m: CGFloat = 0.7) -> UIColor {
        var r = CGFloat(0), g = CGFloat(0), b = CGFloat(0), a = CGFloat(0)
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * m, green: g * m, blue: b * m, alpha: a)
    }
}