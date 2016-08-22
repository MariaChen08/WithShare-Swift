//
//  MyJoinTableViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/15/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class MyJoinTableViewController: UITableViewController {
    //MARK: Properties
    var joins = [Join]()
    
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
        
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
        
        user = User(username: username!, password: password!)
        user?.phoneNumber = phoneNumber
        user?.id = currentUserId
        
        self.loadMyJoinData()
        
        self.refreshControl?.addTarget(self, action: #selector(MyJoinTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // if there are no posts something bad happened and we should try again
        if joins.count == 0 {
            self.loadMyJoinData()
        }
    }
    
    //MARK: Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMyJoinDetailSegue" {
            let joinDetailViewController = segue.destinationViewController as! MyJoinDetailViewController
            // Get the cell that generated this segue.
            if let selectedJoinCell = sender as? MyJoinTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedJoinCell)!
                let selectedJoin = joins[indexPath.row]
                joinDetailViewController.join = selectedJoin
            }
        }
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //MARK: Manage Data Source
    func loadMyJoinData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getJoinByUser(user!, onSuccess: {(joins) in
            self.joins = joins
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tableView.reloadData()
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("load joiners error!")
                    let alert = UIAlertController(title: "Unable to load joiners!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.loadMyJoinData()
        refreshControl.endRefreshing()
    }
    
    
    //MARK: present dynamic data in table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joins.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyJoinTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MyJoinTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let join = joins[indexPath.row]
        
        cell.activityTitleLabel.text = join.postName

        // Configure and format time label
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let cal = NSCalendar.currentCalendar()
        var components = cal.components([.Era, .Year, .Month, .Day], fromDate:NSDate())
        let today = cal.dateFromComponents(components)!
        
        components = cal.components([.Era, .Year, .Month, .Day], fromDate:join.createdAt)
        let otherDate = cal.dateFromComponents(components)!
        
        if (today.isEqualToDate(otherDate)) {
            cell.joinTimeLabel.text = "Joined at:" +  dateFormatter.stringFromDate(join.createdAt) + " Today"
        }
        else {
            cell.joinTimeLabel.text =  "Joined at:" + dateFormatter.stringFromDate(join.createdAt) + " Yesterday"
        }
        
        return cell
    }

}
