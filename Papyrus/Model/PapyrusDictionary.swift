//
//  PapyrusDictionary.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

enum DictionaryLanguage: String {
	case English = "CSW12"
}

struct Dictionary {
	private static let DefKey = "Def"
	private let dictionary: NSDictionary
	private let language: DictionaryLanguage
	
	init(_ language: DictionaryLanguage) {
		self.language = language
		guard let path = NSBundle.mainBundle().pathForResource(language.rawValue, ofType: "plist") else {
			dictionary = NSDictionary()
			return
		}
		dictionary = NSDictionary(contentsOfFile: path) ?? NSDictionary()
	}
	
	func defined(word: String) throws -> String {
		var current = dictionary
		var index = word.startIndex
		for char in word.uppercaseString.characters {
			if let inner = current[String(char)] as? NSDictionary {
				index = advance(index, 1)
				if index == word.endIndex {
					guard let def = inner.objectForKey(Dictionary.DefKey) as? String else {
						throw ValidationError.InvalidWord
					}
					return def
				}
				current = inner
			} else {
				throw ValidationError.InvalidWord
			}
		}
		throw ValidationError.InvalidWord
	}
}