//
//  Presenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 4/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

protocol Presenter {
    func refresh(in view: GameView, with game: Game)
}
