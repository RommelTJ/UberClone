//
//  RequestViewController.swift
//  UberClone
//
//  Created by Rommel Rico on 2/21/16.
//  Copyright © 2016 Rommel. All rights reserved.
//

import UIKit
import MapKit

class RequestViewController: UIViewController, CLLocationManagerDelegate {

    //Properties
    var requestLocation: CLLocationCoordinate2D!
    var requestUsername: String!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(requestUsername)
        print(requestLocation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pickUpRider(sender: AnyObject) {
        //TODO
    }

}
