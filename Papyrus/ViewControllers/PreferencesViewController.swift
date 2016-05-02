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
    
    func save(sender: UIAlertAction) {
        Preferences.sharedInstance.save()
        saveHandler()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        if Preferences.sharedInstance.hasChanges {
            let alert = UIAlertController(title: "Save?", message: "Changes have been made, saving will discard your current game.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: save))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

class PreferencesDataSource : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Preferences.sharedInstance.sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = Preferences.sharedInstance.sections[section].values.first!.count
        return rows
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Preferences.sharedInstance.sections[section].keys.first!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = Array(Preferences.sharedInstance.sections[indexPath.section].values.first!)[indexPath.row]
        cell.accessoryType = Preferences.sharedInstance.values[indexPath.section] == indexPath.row ? .Checkmark : .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Preferences.sharedInstance.values[indexPath.section] = indexPath.row
        tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
    }
    
}