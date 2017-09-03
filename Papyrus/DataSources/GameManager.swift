//
//  GameManager.swift
//  Papyrus
//
//  Created by Chris Nevin on 3/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

private func call(onMain block: @escaping () -> ()) {
    DispatchQueue.main.async(execute: block)
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
    
    func restoreGame(eventHandler handler: @escaping EventHandler, completion: @escaping (Bool) -> ()) {
        eventHandler = handler
        gameQueue.addOperation { [weak self] in
            guard let strongSelf = self, let dictionary = GameManager.dictionary else {
                call(onMain: { completion(false) })
                return
            }
            strongSelf.game = try? Game(restoring: strongSelf.cacheURL, dictionary: dictionary, eventHandler: strongSelf.wrappedEventHandler)
            call(onMain: { [weak strongSelf] in completion(strongSelf?.game != nil) })
        }
    }
    
    func newGame(eventHandler handler: @escaping EventHandler, completion: @escaping Completion) {
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
    
    func hint(completion: @escaping (Solution?) -> ()) {
        enqueue {
            $0.suggestion() { solution in
                call(onMain: { completion(solution) })
            }
        }
    }
    
    func play(solution: Solution) {
        enqueue() { game in
            game.play(solution: solution)
            game.nextTurn()
        }
    }
    
    func shuffle(completion: @escaping Completion = { }) {
        enqueue { [weak self] in
            $0.shuffleRack()
            self?.saveCache()
            call(onMain: completion)
        }
    }
    
    func skip(completion: @escaping Completion = { }) {
        enqueue {
            $0.skip()
            call(onMain: completion)
        }
    }
    
    func start(completion: @escaping Completion = { }) {
        enqueue {
            $0.start()
            call(onMain: completion)
        }
    }
    
    func swap(tiles: [Character]?, completion: @escaping Completion = { }) {
        guard let letters = tiles, letters.count > 0 else {
            return
        }
        enqueue {
            _ = $0.swap(tiles: letters)
            call(onMain: completion)
        }
    }
    
    func swapAll(completion: @escaping Completion = { }) {
        swap(tiles: game?.player.rack.map({ $0.letter }),
             completion: completion)
    }
    
    func validate(tiles: LetterPositions,
                  blanks: Positions,
                  completion: @escaping (Solution?) -> ()) {
        guard game?.ended == false && game?.player is Human else {
            completion(nil)
            return
        }
        enqueue { game in
            switch game.validate(positions: tiles, blanks: blanks) {
            case let .valid(solution):
                call { completion(solution) }
            default:
                call { completion(nil) }
            }
        }
    }
    
    private func enqueue(_ f: @escaping (Game) -> ()) {
        gameQueue.addOperation { [weak game] in
            guard let game = game else { return }
            f(game)
        }
    }
}
