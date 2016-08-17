//
//  MyJoinDetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/16/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class MyJoinDetailViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var gradeLabel: UILabel!
    
    @IBOutlet weak var departmentLabel: UILabel!
    
    @IBOutlet weak var hobbyLabel: UILabel!
    
    @IBOutlet weak var numOfPostLabel: UILabel!
    
    @IBOutlet weak var activityTitleLabel: UILabel!
    
    @IBOutlet weak var meetPlaceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var join: Join?
    var post: Post?
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    var message: String?
    
    
    override func viewDidLoad() {
        if let join = join {
            // Retrieve cached user info
            let defaults = NSUserDefaults.standardUserDefaults()
            username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
            password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
            
            user = User(username: username!, password: password!)
            user?.phoneNumber = phoneNumber
            
            user!.id = join.userId
            
//            self.loadPostData()
            self.loadProfileData()
        }
        
        //Handle the text field’s user input through delegate callbacks.
        messageTextField.delegate = self
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: load detail data
    func loadProfileData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(user!, onSuccess: {(user) in
            print("get profile success")
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("get profile success")
                if (user.fullName != nil && user.fullName != Constants.blankSign) {
                    self.fullNameLabel.text = user.fullName
                }
                else {
                    self.fullNameLabel.text = ""
                }
                if (user.grade != nil && user.grade != Constants.blankSign) {
                    self.gradeLabel.text = user.grade
                }
                else {
                    self.gradeLabel.text = ""
                }
                if (user.department != nil && user.department != Constants.blankSign) {
                    self.departmentLabel.text = user.department
                }
                else {
                    self.departmentLabel.text = ""
                }
                if (user.hobby != nil && user.hobby != Constants.blankSign) {
                    self.hobbyLabel.text = user.hobby
                }
                else {
                    self.hobbyLabel.text = ""
                }
                self.numOfPostLabel.text = String(user.numOfPosts!) + " posts"
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
