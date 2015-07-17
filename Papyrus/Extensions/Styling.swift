//
//  Styling.swift
//  Papyrus
//
//  Created by Chris Nevin on 16/10/2014.
//  Copyright (c) 2014 CJNevin. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func CenterTileColor() -> UIColor {
        return UIColor.purpleColor()
    }
    
    class func DoubleLetterTileColor() -> UIColor {
        return UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1)
    }
    
    class func DoubleWordTileColor() -> UIColor {
        return UIColor(red: 1, green: 182/255, blue: 193/255, alpha: 1)
    }
    
    class func TripleLetterTileColor() -> UIColor {
        return UIColor(red: 65/255, green: 105/255, blue: 225/255, alpha: 1)
    }
    
    class func TripleWordTileColor() -> UIColor {
        return UIColor(red: 205/255, green: 92/255, blue: 92/255, alpha: 1)
    }
    
    class func BoardTileColor() -> UIColor {
        return UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1)
    }
    
    class func SquareBorderColor() -> UIColor {
        return UIColor(red: 140/255, green: 140/255, blue: 120/255, alpha: 1)
    }
    
    class func TileBorderColor() -> UIColor {
        return UIColor(red: 100/255, green: 100/255, blue: 80/255, alpha: 1)
    }
    
    class func TileColorIlluminated() -> UIColor {
        return UIColor.whiteColor()
    }
    
    class func TileColor() -> UIColor {
        return UIColor(red: 240/255, green: 240/255, blue: 200/255, alpha: 1)
    }
}