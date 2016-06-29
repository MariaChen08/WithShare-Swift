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
    var activityTypeTitle = "All Activities"
    
    //MARK: Popover Menu
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverMenuSegue" {
            let popoverViewController = segue.destinationViewController 
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //MARK: unwind methods
    @IBAction func selectActivityType(segue:UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? ActivityTypePopoverMenuViewController{
            let activityTypeTitle = sourceViewController.activityType
            print(sourceViewController.activityType)
            self.title = activityTypeTitle
        }
    }
        

}
