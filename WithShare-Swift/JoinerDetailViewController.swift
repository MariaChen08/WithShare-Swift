//
//  JoinerDetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/16/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class JoinerDetailViewController: UIViewController {

    //MARK: Properties
    var join: Join?
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    override func viewDidLoad() {
        if let post = post {
            activityTitleLabel.text = "Activity Title: " + post.activityTitle!
            meetPlaceLabel.text = "meet@ " + post.meetPlace!
            detailLabel.text = post.detail!
        }
        
        //Handle the text field’s user input through delegate callbacks.
        messageTextField.delegate = self
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
        user = User(username: username!, password: password!, phoneNumber: phoneNumber!)
        
        user?.id = post?.userId
        self.loadPostData()
        

        
        
    }

}
