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
        
        //Set the map to the request location.
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: requestLocation, span: span)
        self.map.setRegion(region, animated: true)
        
        //Add a pin to user location.
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = requestLocation
        objectAnnotation.title = "\(requestUsername)"
        self.map.addAnnotation(objectAnnotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pickUpRider(sender: AnyObject) {
        //TODO
    }

}
