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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print(activityTypes.count)
        return activityTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: activityTypeCellIdentifier, for: indexPath)
        cell.textLabel?.text = activityTypes[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedCell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: selectedCell)!
            activityType = activityTypes[indexPath.row]
            print("selected activity type to create:" + activityType!)
        }
    }
    
    
}

