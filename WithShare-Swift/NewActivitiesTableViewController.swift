//
//  NewActivitiesTableViewController.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/24/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit
import GoogleMaps

class NewActivitiesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var posts = [Post]()
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    
    var loggedIn:Bool = false
    var firstLaunch:Bool = false
    var activityTypeTitle = "All Posts"
    
    let locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient?
    var placePicker : GMSPlacePicker?
    var currentCoordinates:CLLocationCoordinate2D?
    //default location to IST, PSU
    var center = CLLocationCoordinate2DMake(40.793958335519726, -77.867923433207636)
    
    override func viewDidLoad() {
        
        //Check if first time lauch app
        let prefs = UserDefaults.standard
        firstLaunch = prefs.bool(forKey: Constants.NSUserDefaultsKey.firstLaunch)
        print(firstLaunch)

        
        //Check if logged in
//        let prefs = NSUserDefaults.standardUserDefaults()
        loggedIn = prefs.bool(forKey: Constants.NSUserDefaultsKey.logInStatus)
        print(loggedIn)
        
        if (!firstLaunch) {
            
             prefs.set(true, forKey: Constants.NSUserDefaultsKey.firstLaunch)
            DispatchQueue.main.async(execute: { () -> Void in
                self.performSegue(withIdentifier: "firstLaunchAppSegue", sender: self)
            })
            
            //            self.navigationItem.hidesBackButton = true
        }
        
        if (!loggedIn) {
            DispatchQueue.main.async(execute: { () -> Void in
                self.performSegue(withIdentifier: "needLogInSegue", sender: self)
            })
            
            //            self.navigationItem.hidesBackButton = true
        }
        else {
            // Retrieve cached user info
            let defaults = UserDefaults.standard
            username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
            password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
            print(username as Any)
            print(password as Any)
//            username = "testyk@psu.edu"
//            password = "a"
            phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
            
            user = User(username: username!, password: password!)
            
            self.loadPostData()
            
            self.refreshControl?.addTarget(self, action: #selector(NewActivitiesTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // if there are no posts something bad happened and we should try again
        if (loggedIn && posts.count == 0) {
            self.loadPostData()
        }
    }
    
    
    //MARK: Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Popover Filter Menu
        if segue.identifier == "popoverMenuSegue" {
            let popoverViewController = segue.destination 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
            //create new activity
        else if segue.identifier == "createActivitySegue" {
            let createActivityViewController = segue.destination as! CreateActivityViewController
            if activityTypeTitle != "All Posts" {
                createActivityViewController.activityTitle = activityTypeTitle
                print("activity Type before segue: " + activityTypeTitle)
            }
            else {
                createActivityViewController.activityTitle = "Please choose"
            }
            
        }
        else if segue.identifier == "showActivityDetailSegue" {
            let activityDetailViewController = segue.destination as! DetailViewController
            // Get the cell that generated this segue.
            if let selectedActivityCell = sender as? PostTableViewCell {
                let indexPath = tableView.indexPath(for: selectedActivityCell)!
                let selectedActivity = posts[indexPath.row]
                activityDetailViewController.post = selectedActivity
                activityDetailViewController.indexPostion = indexPath.row
                activityDetailViewController.currentCoordinates = currentCoordinates
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //MARK: unwind methods
    @IBAction func popoverMenuUnwindToActivityList(_ segue:UIStoryboardSegue) {
        //select activity type from popover menu
        if let sourceViewController = segue.source as? ActivityTypePopoverMenuViewController{
            activityTypeTitle = sourceViewController.activityType!
            print(sourceViewController.activityType as Any)
            self.title = activityTypeTitle
            self.loadPostData()
        }
        
    }
    
    @IBAction func createActivityUnwindToList(_ sender: UIStoryboardSegue) {
        if sender.source is CreateActivityViewController {
            print("from new activity view")
            self.loadPostData()
        }
    }
    
    @IBAction func joinActivityUnwindToList(_ sender: UIStoryboardSegue) {
        if sender.source is DetailViewController {
            print("from activity detail view")
        }

    }
    
    //MARK: Manage Data Source
    func loadPostData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getActivity(user!, onSuccess: {(posts) in
            self.posts =  posts
            // Filter posts
            let countPosts = posts.count
            if (self.activityTypeTitle != "All Posts") {
                var flag = 0
                if (countPosts > 0) {
                    for index in 0...countPosts-1 {
                        if (posts[index].activityTitle != self.activityTypeTitle) {
                            self.posts.remove(at: index-flag)
                            flag += 1
                        }
                    }
                }
            }
            
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("load activity error!")
                    let alert = UIAlertController(title: "Unable to load activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
        })
    }

    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.loadPostData()
        refreshControl.endRefreshing()
    }
    
    //MARK: present dynamic data in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PostTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PostTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let post = posts[indexPath.row]
        // Configure cells
        cell.ActivityTitleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        cell.ActivityTitleLabel.text = post.activityTitle!
        cell.DetailLabel.text = post.detail
        cell.MeetLocationLabel.text = "meet@: " + post.meetPlace!

        // Configure and format time label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let now = Date()
        print("UTC time post create:")
        print(post.createdAt)
        print("local time post create:")
        print(dateFormatter.string(from: post.createdAt))
        
        let cal = Calendar.current
        var components = (cal as NSCalendar).components([.era, .year, .month, .day], from: now)
        let today = cal.date(from: components)!
        
        components = (cal as NSCalendar).components([.era, .year, .month, .day], from:post.createdAt)
        let otherDate = cal.date(from: components)!
        
        if (today == otherDate) {
            cell.TimeLabel.text =  dateFormatter.string(from: post.createdAt) + " Today"
        }
        else {
            cell.TimeLabel.text =  dateFormatter.string(from: post.createdAt) + " Yesterday"
        }

        return cell
    }

}


// MARK: - CLLocationManagerDelegate
extension NewActivitiesTableViewController: CLLocationManagerDelegate {
    // called when the user grants or revokes location permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // verify the user has granted you permission while the app is in use
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            //            mapView.myLocationEnabled = true
            //            mapView.settings.myLocationButton = true
        }
    }
    
    // executes when the location manager receives new location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            //            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            print("coordinate: \(location.coordinate)")
            currentCoordinates = location.coordinate
            locationManager.stopUpdatingLocation()
        }
        
    }
}


