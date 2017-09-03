//
//  GameType.swift
//  Papyrus
//
//  Created by Chris Nevin on 03/09/2017.
//  Copyright © 2017 CJNevin. All rights reserved.
//

import Foundation

fileprivate extension URL {
	static func gameFileURL(`for` name: String) -> URL {
		return URL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "json")!)
	}
}

let allGameTypes: [GameType] = [
	ScrabbleGameType(),
	SuperScrabbleGameType(),
	WordfeudGameType(),
	WordsWithFriendsGameType()
]

protocol GameType {
	var fileURL: URL { get }
}

struct ScrabbleGameType: GameType {
	let fileURL = URL.gameFileURL(for: "Scrabble")
}

struct SuperScrabbleGameType: GameType {
	let fileURL = URL.gameFileURL(for: "SuperScrabble")
}

struct WordfeudGameType: GameType {
	let fileURL = URL.gameFileURL(for: "Wordfeud")
}

struct WordsWithFriendsGameType: GameType {
	let fileURL = URL.gameFileURL(for: "WordsWithFriends")
}
