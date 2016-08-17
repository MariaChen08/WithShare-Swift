//
//  JoinerDetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/16/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class JoinerDetailViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var hobbyLabel: UILabel!
    @IBOutlet weak var numOfPostLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var join: Join?

    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var joiner: User?
    
    override func viewDidLoad() {
        if let join = join {
            // Retrieve cached user info
            let defaults = NSUserDefaults.standardUserDefaults()
            username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
            password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
            
            joiner = User(username: username!, password: password!)
            joiner?.phoneNumber = phoneNumber
            
            joiner!.id = join.userId
            self.loadJoinerProfile()

        }
        
        //Handle the text field’s user input through delegate callbacks.
        messageTextField.delegate = self
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: load joiner profile
    func loadJoinerProfile() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(joiner!, onSuccess: {(joiner) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("get joiner profile success")
                if (joiner.fullName != nil && joiner.fullName != Constants.blankSign) {
                    self.fullNameLabel.text = joiner.fullName
                }
                else {
                    self.fullNameLabel.text = ""
                }
                if (joiner.grade != nil && joiner.grade != Constants.blankSign) {
                    self.gradeLabel.text = joiner.grade
                }
                else {
                    self.gradeLabel.text = ""
                }
                if (joiner.department != nil && joiner.department != Constants.blankSign) {
                    self.departmentLabel.text = joiner.department
                }
                else {
                    self.departmentLabel.text = ""
                }
                if (joiner.hobby != nil && joiner.hobby != Constants.blankSign) {
                    self.hobbyLabel.text = joiner.hobby
                }
                else {
                    self.hobbyLabel.text = ""
                }
                self.numOfPostLabel.text = String(joiner.numOfPosts!) + " posts"
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("load profile error!")
                    let alert = UIAlertController(title: "Unable to load profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }

}
