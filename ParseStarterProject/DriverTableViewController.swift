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
        cell.textLabel?.text = usernames[indexPath.row]
                                + " "
                                + String(locations[indexPath.row].latitude)
                                + ", "
                                + String(locations[indexPath.row].longitude)
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
                        if let username = object["username"] as? String {
                            self.usernames.append(username)
                        }
                        if let point = object["location"] as? PFGeoPoint {
                            self.locations.append(CLLocationCoordinate2DMake(point.latitude, point.longitude))
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
        }
    }

}
