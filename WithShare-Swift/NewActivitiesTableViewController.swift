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
    var loggedIn:Bool = false
    var activityTypeTitle = "All Activities"
    
    override func viewDidLoad() {
        //Check if logged in
        let prefs = NSUserDefaults.standardUserDefaults()
        loggedIn = prefs.boolForKey("UserLogIn")
        
        if !loggedIn {
            performSegueWithIdentifier("needLogInSegue", sender: self)
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
        else if segue.identifier == "createActivitySegue" {
            let createActivityViewController = segue.destinationViewController as! CreateActivityViewController
            if activityTypeTitle != "All Activities" {
                createActivityViewController.activityTypeShow = activityTypeTitle
                print("activity Type before segue: " + activityTypeTitle)
            }
            else {
                createActivityViewController.activityTypeShow = "Please choose"
            }
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //MARK: unwind methods
    @IBAction func selectActivityType(segue:UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? ActivityTypePopoverMenuViewController{
            activityTypeTitle = sourceViewController.activityType!
            print(sourceViewController.activityType)
            self.title = activityTypeTitle
        }
    }
    
    @IBAction func postNewActivity(segue:UIStoryboardSegue) {
//        if let sourceViewController = segue.sourceViewController as? ActivityTypePopoverMenuViewController{
//            let activityTypeTitle = sourceViewController.activityType
//            print(sourceViewController.activityType)
//            self.title = activityTypeTitle
//        }
    }


}

