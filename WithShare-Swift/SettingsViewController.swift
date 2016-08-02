//
//  SettingsViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/11/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate{
    
    //MARK: Properties
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var gradeTextField: UITextField!
    
    @IBOutlet weak var departmentTextField: UITextField!
    
    @IBOutlet weak var hobbyTextField: UITextField!
    
    @IBOutlet weak var shareProfileSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var SaveButton: UIButton!
    
    @IBOutlet weak var LogOutButton: UIButton!
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var fullName: String?
    var gender: String?
    var grade: String?
    var department: String?
    var hobby: String?
    var shareProfile = true
    
    var profileDict = [Constants.ServerModelField_User.username: "", Constants.ServerModelField_User.fullname: "", Constants.ServerModelField_User.grade: "", Constants.ServerModelField_User.department: "", Constants.ServerModelField_User.hobby : "", Constants.ServerModelField_User.gender: "", Constants.ServerModelField_User.shareProfile: true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve cached string-type user profile
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        fullName = defaults.stringForKey(Constants.NSUserDefaultsKey.fullName)
        gender = defaults.stringForKey(Constants.NSUserDefaultsKey.gender)
        grade = defaults.stringForKey(Constants.NSUserDefaultsKey.grade)
        department = defaults.stringForKey(Constants.NSUserDefaultsKey.department)
        hobby = defaults.stringForKey(Constants.NSUserDefaultsKey.hobby)
        shareProfile = defaults.boolForKey(Constants.NSUserDefaultsKey.shareProfile)
        
        // MARK: For debug purpose
        user = User(username: username!, password: password!, phoneNumber: phoneNumber!)
        
        if fullName != nil {
            fullNameTextField.text = fullName
        }
        if grade != nil {
            gradeTextField.text = grade
        }
        if department != nil {
            departmentTextField.text = department
        }
        if hobby != nil {
            hobbyTextField.text = hobby
        }
        
        if gender == Constants.Gender.female {
            genderSegmentedControl.selectedSegmentIndex = 0
        }
        else {
            genderSegmentedControl.selectedSegmentIndex = 1
        }
        
        if shareProfile {
            shareProfileSegmentedControl.selectedSegmentIndex = 0
        }
        else {
            shareProfileSegmentedControl.selectedSegmentIndex = 1
        }
        
        //Handle the text field’s user input through delegate callbacks.
        fullNameTextField.delegate = self
        gradeTextField.delegate = self
        departmentTextField.delegate = self
        hobbyTextField.delegate = self
        
        fullNameTextField.tag = 0
        gradeTextField.tag = 1
        departmentTextField.tag = 2
        hobbyTextField.tag = 3
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch (textField.tag) {
        case 0:
            fullName = textField.text
            if fullName != nil {
                fullName = fullName!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 1:
            grade = textField.text
            if grade != nil {
                grade = grade!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 2:
            department = textField.text
            if department != nil {
                department = department!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 3:
            hobby = textField.text
            if hobby != nil {
                hobby = hobby!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        default:
            print("did not edit saved profile")
        }
    }
    
    //MARK: Actions
    @IBAction func genderIndexChanged(sender: AnyObject) {
        switch genderSegmentedControl.selectedSegmentIndex
        {
        case 0:
            gender = Constants.Gender.female;
        case 1:
            gender = Constants.Gender.male;
        default:
            break;
        }
    }
    
    @IBAction func shareProfileIndexChanged(sender: AnyObject) {
        switch shareProfileSegmentedControl.selectedSegmentIndex
        {
        case 0:
            shareProfile = true;
        case 1:
            shareProfile = false;
        default:
            break;
        }

    }
    
    @IBAction func logOut(sender: AnyObject) {
        //cache current user status: Logged Out
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: Constants.NSUserDefaultsKey.logInStatus)
    }
    
    @IBAction func saveChanges(sender: AnyObject) {
        profileDict[Constants.ServerModelField_User.username] = user?.username
        
        // cache string-type user profile
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if fullName != nil {
            fullNameTextField.text = fullName
            defaults.setObject(fullName, forKey: Constants.NSUserDefaultsKey.fullName)
            profileDict[Constants.ServerModelField_User.fullname] = fullName
        }
        else {
            fullNameTextField.text = "Edit your full name.."
            profileDict[Constants.ServerModelField_User.fullname] = Constants.blankSign
        }
        if grade != nil {
            gradeTextField.text = grade
            defaults.setObject(grade, forKey: Constants.NSUserDefaultsKey.grade)
            profileDict[Constants.ServerModelField_User.grade] = grade
        }
        else {
            gradeTextField.text = "e.g. freshman, senior, etc."
            profileDict[Constants.ServerModelField_User.grade] = Constants.blankSign
        }
        if department != nil {
            departmentTextField.text = department
            defaults.setObject(department, forKey: Constants.NSUserDefaultsKey.department)
            profileDict[Constants.ServerModelField_User.department] = department
        }
        else {
            departmentTextField.text = "department"
            profileDict[Constants.ServerModelField_User.department] = Constants.blankSign
        }
        if hobby != nil {
            hobbyTextField.text = hobby
            defaults.setObject(hobby, forKey: Constants.NSUserDefaultsKey.hobby)
            profileDict[Constants.ServerModelField_User.hobby] = hobby
        }
        else {
            hobbyTextField.text = "e.g. basketball, music, etc."
            profileDict[Constants.ServerModelField_User.hobby] = Constants.blankSign
        }
        defaults.setObject(gender, forKey: Constants.NSUserDefaultsKey.gender)
        profileDict[Constants.ServerModelField_User.gender] = gender
        defaults.setBool(shareProfile, forKey: Constants.NSUserDefaultsKey.shareProfile)
        profileDict[Constants.ServerModelField_User.shareProfile] = shareProfile
        
        print(profileDict)
        
        // Upload to server
        ApiManager.sharedInstance.editProfile(user!, profileData: profileDict, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("update profile success!")
                let alert = UIAlertController(title: "Successfully updated profile!", message:
                    "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("create profile error!")
                    let alert = UIAlertController(title: "Unable to update profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
    

}
