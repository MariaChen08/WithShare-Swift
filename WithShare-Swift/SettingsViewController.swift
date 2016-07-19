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
        
        if gender == "female" {
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
            gender = "female";
        case 1:
            gender = "male";
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
        defaults.setBool(false, forKey: "UserLogIn")
    }
    
    @IBAction func saveChanges(sender: AnyObject) {
        // cache string-type user profile
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if fullName != nil {
            fullNameTextField.text = fullName
            defaults.setObject(fullName, forKey: "FullName")
        }
        else {
            fullNameTextField.text = "Edit your full name.."
        }
        if grade != nil {
            gradeTextField.text = grade
            defaults.setObject(grade, forKey: "Grade")
        }
        else {
            gradeTextField.text = "e.g. freshman, senior, etc."
        }
        if department != nil {
            departmentTextField.text = department
            defaults.setObject(department, forKey: "Department")
        }
        else {
            departmentTextField.text = "department"
        }
        if hobby != nil {
            hobbyTextField.text = hobby
        }
        else {
            hobbyTextField.text = "e.g. basketball, music, etc."
            defaults.setObject(hobby, forKey: "Hobby")
        }
        defaults.setObject(gender, forKey: "Gender")
        defaults.setBool(shareProfile, forKey: "ShareProfile")
    }
    
    

}
