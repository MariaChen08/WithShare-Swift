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
    
    @IBOutlet weak var joinButton: UIBarButtonItem!
    
    var join: Join?
    var post: Post?
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    var message: String?
    
    
    override func viewDidLoad() {
        // Initial blank page
        fullNameLabel.text = ""
        gradeLabel.text = ""
        departmentLabel.text = ""
        numOfPostLabel.text = ""
        activityTitleLabel.text = ""
        meetPlaceLabel.text = ""
        detailLabel.text = ""
        
        activityTitleLabel.font = UIFont.boldSystemFontOfSize(18.0)

        
        if let join = join {
            if (join.status == Constants.JoinStatus.confirm) {
                self.joinButton.title = "";
                self.joinButton.enabled = false;
            }
            
            // Retrieve cached user info
            let defaults = NSUserDefaults.standardUserDefaults()
            username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
            password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
            currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
            
            user = User(username: username!, password: password!)
            user?.id = currentUserId
            user?.phoneNumber = phoneNumber
            
            post = Post()
            post!.id = join.postId
            
            self.loadPostData()
        }
        
        //Handle the text field’s user input through delegate callbacks.
        messageTextField.delegate = self
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: load detail data
    func loadPostData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getPostById(user!, postId: self.post!.id!, onSuccess: {(post) in
            print("get post profile success")
            NSOperationQueue.mainQueue().addOperationWithBlock {
                // load user profile
                if (post.fullName != nil && post.fullName != Constants.blankSign) {
                    self.fullNameLabel.text = post.fullName
                }
                else {
                    self.fullNameLabel.text = ""
                }
                if (post.postGrade != nil && post.postGrade != Constants.blankSign) {
                    self.gradeLabel.text = post.postGrade
                }
                else {
                    self.gradeLabel.text = ""
                }
                if (post.postDepartment != nil && post.postDepartment != Constants.blankSign) {
                    self.departmentLabel.text = post.postDepartment
                }
                else {
                    self.departmentLabel.text = ""
                }
                if (post.postHobby != nil && post.postHobby != Constants.blankSign) {
                    self.hobbyLabel.text = post.postHobby
                }
                else {
                    self.hobbyLabel.text = ""
                }
                self.numOfPostLabel.text = String(post.postNumOfPosts!) + " posts"
                
                // load post
                self.activityTitleLabel.text = post.activityTitle!
                self.meetPlaceLabel.text = "meet@ " + post.meetPlace!
                self.detailLabel.text = post.detail!
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

    @IBAction func confirmJoin(sender: AnyObject) {
        self.join?.status = Constants.JoinStatus.confirm
        print(self.join?.status)
        // Upload to server
        ApiManager.sharedInstance.confirmJoinActivity(self.user!, join: self.join!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("confirm new activity success!")
                print("joinid: ")
                print(self.join!.id)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("join activity error!")
                    let alert = UIAlertController(title: "Unable to join activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    

}
