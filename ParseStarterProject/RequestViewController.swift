//
//  RequestViewController.swift
//  UberClone
//
//  Created by Rommel Rico on 2/21/16.
//  Copyright © 2016 Rommel. All rights reserved.
//

import UIKit
import MapKit
import Parse

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
        //Query for the request in Parse.
        let query = PFQuery(className:"RiderRequest")
        query.whereKey("username", equalTo: requestUsername)
        query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let query = PFQuery(className: "RiderRequest")
                        query.getObjectInBackgroundWithId(object.objectId!, block: { (object: PFObject?, error: NSError?) -> Void in
                            if error != nil {
                                print("error: \(error)")
                            } else if let riderRequest = object {
                                riderRequest["driverResponse"] = PFUser.currentUser()?.username!
                                riderRequest.saveInBackground()
                            }
                        })
                    }
                }
            } else {
                print("Error: \(error), \(error?.userInfo)")
            }
        })
    }

}
