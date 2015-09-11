//
//  Lexicon.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

// TODO: Refactor using GADDAG/DAWG or similar approach.

import Foundation

struct Lexicon {
    static let sharedInstance = Lexicon()
    let DefKey = "Def"
    
    typealias LexiconType = [String: AnyObject]
    var dictionary: LexiconType?
    private init() {
        if let path = NSBundle.mainBundle().pathForResource("CSW12", ofType: "plist"), contents = NSDictionary(contentsOfFile: path) as? LexiconType {
            self.dictionary = contents
        }
    }
    
    /// Determine if a word is defined in the dictionary.
    func defined(word: String) throws -> String {
        var current = dictionary
        var index = word.startIndex
        for char in word.uppercaseString.characters {
            if let inner = current?[String(char)] as? LexiconType {
                index = index.advancedBy(1)
                if index == word.endIndex {
                    guard let def = inner[DefKey] as? String else {
                        throw ValidationError.UndefinedWord(word)
                    }
                    return def
                }
                current = inner
            } else {
                throw ValidationError.UndefinedWord(word)
            }
        }
        throw ValidationError.UndefinedWord(word)
    }
    
    func anagramsOf(letters: String, length: Int, prefix: String,
        fixedLetters: [(Int, Character)], fixedCount: Int, source: AnyObject,
        inout results: [String])
    {
        guard let source = source as? LexiconType else { return }
        let prefixLength = prefix.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if let c = fixedLetters.filter({$0.0 == prefixLength}).map({$0.1}).first, newSource = source[String(c)] {
            let newPrefix = prefix + String(c)
            let reverseFiltered = fixedLetters.filter({$0.0 != prefixLength})
            anagramsOf(letters, length: length, prefix: newPrefix,
                fixedLetters: reverseFiltered, fixedCount: fixedCount,
                source: newSource, results: &results)
            return
        }
        
        // See if word exists
        if let _ = source.indexForKey(DefKey) where fixedLetters.count == 0 &&
            prefixLength == length && prefixLength > fixedCount {
            results.append(prefix)
        }
        // Before continuing...
        for (key, value) in source {
            // Search for ? or key
            if let range = letters.rangeOfString("?") ?? letters.rangeOfString(key) {
                // Strip key/?
                let newLetters = letters.stringByReplacingCharactersInRange(range, withString: "")
                // Create anagrams with remaining letters
                anagramsOf(newLetters, length: length, prefix: prefix + key,
                    fixedLetters: fixedLetters, fixedCount: fixedCount,
                    source: value, results: &results)
            }
        }
    }
}