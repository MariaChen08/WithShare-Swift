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
                self.activityTitleLabel.text = "Activity Title: " + post.activityTitle!
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


}
