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
                                
                                //Launch Apple Maps directions to location.
                                let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                                CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                                    if error != nil {
                                        print("Error: \(error)")
                                    } else {
                                        if placemarks?.count > 0 {
                                            let placemark = placemarks![0] as CLPlacemark
                                            let mkPlacemark = MKPlacemark(placemark: placemark)
                                            let mapItem = MKMapItem(placemark: mkPlacemark)
                                            mapItem.name = "\(self.requestUsername)"
                                            //You could also choode: MKLaunchOptionsDirectionsModeWalking
                                            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                            mapItem.openInMapsWithLaunchOptions(launchOptions)
                                        } else {
                                            print("No placemarks received from CLGeocoder")
                                        }
                                    }
                                })
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
