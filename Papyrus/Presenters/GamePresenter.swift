//
//  GamePresenter.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import PapyrusCore

struct GamePresenter: Presenter {
    private let presenters: [Presenter]
    private let padding: CGFloat = 8
    private let scoreHeight: CGFloat = 80
    let boardPresenter: BoardPresenter
    let rackPresenter: RackPresenter
    let scorePresenter: ScorePresenter
    let definitionLabel: UILabel
    
    init(view: GameView, onPlacement: () -> (), onBlank: (tileView: TileView) -> ()) {
        let width = view.bounds.width
        
        let rackHeight = RackPresenter.calculateHeight(forRect: view.bounds)
        let rackRect = CGRect(x: 0, y: view.bounds.height - rackHeight, width: width, height: rackHeight)
        
        let edge = width - (padding * 2)
        let boardRect = CGRect(x: padding, y: rackRect.origin.y - edge, width: edge, height: edge).presentationRect
        boardPresenter = BoardPresenter(rect: boardRect, onPlacement: onPlacement, onBlank: onBlank)
        rackPresenter = RackPresenter(rect: rackRect, delegate: boardPresenter)
        
        let scoreRect = CGRect(origin: CGPoint(x: 0, y: padding), size: CGSize(width: width, height: scoreHeight))
        scorePresenter = ScorePresenter(layout: ScoreLayout(rect: scoreRect))
        
        let definitionY = scoreRect.origin.y + scoreRect.height
        definitionLabel = UILabel(frame: CGRect(x: padding,
                                                y: definitionY,
                                                width: width - (padding * 2),
                                                height: boardRect.origin.y - definitionY))
        definitionLabel.numberOfLines = 4
        definitionLabel.textAlignment = .center
        definitionLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        view.addSubview(definitionLabel)
        
        presenters = [boardPresenter, rackPresenter, scorePresenter]
    }
    
    func refresh(in view: GameView, with game: Game) {
        presenters.forEach({ $0.refresh(in: view, with: game) })
    }
}
