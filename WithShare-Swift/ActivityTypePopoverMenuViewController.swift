//
//  ActivityTypePopoverMenuViewController.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/25/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class ActivityTypePopoverMenuViewController: UITableViewController {
    
    //MARK: Properties
    
    let activityTypes = ["All Activities", "Eat Out", "Physical Activities", "Group Study", "Socializing", "More"]
    
    let activityTypeCellIdentifier = "activityTypeCell"
    
    var activityType: String? = "All Activities"
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Present UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(activityTypes.count)
        return activityTypes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(activityTypeCellIdentifier, forIndexPath: indexPath) 
        cell.textLabel?.text = activityTypes[indexPath.row]
        return cell
    }
    
    
    // Select activity type and prepare segue unwind back to list of activities.
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
////        print("You selected cell number: \(indexPath.row)!")
//        let activityType = activityTypes[indexPath.row]
//        print("selected activity type:" + activityType)
//
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let selectedCell = sender as? UITableViewCell {
            let indexPath = tableView.indexPathForCell(selectedCell)!
            activityType = activityTypes[indexPath.row]
            print("selected activity type:" + activityType!)
        }
    }


}
