//
//  ConfigureViewController.swift
//  Harold
//
//  Created by Harlan Haskins on 9/13/15.
//  Copyright © 2015 Harlan Haskins. All rights reserved.
//

import UIKit

class ConfigureViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let port = Credentials.port {
            usernameField.text = "\(port)"
        }
        passwordField.text = Credentials.password
        didChangeText(usernameField)
    }

    @IBAction func didChangeText(sender: UITextField) {
        let port = usernameField.text.flatMap { Int($0) }
        self.doneButton.enabled = !(port == nil || passwordField.isEmpty)
    }
    
    @IBAction func didTapDone(sender: UIBarButtonItem) {
        Credentials.port = usernameField.text.flatMap { Int($0) }
        Credentials.password = passwordField.text
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension UITextField {
    var isEmpty: Bool {
        return self.text?.isEmpty ?? true
    }
}