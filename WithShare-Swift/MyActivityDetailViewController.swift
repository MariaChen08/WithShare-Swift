//
//  MyActivityDetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class MyActivityDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var meetPlaceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var closePostButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var joins = [Join]()
//    var joiners = [User]()
    
    var post: Post?
    var user: User?
//    var joiner: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    //table pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MyActivityDetailViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityTitleLabel.font = UIFont.boldSystemFontOfSize(17.0)
        
        if let post = post {
            activityTitleLabel.text = post.activityTitle!
            meetPlaceLabel.text = "meet@ " + post.meetPlace!
            if (post.detail?.isEmpty == false) {
                detailLabel.text = "detail: " + post.detail!
            }
            else {
                detailLabel.text = post.detail!
            }

            if (post.status == Constants.PostStatus.closed) {
                closePostButton.enabled = false
                closePostButton.setTitle("closed", forState: .Normal)
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
        user = User(username: username!, password: password!)
        user?.phoneNumber = phoneNumber
        
//        user?.id = post?.userId
        user?.id = currentUserId
        
        self.loadMyJoinData()
        
    }
    
    //Pull to refresh
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        self.loadMyJoinData()
        refreshControl.endRefreshing()
    }

    
    // MARK: Joiner Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of joins:")
        print(joins.count)
        return joins.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "JoinedUserCustomCell"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! JoinedUserCustomCell
        
        // Fetches the appropriate join for the data source layout.
        let join = joins[indexPath.row]
        
        if (join.fullName != nil && join.fullName != Constants.blankSign) {
            cell.userNameLabel.text = join.fullName
        }
        else {
            cell.userNameLabel.text = join.username
        }
        
        if (join.status == Constants.JoinStatus.interested) {
            cell.userNameLabel.text = cell.userNameLabel.text! + "(interested)"
        }
        
        // Configure and format time label
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let cal = NSCalendar.currentCalendar()
        var components = cal.components([.Era, .Year, .Month, .Day], fromDate:NSDate())
        let today = cal.dateFromComponents(components)!
        
        components = cal.components([.Era, .Year, .Month, .Day], fromDate:join.createdAt)
        let otherDate = cal.dateFromComponents(components)!
        
        print(join.createdAt)
        print("Joined at: " + dateFormatter.stringFromDate(join.createdAt) + " Yesterday")
        
        cell.joinTimeLabel.text = ""
        
        if (today.isEqualToDate(otherDate)) {
            cell.joinTimeLabel.text =  dateFormatter.stringFromDate(join.createdAt) + " Today"
        }
        else {
            cell.joinTimeLabel.text =  dateFormatter.stringFromDate(join.createdAt) + " Yesterday"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: load joiners
    func loadMyJoinData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getJoinById(user!, post: post!, onSuccess: {(joins) in
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
    
    //MARK: Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showJoinerDetailSegue" {
            let joinerDetailViewController = segue.destinationViewController as! JoinerDetailViewController
            // Get the cell that generated this segue.
            if let selectedActivityCell = sender as? JoinedUserCustomCell {
                let indexPath = tableView.indexPathForCell(selectedActivityCell)!
                let selectedActivity = joins[indexPath.row]
                joinerDetailViewController.join = selectedActivity
            }
        }
        else if segue.identifier == "editPostSegue" {
            let postViewController = segue.destinationViewController as! CreateActivityViewController
            postViewController.post = self.post
        }
    }
    
    //MARK: Actions
    @IBAction func closeActivity(sender: AnyObject) {
        self.post?.status = Constants.PostStatus.closed
//        print(self.post?.status)
        // Upload to server
        ApiManager.sharedInstance.editActivity(self.user!, post: self.post!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("close activity success!")
                print("postid: ")
                print(self.post?.id)
                self.closePostButton.enabled = false
                self.closePostButton.setTitle("closed", forState: .Normal)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("close activity error!")
                    let alert = UIAlertController(title: "Unable to close activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
    @IBAction func editPost(sender: AnyObject) {
        self.performSegueWithIdentifier("editPostSegue", sender: self)
    }
    
}
