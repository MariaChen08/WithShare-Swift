//
//  CreateActivityViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 6/29/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class CreateActivityViewController: UIViewController, UIPopoverPresentationControllerDelegate{
    //MARK: Properties
    @IBOutlet weak var activityTypeButton: UIButton!
    var activityTypeShow:String? = "More"
    
    override func viewDidLoad() {
        activityTypeButton.setTitle(activityTypeShow, forState: .Normal)
    }
    
    //MARK: Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Popover Select Activity Type Menu
        if segue.identifier == "popoverSelectActivitySegue" {
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
        if let sourceViewController = segue.sourceViewController as? SelectActivityTypeMenu{
            let activityTypeShow = sourceViewController.activityType
            print(sourceViewController.activityType)
            activityTypeButton.setTitle(activityTypeShow, forState: .Normal)        }
    }



}
