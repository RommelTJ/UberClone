//
//  DriverTableViewController.swift
//  UberClone
//
//  Created by Rommel Rico on 2/20/16.
//  Copyright © 2016 Rommel. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {

    //Properties
    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var distances: [CLLocationDistance] = [CLLocationDistance]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let distance = Double(distances[indexPath.row])
        let roundedDistance = Double(round(distance * 10) / 10)
        let distanceString = String(roundedDistance)
        cell.textLabel?.text = "\(usernames[indexPath.row]): \(distanceString)km away"
        return cell
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Set the map region to current location
        let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        latitude = locValue.latitude
        longitude = locValue.longitude
        
        //Query for Rider Requests and Update Table.
        let query = PFQuery(className:"RiderRequest")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: latitude, longitude: longitude))
        query.limit = 10
        query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                //Successfully retrieved objects.
                if let objects = objects {
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    for object in objects {
                        if object["driverResponse"] == nil || object["driverResponse"] as? String == "" {
                            if let username = object["username"] as? String {
                                self.usernames.append(username)
                            }
                            if let point = object["location"] as? PFGeoPoint {
                                let requestLocation = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                                self.locations.append(requestLocation)
                                let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                                let driverCLLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
                                let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                                self.distances.append(distance/1000) //distance is in meters. Divide by 1000 to get km.
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            } else {
                print("Error: \(error), \(error?.userInfo)")
            }
        })
        
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logoutDriverSegue" {
            navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: false)
            PFUser.logOut()
        } else if segue.identifier == "showViewRequestsSegue" {
            if let destination = segue.destinationViewController as? RequestViewController {
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                destination.requestUsername = usernames[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }

}
