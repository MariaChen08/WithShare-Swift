//
//  NewActivitiesTableViewController.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/24/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class NewActivitiesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    //MARK: Properties
    var posts = [Post]()
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    
    var loggedIn:Bool = false
    var activityTypeTitle = "All Activities"
    
    override func viewDidLoad() {
        
        //Check if logged in
        let prefs = NSUserDefaults.standardUserDefaults()
        loggedIn = prefs.boolForKey("UserLogIn")
        
        if !loggedIn {
            performSegueWithIdentifier("needLogInSegue", sender: self)
            //            self.navigationItem.hidesBackButton = true
        }
        
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        
        user = User(username: username!, password: password!, phoneNumber: phoneNumber!)
        
        self.loadPostData()
       
    }
    
    //MARK: Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Popover Filter Menu
        if segue.identifier == "popoverMenuSegue" {
            let popoverViewController = segue.destinationViewController 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
            //create new activity
        else if segue.identifier == "createActivitySegue" {
            let createActivityViewController = segue.destinationViewController as! CreateActivityViewController
            if activityTypeTitle != "All Activities" {
                createActivityViewController.activityTypeShow = activityTypeTitle
                print("activity Type before segue: " + activityTypeTitle)
            }
            else {
                createActivityViewController.activityTypeShow = "Please choose"
            }
            
        }
        else if segue.identifier == "showActivityDetailSegue" {
            let activityDetailViewController = segue.destinationViewController as! DetailViewController
            // Get the cell that generated this segue.
            if let selectedActivityCell = sender as? PostTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedActivityCell)!
                let selectedActivity = posts[indexPath.row]
                activityDetailViewController.post = selectedActivity
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //MARK: unwind methods
    @IBAction func popoverMenuUnwindToActivityList(segue:UIStoryboardSegue) {
        //select activity type from popover menu
        if let sourceViewController = segue.sourceViewController as? ActivityTypePopoverMenuViewController{
            activityTypeTitle = sourceViewController.activityType!
            print(sourceViewController.activityType)
            self.title = activityTypeTitle
        }
        
    }
    
    @IBAction func createActivityUnwindToList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? CreateActivityViewController {
            print("from new activity view")
            //MARK: from debug purpose
            if let post = sourceViewController.post {
                // Add a new post.
                print("new activity created unwind to list")
                let newIndexPath = NSIndexPath(forRow: posts.count, inSection: 0)
                posts.append(post)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            else {
                print("cancel creating new activity")
                // usage log
            }
        }
    }
    
    @IBAction func joinActivityUnwindToList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? DetailViewController {
            print("from activity detail view")
        }

    }
    
    func loadPostData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getActivity(user!, onSuccess: {(posts) in
            for post in posts {
                self.posts.append(post)
                print(post.id)
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tableView.reloadData()
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("load activity error!")
                    let alert = UIAlertController(title: "Unable to load activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }

    

    
    //MARK: present dynamic data in table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PostTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let post = posts[indexPath.row]
        // Configure cells
        cell.ActivityTitleLabel.font = UIFont.boldSystemFontOfSize(16.0)
        cell.ActivityTitleLabel.text = "Title: " + post.activityTitle!
        cell.DetailLabel.text = post.detail
        cell.MeetLocationLabel.text = "meet@: " + post.meetPlace!

        // Configure and format time label
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let cal = NSCalendar.currentCalendar()
        var components = cal.components([.Era, .Year, .Month, .Day], fromDate:NSDate())
        let today = cal.dateFromComponents(components)!
        
        components = cal.components([.Era, .Year, .Month, .Day], fromDate:post.createdAt)
        let otherDate = cal.dateFromComponents(components)!
        
        if (today.isEqualToDate(otherDate)) {
            cell.TimeLabel.text =  dateFormatter.stringFromDate(post.createdAt) + " Today"
        }
        else {
            cell.TimeLabel.text =  dateFormatter.stringFromDate(post.createdAt) + " Yesterday"
        }

        return cell
    }

}

