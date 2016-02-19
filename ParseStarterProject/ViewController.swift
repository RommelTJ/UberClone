/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var toggleSignupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //Set the text fields to the textFieldDelegate so we can dismiss the keyboard
        self.username.delegate = self
        self.password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doSignUp(sender: AnyObject) {
        if username.text == "" || password.text == "" {
            displayAlert("Missing Field(s)", message: "Username and password are required.")
        }
    }
    
    @IBAction func doToggleSignup(sender: AnyObject) {
        
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
