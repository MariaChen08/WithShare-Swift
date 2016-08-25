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
    var activityTypeTitle = "All Posts"
    
    override func viewDidLoad() {
        
        //Check if logged in
        let prefs = NSUserDefaults.standardUserDefaults()
        loggedIn = prefs.boolForKey("UserLogIn")
        print(loggedIn)
        
        if (!loggedIn) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("needLogInSegue", sender: self)
            })
            
            //            self.navigationItem.hidesBackButton = true
        }
        else {
            // Retrieve cached user info
            let defaults = NSUserDefaults.standardUserDefaults()
            username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
            password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
            
            user = User(username: username!, password: password!)
            
            self.loadPostData()
            
            self.refreshControl?.addTarget(self, action: #selector(NewActivitiesTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // if there are no posts something bad happened and we should try again
        if (loggedIn && posts.count == 0) {
            self.loadPostData()
        }
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
            if activityTypeTitle != "All Posts" {
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
            self.loadPostData()
        }
        
    }
    
    @IBAction func createActivityUnwindToList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? CreateActivityViewController {
            print("from new activity view")
            self.loadPostData()
        }
    }
    
    @IBAction func joinActivityUnwindToList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? DetailViewController {
            print("from activity detail view")
        }

    }
    
    //MARK: Manage Data Source
    func loadPostData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getActivity(user!, onSuccess: {(posts) in
            self.posts =  posts
            // Filter posts
            let countPosts = posts.count
            if (self.activityTypeTitle != "All Posts") {
                var flag = 0
                for index in 0...countPosts-1 {
                    if (posts[index].activityTitle != self.activityTypeTitle) {
                        self.posts.removeAtIndex(index-flag)
                        flag += 1
                    }
                }
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
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
        })
    }
    
//    func filterActivityType(type: String) {
//        var filter_posts = [Post]()
//        filter_posts = self.posts
//        
//    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        self.loadPostData()
        refreshControl.endRefreshing()
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
        cell.ActivityTitleLabel.text = post.activityTitle!
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

