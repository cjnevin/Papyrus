//
//  GameManager.swift
//  Papyrus
//
//  Created by Chris Nevin on 3/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

private func call(onMain block: () -> ()) {
    DispatchQueue.main.async(execute: block)
}

enum GameType: Int {
    case scrabble = 0
    case superScrabble
    case wordfeud
    case wordsWithFriends
    
    var fileURL: URL {
        let fileNames: [GameType: String] = [.scrabble: "Scrabble", .superScrabble: "SuperScrabble", .wordfeud: "Wordfeud", .wordsWithFriends: "WordsWithFriends"]
        return URL(fileURLWithPath: Bundle.main.path(forResource: fileNames[self], ofType: "json")!)
    }
}


class GameManager {
    typealias Completion = () -> ()
    private let gameQueue = OperationQueue()
    private let cacheURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/lastGame.json")
    private static var dictionary: AnagramDictionary?
    
    static let sharedInstance = GameManager()
    
    private(set) var game: Game?
    private(set) var eventHandler: EventHandler?
    
    init() {
        gameQueue.maxConcurrentOperationCount = 1
        prepareDictionary()
    }
    
    private func prepareDictionary() {
        if GameManager.dictionary == nil {
            gameQueue.addOperation {
                GameManager.dictionary = AnagramDictionary(filename: Preferences.sharedInstance.dictionary)
            }
        }
    }
    
    func clearCache() {
        _ = try? FileManager.default.removeItem(at: cacheURL)
    }
    
    func saveCache() {
        _ = game?.save(to: cacheURL)
    }
    
    func wrappedEventHandler(event: GameEvent) {
        call { [weak self] in
            switch event {
            case .over(_, _):
                self?.clearCache()
            case .turnEnded(_):
                self?.saveCache()
            default:
                break
            }
            self?.eventHandler?(event)
        }
    }
    
    func restoreGame(eventHandler handler: EventHandler, completion: (success: Bool) -> ()) {
        eventHandler = handler
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self, let dictionary = GameManager.dictionary else {
                call(onMain: { completion(success: false) })
                return
            }
            strongSelf.game = try? Game(restoring: strongSelf.cacheURL, dictionary: dictionary, eventHandler: strongSelf.wrappedEventHandler)
            call(onMain: { [weak strongSelf] in completion(success: strongSelf?.game != nil) })
        }
    }
    
    func newGame(eventHandler handler: EventHandler, completion: Completion) {
        endGame()
        clearCache()
        eventHandler = handler
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self, let dictionary = GameManager.dictionary else {
                call(onMain: completion)
                return
            }
            func makePlayers(_ count: Int, f: () -> (Player)) -> [Player] {
                return (0..<count).map({ _ in f() })
            }
            let prefs = Preferences.sharedInstance
            let players = (makePlayers(prefs.opponents, f: { Computer(difficulty: prefs.difficulty) }) +
                makePlayers(prefs.humans, f: { Human() }))
            
            strongSelf.game = try! Game(
                config: prefs.gameType.fileURL,
                dictionary: dictionary,
                players: players, eventHandler: strongSelf.wrappedEventHandler)
        
            call(onMain: completion)
        }
    }
    
    func endGame() {
        gameQueue.cancelAllOperations()
        game?.stop()
        gameQueue.waitUntilAllOperationsAreFinished()
        eventHandler = nil
        game = nil
    }
    
    func hint(completion: (solution: Solution?) -> ()) {
        enqueue {
            $0.suggestion() { solution in
                call(onMain: { completion(solution: solution) })
            }
        }
    }
    
    func play(solution: Solution) {
        enqueue() { game in
            game.play(solution: solution)
            game.nextTurn()
        }
    }
    
    func shuffle(completion: Completion = { }) {
        enqueue { [weak self] in
            $0.shuffleRack()
            self?.saveCache()
            call(onMain: completion)
        }
    }
    
    func skip(completion: Completion = { }) {
        enqueue {
            $0.skip()
            call(onMain: completion)
        }
    }
    
    func start(completion: Completion = { }) {
        enqueue {
            $0.start()
            call(onMain: completion)
        }
    }
    
    func swap(tiles: [Character]?, completion: Completion = { }) {
        guard let letters = tiles, letters.count > 0 else {
            return
        }
        enqueue {
            _ = $0.swap(tiles: letters)
            call(onMain: completion)
        }
    }
    
    func swapAll(completion: Completion = { }) {
        swap(tiles: game?.player.rack.map({ $0.letter }),
             completion: completion)
    }
    
    func validate(tiles: LetterPositions,
                  blanks: Positions,
                  completion: (solution: Solution?) -> ()) {
        guard game?.ended == false && game?.player is Human else {
            completion(solution: nil)
            return
        }
        enqueue { game in
            switch game.validate(positions: tiles, blanks: blanks) {
            case let .valid(solution):
                call { completion(solution: solution) }
            default:
                call { completion(solution: nil) }
            }
        }
    }
    
    private func enqueue(_ f: (game: Game) -> ()) {
        gameQueue.addOperation { [weak game] in
            guard let game = game else { return }
            f(game: game)
        }
    }
}
