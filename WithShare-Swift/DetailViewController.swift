//
//  DetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var meetPlaceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var hobbyLabel: UILabel!
    @IBOutlet weak var numOfPostLabel: UILabel!
    
    @IBOutlet weak var sendMessageLabel: UILabel!
    
    @IBOutlet weak var joinButton: UIBarButtonItem!
    
    
    var post: Post?
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    let locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient?
    var placePicker : GMSPlacePicker?
    var currentCoordinates:CLLocationCoordinate2D?
    //default location to IST, PSU
    var center = CLLocationCoordinate2DMake(40.793958335519726, -77.867923433207636)
    
    var join:Join?
    
    override func viewDidLoad() {
        if let post = post {
            activityTitleLabel.text = "Activity Title: " + post.activityTitle!
            meetPlaceLabel.text = "meet@ " + post.meetPlace!
            detailLabel.text = post.detail!
        }
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
        user = User(username: username!, password: password!, phoneNumber: phoneNumber!)

        user?.id = post?.userId
        self.loadPostData()
        
        //Google Map
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //Google Place APIs
        placesClient = GMSPlacesClient.sharedClient()
    }

    //MARK: load detail data
    func loadPostData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(user!, onSuccess: {(user) in
            print("get profile success")
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("get profile success")
                if (user.fullName != nil) {
                    self.fullNameLabel.text = user.fullName
                }
                else {
                    self.fullNameLabel.text = ""
                }
                if (user.grade != nil) {
                    self.gradeLabel.text = user.grade
                }
                else {
                    self.gradeLabel.text = ""
                }
                if (user.department != nil) {
                    self.departmentLabel.text = user.department
                }
                else {
                    self.departmentLabel.text = ""
                }
                if (user.hobby != nil) {
                    self.hobbyLabel.text = user.hobby
                }
                else {
                    self.hobbyLabel.text = ""
                }
                self.numOfPostLabel.text = "created " + String(user.numOfPosts!) + " activities"
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("load profile error!")
                    let alert = UIAlertController(title: "Unable to load profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
    //MARK: Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Join activity
        if joinButton === sender {
            join = Join()
            if (currentCoordinates != nil) {
                join?.currentLatitude = currentCoordinates!.latitude
                join?.currentLongtitude = currentCoordinates!.longitude
            }
            else {
                join?.currentLatitude = 0
                join?.currentLongtitude = 0
            }
            join?.userId = currentUserId
            join?.postId = post?.id
            
            // Upload to server
            ApiManager.sharedInstance.createJoinActivity(user!, join: join!, onSuccess: {(user) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("create new activity success!")
                    print("joinid: ")
                    print(self.join!.id)
                    self.performSegueWithIdentifier("joinActivityExit", sender: self)
                }
                }, onError: {(error) in
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        print("join activity error!")
                        let alert = UIAlertController(title: "Unable to join activity!", message:
                            "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            })
        }
    }

}

// MARK: - CLLocationManagerDelegate
extension DetailViewController: CLLocationManagerDelegate {
    // called when the user grants or revokes location permissions
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // verify the user has granted you permission while the app is in use
        if status == .AuthorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
//            mapView.myLocationEnabled = true
//            mapView.settings.myLocationButton = true
        }
    }
    
    // executes when the location manager receives new location data.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
//            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            print("coordinate: \(location.coordinate)")
            currentCoordinates = location.coordinate
            locationManager.stopUpdatingLocation()
        }
        
    }
}

