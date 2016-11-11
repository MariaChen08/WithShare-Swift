//
//  CreateProfileViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 6/26/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
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
    var gender = Constants.Gender.female
    
    var profileDict = [Constants.ServerModelField_User.username: "", Constants.ServerModelField_User.fullname: "", Constants.ServerModelField_User.grade: "", Constants.ServerModelField_User.department: "", Constants.ServerModelField_User.hobby : "", Constants.ServerModelField_User.gender: "", Constants.ServerModelField_User.shareProfile: true]
    
    let yearInSchoolPicker: UIPickerView = UIPickerView()
//    let cancelButton = UIButton(type: UIButtonType.system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup buttons
        skipButton.layer.cornerRadius = 5
        skipButton.layer.masksToBounds = true
        
        saveButton.layer.cornerRadius = 5
        saveButton.layer.masksToBounds = true
        
        
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
        
        // setup delegation of year in school uipicker stuff
        yearInSchoolPicker.delegate = self
        yearInSchoolPicker.dataSource = self
        
        // set accessory views
        self.gradeTextField.inputView = self.yearInSchoolPicker
//
//        self.seatsAvailableTextField.inputView = self.seatsAvailablePicker
//        self.seatsAvailableTextField.inputAccessoryView = self.cancelButton
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switch (textField.tag) {
        case 3:
            animateViewMoving(true, moveValue: 200)
        case 4:
            animateViewMoving(true, moveValue: 200)
        default:
            print("did not edit saved profile")
        }
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
            animateViewMoving(false, moveValue: 200)
        case 4:
            hobby = textField.text
            if hobby != nil {
                hobby = hobby!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
            animateViewMoving(false, moveValue: 200)
        default:
            print("did not create profile")
        }
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    // MARK: - UIPickerView delegation
    
    // All of these delegates for all of the different picker views for this...I don't think you can separate them out terribly easily
    // so I just figure out which control is currently the first responder...a bit hacky
    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearInSchoolEnum.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return yearInSchoolEnum.getItem(row).description
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.gradeTextField.text = yearInSchoolEnum.getItem(row).description
        self.gradeTextField.resignFirstResponder()
    }


    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "createProfilePhotoSegue") {
            if let uploadPhotoViewController = segue.destinationViewController as? UploadPhotoViewController {
                uploadPhotoViewController.user = self.user!
            }
        }
    }
    
    //MARK: Actions
    @IBAction func genderIndexChangded(sender: AnyObject) {
        switch genderSegmentedControl.selectedSegmentIndex
        {
            case 0:
                gender = Constants.Gender.female;
            case 1:
                gender = Constants.Gender.male;
            default:
                gender = Constants.Gender.female;
        }
    }
    
    @IBAction func skipProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("createProfilePhotoSegue", sender: self)
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        
        profileDict[Constants.ServerModelField_User.username] = user?.username
        
        // read all text input
        firstName = firstNameTextField.text
        firstName = firstName?.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        lastName = lastNameTextField.text
        lastName = lastName?.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        grade = gradeTextField.text
        grade = grade?.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
        department = departmentTextField.text
        department = department!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        hobby = hobbyTextField.text
        hobby = hobby?.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
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
        if (fullName != nil && fullName != "") {
            user?.fullName = fullName
            defaults.setObject(fullName, forKey: Constants.NSUserDefaultsKey.fullName)
            profileDict[Constants.ServerModelField_User.fullname] = fullName
        }
        else {
            profileDict[Constants.ServerModelField_User.fullname] = Constants.blankSign
        }
        user?.gender = gender
        defaults.setObject(gender, forKey: Constants.NSUserDefaultsKey.gender)
        profileDict[Constants.ServerModelField_User.gender] = gender
        if (grade != nil && grade != "") {
            user?.grade = grade
            defaults.setObject(grade, forKey: Constants.NSUserDefaultsKey.grade)
            profileDict[Constants.ServerModelField_User.grade] = grade
        }
        else {
            profileDict[Constants.ServerModelField_User.grade] = Constants.blankSign

        }
        if (department != nil && department != "") {
            user?.department = department
            defaults.setObject(department, forKey: Constants.NSUserDefaultsKey.department)
            profileDict[Constants.ServerModelField_User.department] = department
        }
        else {
            profileDict[Constants.ServerModelField_User.department] = Constants.blankSign
        }
        
        if (hobby != nil && hobby != "") {
            user?.hobby = hobby
            defaults.setObject(hobby, forKey: Constants.NSUserDefaultsKey.hobby)
            profileDict[Constants.ServerModelField_User.hobby] = hobby
        }
        else {
            profileDict[Constants.ServerModelField_User.hobby] = Constants.blankSign
        }
        
        print("create profile: ")
        print(profileDict)
        
        // Upload to server
        ApiManager.sharedInstance.editProfile(user!, profileData: profileDict, onSuccess: {(user) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("create profile success!")
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.performSegueWithIdentifier("createProfilePhotoSegue", sender: self)
                }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("create profile error!")
                    let alert = UIAlertController(title: "Unable to create profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
}
