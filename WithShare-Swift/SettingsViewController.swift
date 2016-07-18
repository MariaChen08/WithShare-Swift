//
//  SettingsViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/11/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var gradeTextField: UITextField!
    
    @IBOutlet weak var departmentTextField: UITextField!
    
    @IBOutlet weak var hobbiesTextField: UITextField!
    
    @IBOutlet weak var showProfileSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var SaveButton: UIButton!
    
    @IBOutlet weak var LogOutButton: UIButton!
    
    var fullName: String?
    var gender: String?
    var grade: String?
    var department: String?
    var hobby: String?
    var shareProfile = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve cached string-type user profile
        let defaults = NSUserDefaults.standardUserDefaults()
        fullName = defaults.stringForKey("FullName")
        gender = defaults.stringForKey("Gender")
        grade = defaults.stringForKey("Grade")
        department = defaults.stringForKey("Department")
        hobby = defaults.stringForKey("Hobby")
        shareProfile = defaults.boolForKey("ShareProfile")
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: Actions
    @IBAction func logOut(sender: AnyObject) {
        //cache current user status: Logged Out
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: "UserLogIn")
    }
    
    
    

}
