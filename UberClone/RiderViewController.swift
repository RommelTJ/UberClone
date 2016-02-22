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
    var driverOnTheWay: Bool = false
    
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
        //Get current location.
        let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        latitude = locValue.latitude
        longitude = locValue.longitude
        
        //Query to check where the driver is in relation to the Rider.
        let query = PFQuery(className:"RiderRequest")
        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                //Successfully retrieved objects.
                if let objects = objects {
                    for object in objects {
                        //Let the user know the driver is on the way.
                        if let driverUsername = object["driverResponse"] {
                            //Get the location of the driver.
                            let query = PFQuery(className:"DriverLocation")
                            query.whereKey("username", equalTo: driverUsername)
                            query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                                if error != nil {
                                    print("Error: \(error)")
                                } else {
                                    if let objects = objects {
                                        for object in objects {
                                            if let driverPoint = object["driverLocation"] as? PFGeoPoint {
                                                let driverCLLocation = CLLocation(latitude: driverPoint.latitude, longitude: driverPoint.longitude)
                                                let riderCLLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
                                                let distanceMeters = riderCLLocation.distanceFromLocation(driverCLLocation)
                                                let distanceKM = distanceMeters/1000
                                                let roundedDistance = Double(round(distanceKM * 10) / 10)
                                                self.driverOnTheWay = true
                                                self.callAnUberButton.setTitle("Driver \(driverUsername) is \(roundedDistance)km away!", forState: .Normal)
                                                
                                                //Update the map to show the driver on the way.
                                                let center = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                                                let latDelta = abs(driverPoint.latitude - self.latitude) * 2 + 0.01
                                                let lonDelta = abs(driverPoint.longitude - self.longitude) * 2 + 0.01
                                                let span = MKCoordinateSpanMake(latDelta, lonDelta)
                                                let region = MKCoordinateRegion(center: center, span: span)
                                                self.map.setRegion(region, animated: true)
                                                
                                                //Add a pin to user location.
                                                self.map.removeAnnotations(self.map.annotations)
                                                let pinLocation = CLLocationCoordinate2DMake(self.latitude, self.longitude)
                                                let objectAnnotation = MKPointAnnotation()
                                                objectAnnotation.coordinate = pinLocation
                                                objectAnnotation.title = "My Location"
                                                self.map.addAnnotation(objectAnnotation)
                                                
                                                //Add a pin to show driver location.
                                                let driverPinLocation = CLLocationCoordinate2DMake(driverPoint.latitude, driverPoint.longitude)
                                                let driverObjectAnnotation = MKPointAnnotation()
                                                driverObjectAnnotation.coordinate = driverPinLocation
                                                driverObjectAnnotation.title = "Driver Location"
                                                self.map.addAnnotation(driverObjectAnnotation)
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            } else {
                print("Error: \(error), \(error?.userInfo)")
            }
        })
        
        if driverOnTheWay == false {
            //Set the map region to current location
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
}
