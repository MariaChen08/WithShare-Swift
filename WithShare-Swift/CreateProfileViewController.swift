//
//  CreateProfileViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 6/26/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController, UITextFieldDelegate{
    //MARK: Properties
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var hobbyTextField: UITextField!
    
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var user: User?
    
    var firstName: String?
    var lastName: String?
    var fullName: String?
    var grade: String?
    var department: String?
    var hobby: String?
    var gender = "female"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Handle the text field’s user input through delegate callbacks.
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        gradeTextField.delegate = self
        departmentTextField.delegate = self
        hobbyTextField.delegate = self
        
        firstNameTextField.tag = 0
        lastNameTextField.tag = 1
        gradeTextField.tag = 2
        departmentTextField.tag = 3
        hobbyTextField.tag = 4
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        print(user?.username)
        
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
            firstName = textField.text
            if firstName != nil {
                firstName = firstName!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 1:
            lastName = textField.text
            if lastName != nil {
                lastName = lastName!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 2:
            grade = textField.text
            if grade != nil {
                grade = grade!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 3:
            department = textField.text
            if department != nil {
                department = department!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 4:
            hobby = textField.text
            if hobby != nil {
                hobby = hobby!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        default:
            print("did not create profile")
        }
    }
    
    //MARK: Actions
    @IBAction func genderIndexChangded(sender: AnyObject) {
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
    
    @IBAction func saveProfile(sender: AnyObject) {
        // cache string-type user profile
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // construct fullname
        if (firstName != nil && lastName != nil) {
            fullName = firstName! + " " + lastName!
            fullName = fullName!.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        else if (firstName != nil) {
            fullName = firstName!
        }
        else if (lastName != nil) {
            fullName = lastName!
        }
        
        // create user profile
        if (fullName != nil) {
            user?.fullName = fullName
            defaults.setObject(fullName, forKey: "FullName")
        }
        user?.gender = gender
        defaults.setObject(gender, forKey: "Gender")
        if (grade != nil) {
            user?.grade = grade
            defaults.setObject(grade, forKey: "Grade")
        }
        if (department != nil) {
            user?.department = department
            defaults.setObject(department, forKey: "Department")
        }
        if (hobby != nil) {
            user?.hobby = hobby
            defaults.setObject(hobby, forKey: "Hobby")
        }
    }
}
