//
//  RiderViewController.swift
//  UberClone
//
//  Created by Rommel Rico on 2/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class RiderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutRiderSegue" {
            PFUser.logOut()
        }
    }
    
}
