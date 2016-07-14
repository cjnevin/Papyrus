//
//  Preferences.swift
//  Papyrus
//
//  Created by Chris Nevin on 2/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

enum PreferenceError : ErrorProtocol {
    case insufficientPlayers
}

class Preferences {
    static let sharedInstance = Preferences()
    
    let sections = [["Board": ["", "", "", ""]],
                    ["Difficulty": ["Very Easy", "Easy", "Medium", "Hard"]],
                    ["AI Players": ["0", "1", "2", "3"]],
                    ["Human Players": ["0", "1", "2", "3"]],
                    ["Dictionary": ["SOWPODS", "TWL06", "WWF"]]]
    var values = [Int: Int]()
    var originalValues = [Int: Int]()
    
    var hasChanges: Bool {
        return values != originalValues
    }
    
    init() {
        load()
    }
    
    func load() {
        let defaults = [0: 0, 1: 3, 2: 1, 3: 1, 4: 0]
        for (index, _) in sections.enumerated() {
            if let value = UserDefaults.standard().object(forKey: sections[index].keys.first!) as? Int {
                values[index] = value
            } else {
                values[index] = defaults[index]
            }
        }
        originalValues = values
    }
    
    func save() throws {
        if values[2]! + values[3]! < 2 {
            throw PreferenceError.insufficientPlayers
        }
        for (index, _) in sections.enumerated() {
            UserDefaults.standard().set(values[index]!, forKey: sections[index].keys.first!)
        }
        UserDefaults.standard().synchronize()
        originalValues = values
    }
    
    var difficulty: Difficulty {
        switch values[1]! {
        case 0:
            return .veryEasy
        case 1:
            return .easy
        case 2:
            return .medium
        default:
            return .hard
        }
    }
    
    var gameType: GameType {
        return GameType(rawValue: values[0]!)!
    }
    
    var opponents: Int {
        return values[2]!
    }
    
    var humans: Int {
        return values[3]!
    }
    
    var dictionary: String {
        switch values[4]! {
        case 1:
            return "twl06_anagrams"
        case 2:
            return "wordswithfriends_anagrams"
        default:
            return "sowpods_anagrams"
        }
    }
}
