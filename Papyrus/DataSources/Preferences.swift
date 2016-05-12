//
//  Preferences.swift
//  Papyrus
//
//  Created by Chris Nevin on 2/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

enum GameType: Int {
    case Scrabble
    case SuperScrabble
}

class Preferences {
    static let sharedInstance = Preferences()
    
    let sections = [["Game Type": ["Scrabble", "Super Scrabble"]],
                    ["Difficulty": ["Very Easy", "Easy", "Medium", "Hard"]],
                    ["Number of Opponents": ["1", "2", "3"]]]
    var values = [Int: Int]()
    var originalValues = [Int: Int]()
    
    var hasChanges: Bool {
        return values != originalValues
    }
    
    init() {
        load()
    }
    
    func load() {
        let defaults = [0: 0, 1: 3, 2: 1]
        for (index, _) in sections.enumerate() {
            values[index] = NSUserDefaults.standardUserDefaults().integerForKey(sections[index].keys.first!) ?? defaults[index]
        }
        originalValues = values
    }
    
    func save() {
        for (index, _) in sections.enumerate() {
            NSUserDefaults.standardUserDefaults().setInteger(values[index]!, forKey: sections[index].keys.first!)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        originalValues = values
    }
    
    var difficulty: Difficulty {
        switch values[1]! {
        case 0:
            return .VeryEasy
        case 1:
            return .Easy
        case 2:
            return .Medium
        default:
            return .Hard
        }
    }
    
    var gameType: GameType {
        return GameType(rawValue: values[0]!)!
    }
    
    var opponents: Int {
        return values[2]! + 1
    }
}
