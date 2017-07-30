//
//  PreferencesViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 2/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

class PreferencesViewController : UITableViewController {
    private let preferences: Preferences = .sharedInstance
    var saveHandler: (() -> ())!
    var dataSource: PreferencesDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = PreferencesDataSource(preferences: preferences)
        title = "Preferences"
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.register(loadable: BoardCell.self)
        tableView.register(loadable: SliderCell.self)
        tableView.reloadData()
    }
    
    func save(_ sender: UIAlertAction) {
        do {
            try preferences.save()
            saveHandler()
            dismiss(animated: true, completion: nil)
        } catch let err as PreferenceError {
            if err == PreferenceError.insufficientPlayers {
                let alert = UIAlertController(title: "Insufficient Players", message: "Please specify at least 2 players.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } catch {
            assert(false)
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        if preferences.hasChanges {
            let alert = UIAlertController(title: "Save?", message: "Changes have been made, saving will discard your current game.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: save))
            present(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
