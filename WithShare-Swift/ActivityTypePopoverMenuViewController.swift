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
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(activityTypes.count)
        return activityTypes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(activityTypeCellIdentifier, forIndexPath: indexPath) 
        cell.textLabel?.text = activityTypes[indexPath.row]
        return cell
    }

}
