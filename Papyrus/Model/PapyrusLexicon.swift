//
//  PapyrusLexicon.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

struct Lexicon {
    static let sharedInstance = Lexicon()
    
    private typealias LexiconType = [String: AnyObject]
    private var dictionary: LexiconType?
    private init() {
        if let path = NSBundle.mainBundle().pathForResource("CSW12", ofType: "plist"), contents = NSDictionary(contentsOfFile: path) as? LexiconType {
            self.dictionary = contents
        }
    }
    
    /// Determine if a word is defined in the dictionary.
    func defined(word: String) throws -> String {
        let DefKey = "Def"
        var current = dictionary
        var index = word.startIndex
        for char in word.uppercaseString.characters {
            if let inner = current?[String(char)] as? LexiconType {
                index = advance(index, 1)
                if index == word.endIndex {
                    guard let def = inner[DefKey] as? String else {
                        throw ValidationError.Undefined(word)
                    }
                    return def
                }
                current = inner
            } else {
                throw ValidationError.Undefined(word)
            }
        }
        throw ValidationError.Undefined(word)
    }
}