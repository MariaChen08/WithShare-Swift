//
//  SelectActivityTypeMenu.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 6/30/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class SelectActivityTypeMenu: UITableViewController {
    //MARK: Properties
    
    let activityTypes = [Constants.activityTypes.eatOut, Constants.activityTypes.physicalActivity, Constants.activityTypes.groupStudy, Constants.activityTypes.socializing, Constants.activityTypes.more]
    
    let activityTypeCellIdentifier = "selectActivityTypeCell"
    
    var activityType: String? = Constants.activityTypes.eatOut
    
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let selectedCell = sender as? UITableViewCell {
            let indexPath = tableView.indexPathForCell(selectedCell)!
            activityType = activityTypes[indexPath.row]
            print("selected activity type to create:" + activityType!)
        }
    }
    
    
}

