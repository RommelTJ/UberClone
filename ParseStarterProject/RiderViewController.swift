//
//  RiderViewController.swift
//  UberClone
//
//  Created by Rommel Rico on 2/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //Properties
    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    @IBOutlet weak var callAnUberButton: UIButton!
    var riderRequestActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutRiderSegue" {
            PFUser.logOut()
        }
    }
    
    @IBAction func callAnUber(sender: AnyObject) {
        if riderRequestActive == false {
            let riderRequest = PFObject(className:"RiderRequest")
            riderRequest["username"] = PFUser.currentUser()?.username
            riderRequest["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            riderRequest.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                    self.callAnUberButton.setTitle("Cancel An Uber", forState: .Normal)
                    self.riderRequestActive = true
                } else {
                    let alert = UIAlertController(title: "Could not call Uber", message: "Please try again later", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        } else {
            riderRequestActive = false
            self.callAnUberButton.setTitle("Call An Uber", forState: .Normal)
            let query = PFQuery(className:"RiderRequest")
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    print("Successfully retrieved \(objects?.count) requests.")
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                } else {
                    print("Error: \(error), \(error?.userInfo)")
                }
            })
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Set the map region to current location
        let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        latitude = locValue.latitude
        longitude = locValue.longitude
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        self.map.setRegion(region, animated: true)
        
        //Add a pin to user location.
        self.map.removeAnnotations(self.map.annotations)
        let pinLocation = CLLocationCoordinate2DMake(latitude, longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "My Location"
        self.map.addAnnotation(objectAnnotation)
        
    }
}
