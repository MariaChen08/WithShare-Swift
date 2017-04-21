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
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
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
    
    var profileDict = [Constants.ServerModelField_User.username: "", Constants.ServerModelField_User.fullname: "", Constants.ServerModelField_User.grade: "", Constants.ServerModelField_User.department: "", Constants.ServerModelField_User.hobby : "", Constants.ServerModelField_User.gender: "", Constants.ServerModelField_User.shareProfile: true] as [String : Any]
    
    let yearInSchoolPicker: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup buttons
        skipButton.layer.cornerRadius = 5
        skipButton.layer.masksToBounds = true
        
        saveButton.layer.cornerRadius = 5
        saveButton.layer.masksToBounds = true
        
        // set up multipline input
        descriptionTextView.text = Constants.shortDescriptionPlaceholder
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 5
        
        //Handle the text field’s user input through delegate callbacks.
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        gradeTextField.delegate = self
        departmentTextField.delegate = self
        descriptionTextView.delegate = self
        
        firstNameTextField.tag = 0
        lastNameTextField.tag = 1
        gradeTextField.tag = 2
        departmentTextField.tag = 3
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        print(user?.username as Any)
        
        // setup delegation of year in school uipicker stuff
        yearInSchoolPicker.delegate = self
        yearInSchoolPicker.dataSource = self
        
        // set accessory views
        self.gradeTextField.inputView = self.yearInSchoolPicker
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 3:
            animateViewMoving(true, moveValue: 200)
        default:
            print("did not edit saved profile")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 0:
            firstName = textField.text
            if firstName != nil {
                firstName = firstName!.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
            }
        case 1:
            lastName = textField.text
            if lastName != nil {
                lastName = lastName!.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
            }
        case 2:
            grade = textField.text
            if grade != nil {
                grade = grade!.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
            }
        case 3:
            department = textField.text
            if department != nil {
                department = department!.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
            }
            animateViewMoving(false, moveValue: 200)
        default:
            print("did not create profile")
        }
    }
    
    // MARK: UITextViewDelegate
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        //Hide the keyboard
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
       
        textView.text = ""
        animateViewMoving(true, moveValue: 200)
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.shortDescriptionPlaceholder
            textView.textColor = UIColor.lightGray
        }
        else {
            hobby = textView.text
        }
        animateViewMoving(false, moveValue: 200)
    }

    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    // MARK: - UIPickerView delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearInSchoolEnum.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return yearInSchoolEnum.getItem(row).description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.gradeTextField.text = yearInSchoolEnum.getItem(row).description
        self.gradeTextField.resignFirstResponder()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "createProfilePhotoSegue") {
            if let uploadPhotoViewController = segue.destination as? UploadPhotoViewController {
                uploadPhotoViewController.user = self.user!
            }
        }
    }
    
    //MARK: Actions
    @IBAction func genderIndexChangded(_ sender: AnyObject) {
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
    
    @IBAction func skipProfile(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "createProfilePhotoSegue", sender: self)
    }
    
    @IBAction func saveProfile(_ sender: AnyObject) {
        
        profileDict[Constants.ServerModelField_User.username] = user?.username
        
        // read all text input
        firstName = firstNameTextField.text
        firstName = firstName?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        lastName = lastNameTextField.text
        lastName = lastName?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        grade = gradeTextField.text
        grade = grade?.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
        department = departmentTextField.text
        department = department!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        hobby = descriptionTextView.text
        hobby = hobby?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        // cache string-type user profile
        let defaults = UserDefaults.standard
        
        // construct fullname
        if (firstName != nil && lastName != nil) {
            fullName = firstName! + " " + lastName!
            fullName = fullName!.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
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
            defaults.set(fullName, forKey: Constants.NSUserDefaultsKey.fullName)
            profileDict[Constants.ServerModelField_User.fullname] = fullName
        }
        else {
            profileDict[Constants.ServerModelField_User.fullname] = Constants.blankSign
        }
        user?.gender = gender
        defaults.set(gender, forKey: Constants.NSUserDefaultsKey.gender)
        profileDict[Constants.ServerModelField_User.gender] = gender
        if (grade != nil && grade != "") {
            user?.grade = grade
            defaults.set(grade, forKey: Constants.NSUserDefaultsKey.grade)
            profileDict[Constants.ServerModelField_User.grade] = grade
        }
        else {
            profileDict[Constants.ServerModelField_User.grade] = Constants.blankSign

        }
        if (department != nil && department != "") {
            user?.department = department
            defaults.set(department, forKey: Constants.NSUserDefaultsKey.department)
            profileDict[Constants.ServerModelField_User.department] = department
        }
        else {
            profileDict[Constants.ServerModelField_User.department] = Constants.blankSign
        }
        
        if (hobby != nil && hobby != "" && hobby != Constants.shortDescriptionPlaceholder) {
            user?.hobby = hobby
            defaults.set(hobby, forKey: Constants.NSUserDefaultsKey.hobby)
            profileDict[Constants.ServerModelField_User.hobby] = hobby
        }
        else {
            profileDict[Constants.ServerModelField_User.hobby] = Constants.blankSign
        }
        
        print("create profile: ")
        print(profileDict)
        
        // Upload to server
        ApiManager.sharedInstance.editProfile(user!, profileData: profileDict as Dictionary<String, AnyObject>, onSuccess: {(user) in
                OperationQueue.main.addOperation {
                    print("create profile success!")
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.performSegue(withIdentifier: "createProfilePhotoSegue", sender: self)
                }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("create profile error!")
                    let alert = UIAlertController(title: "Unable to create profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
    
}
