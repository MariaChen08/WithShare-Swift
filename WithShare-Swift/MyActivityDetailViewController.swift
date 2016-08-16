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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let post = post {
            activityTitleLabel.text = "Activity Title: " + post.activityTitle!
            meetPlaceLabel.text = "meet@ " + post.meetPlace!
            detailLabel.text = post.detail!
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
        user = User(username: username!, password: password!, phoneNumber: phoneNumber!)
        
        user?.id = post?.userId
        
        self.loadMyJoinData()
        
//        self.tableView.registerClass(JoinedUserCustomCell.self, forCellReuseIdentifier: "JoinedUserCustomCell")

        
    }
    
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
            cell.joinTimeLabel.text =  "Joined at: " + dateFormatter.stringFromDate(join.createdAt) + " Today"
        }
        else {
            cell.joinTimeLabel.text =  "Joined at: " + dateFormatter.stringFromDate(join.createdAt) + " Yesterday"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: load joiners
    func loadMyJoinData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getJoinById(user!, post: post!, onSuccess: {(joins) in
            for join in joins {
                self.joins.append(join)
                print(join.id)
            }
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
    }

}
