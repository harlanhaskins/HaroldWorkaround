//
//  ViewController.swift
//  Harold
//
//  Created by Harlan Haskins on 9/10/15.
//  Copyright © 2015 Harlan Haskins. All rights reserved.
//

import UIKit
import Alamofire
import BRYXBanner

class ViewController: UITableViewController {
    
    var harold: Harold? {
        didSet {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Harold"
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "loadFiles", forControlEvents: .AllEvents)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if Credentials.port == nil || Credentials.password == nil {
            self.performSegueWithIdentifier("ShowConfigure", sender: nil)
        } else {
            loadFiles()
        }
    }
    
    func loadFiles() {
        HaroldAPI.loadFilenames { harold, error in
            self.harold = harold
            if let error = error {
                self.handleError(error)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.harold?.filenames.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell", forIndexPath: indexPath)
        if let harold = self.harold {
            let name = harold.filenames[indexPath.row]
            cell.textLabel?.text = name
            cell.accessoryType = self.harold?.selected == name ? .Checkmark : .None
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let harold = self.harold else { return }
        let filename = harold.filenames[indexPath.row]
        if filename == harold.selected { return }
        let old = harold
        self.harold = Harold(filenames: harold.filenames, selected: filename)
        HaroldAPI.select(filename) { error in
            if let error = error {
                self.handleError(error)
                self.harold = old
            } else {
                Banner.showSuccess("Successfully changed Harold tone to \"\(filename)\"")
            }
        }
    }
    
    func handleError(error: ErrorType) {
        switch error {
        case HaroldError.URL:
            Banner.showError("Invalid URL. Make sure you've entered a username and password.")
        default:
            Banner.showError("\(error)")
        }
    }
}

extension Banner {
    static func showError(error: String) {
        Banner(title: "Error", subtitle: error, image: UIImage(named: "Caution"), backgroundColor: Pallette.red).show(duration: 3.0)
    }
    static func showSuccess(message: String? = nil) {
        Banner(title: "Success", subtitle: message, image: UIImage(named: "ThumbsUp"), backgroundColor: Pallette.green).show(duration: 3.0)
    }
}
