//
//  PreferencesViewController.swift
//  Papyrus
//
//  Created by Chris Nevin on 2/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

class PreferencesViewController : UITableViewController {
    
    var saveHandler: (() -> ())!
    var dataSource: PreferencesDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = PreferencesDataSource()
        title = "Preferences"
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()
    }
    
    func save(_ sender: UIAlertAction) {
        do {
            try Preferences.sharedInstance.save()
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
        if Preferences.sharedInstance.hasChanges {
            let alert = UIAlertController(title: "Save?", message: "Changes have been made, saving will discard your current game.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: save))
            present(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

class PreferencesDataSource : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Preferences.sharedInstance.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = Preferences.sharedInstance.sections[section].values.first!.count
        return rows
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Preferences.sharedInstance.sections[section].keys.first!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = Array(Preferences.sharedInstance.sections[(indexPath as NSIndexPath).section].values.first!)[(indexPath as NSIndexPath).row]
        cell.accessoryType = Preferences.sharedInstance.values[(indexPath as NSIndexPath).section] == (indexPath as NSIndexPath).row ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Preferences.sharedInstance.values[(indexPath as NSIndexPath).section] = (indexPath as NSIndexPath).row
        tableView.reloadSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: .fade)
    }
    
}
