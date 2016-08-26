//
//  MyActivitiesTableViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class MyActivitiesTableViewController: UITableViewController {
    
    //MARK: Properties
    var posts = [Post]()
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
//    var loggedIn:Bool = false
//    var activityTypeTitle = "All Activities"
    
    override func viewDidLoad() {
        
//        //Check if logged in
//        let prefs = NSUserDefaults.standardUserDefaults()
//        loggedIn = prefs.boolForKey("UserLogIn")
//        
//        if !loggedIn {
//            performSegueWithIdentifier("needLogInSegue", sender: self)
//            //            self.navigationItem.hidesBackButton = true
//        }
        
        
        self.loadMyPostData()
        
        self.refreshControl?.addTarget(self, action: #selector(MyActivitiesTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    //MARK: Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMyPostDetailSegue" {
            let activityDetailViewController = segue.destinationViewController as! MyActivityDetailViewController
            // Get the cell that generated this segue.
            if let selectedActivityCell = sender as? MyPostTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedActivityCell)!
                let selectedActivity = posts[indexPath.row]
                activityDetailViewController.post = selectedActivity
            }
        }
    }
    
    @IBAction func backMyActivityUnwindToList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? MyActivityDetailViewController {
            print("from my post detail view")
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // Manage Data Source
    func loadMyPostData() {
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        self.username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        self.password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        self.phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        self.currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
        
        self.user = User(username: username!, password: password!)
        self.user?.phoneNumber = phoneNumber
        self.user?.id = currentUserId

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getMyActivity(self.user!, onSuccess: {(posts) in
            self.posts = posts
            NSOperationQueue.mainQueue().addOperationWithBlock {
                // Filter posts
                let countPosts = posts.count
                var flag = 0
                for index in 0...countPosts-1 {
                    if (posts[index].status == Constants.PostStatus.modified) {
                        self.posts.removeAtIndex(index-flag)
                        flag += 1
                    }
                }
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
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.loadMyPostData()
        refreshControl.endRefreshing()
    }
    
    //MARK: unwind segues
    @IBAction func editPostUnwindToList(segue:UIStoryboardSegue) {
        self.loadMyPostData()
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
        let cellIdentifier = "MyPostTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MyPostTableViewCell
        
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
