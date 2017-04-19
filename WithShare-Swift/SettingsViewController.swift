//
//  SettingsViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/11/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
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
    var currentUserId: Int64?
    
    var fullName: String?
    var gender: String?
    var grade: String?
    var department: String?
    var hobby: String?
    var shareProfile = true
    
    var profileDict = [Constants.ServerModelField_User.username: "", Constants.ServerModelField_User.fullname: "", Constants.ServerModelField_User.grade: "", Constants.ServerModelField_User.department: "", Constants.ServerModelField_User.hobby : "", Constants.ServerModelField_User.gender: "", Constants.ServerModelField_User.profilePhoto: "", Constants.ServerModelField_User.shareProfile: true] as [String : Any]
    
    let yearInSchoolPicker: UIPickerView = UIPickerView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve cached user info
        let defaults = UserDefaults.standard
        username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
        password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = ((defaults.object(forKey: Constants.NSUserDefaultsKey.id)) as AnyObject).int64Value
        user = User(username: username!, password: password!)
        user!.id = currentUserId
        user?.phoneNumber = phoneNumber
        
        //Show user profile
        self.loadProfileData()
        
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
            animateViewMoving(true, moveValue: 120)
        default:
            print("did not edit saved profile")
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 0:
            fullName = textField.text
            fullName = fullName?.trimmingCharacters(
                                in: CharacterSet.whitespacesAndNewlines)
        case 1:
            grade = textField.text
            grade = grade?.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
        case 2:
            department = textField.text
            department = department?.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
        case 3:
            hobby = textField.text
            hobby = hobby?.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
            animateViewMoving(false, moveValue: 120)
        default:
            print("did not edit saved profile")
        }
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
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        profileImage.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        
        fullNameTextField.resignFirstResponder()
        gradeTextField.resignFirstResponder()
        departmentTextField.resignFirstResponder()
        hobbyTextField.resignFirstResponder()
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func genderIndexChanged(_ sender: AnyObject) {
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
    
    @IBAction func shareProfileIndexChanged(_ sender: AnyObject) {
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
    
    @IBAction func logOut(_ sender: AnyObject) {
        //cache current user status: Logged Out
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: Constants.NSUserDefaultsKey.logInStatus)
    }
    
    @IBAction func saveChanges(_ sender: AnyObject) {
        profileDict[Constants.ServerModelField_User.username] = user?.username
        
        // read all text input
        fullName = fullNameTextField.text
        fullName = fullName?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        grade = gradeTextField.text
        grade = grade?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        department = departmentTextField.text
        department = department?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        hobby = hobbyTextField.text
        hobby = hobby?.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)
        
        if (fullName != nil && fullName != "") {
            profileDict[Constants.ServerModelField_User.fullname] = fullName
        }
        else {
            profileDict[Constants.ServerModelField_User.fullname] = Constants.blankSign
        }
        if (grade != nil && grade != "") {
            profileDict[Constants.ServerModelField_User.grade] = grade
        }
        else {
            profileDict[Constants.ServerModelField_User.grade] = Constants.blankSign
        }
        if (department != nil && department != "") {
            profileDict[Constants.ServerModelField_User.department] = department
        }
        else {
            profileDict[Constants.ServerModelField_User.department] = Constants.blankSign
        }
        if (hobby != nil && hobby != "") {
            profileDict[Constants.ServerModelField_User.hobby] = hobby
        }
        else {
            profileDict[Constants.ServerModelField_User.hobby] = Constants.blankSign
        }
        profileDict[Constants.ServerModelField_User.gender] = gender
        profileDict[Constants.ServerModelField_User.shareProfile] = shareProfile
        
        if (profileImage.image != nil) {
            user?.profilePhoto = profileImage.image
            // down scale photo
            user?.profilePhoto = resizeImage((user?.profilePhoto!)!, newWidth: 200)
            // Base64 encode photo
            let imageData:Data = UIImagePNGRepresentation((user?.profilePhoto)!)!
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            profileDict[Constants.ServerModelField_User.profilePhoto] = strBase64
        }
        
        // Upload to server
        ApiManager.sharedInstance.editProfile(user!, profileData: profileDict as Dictionary<String, AnyObject>, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("update profile success!")
                let alert = UIAlertController(title: "Successfully updated profile!", message:
                    "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("create profile error!")
                    let alert = UIAlertController(title: "Unable to update profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
    
    //MARK: load detail data
    func loadProfileData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(user!, onSuccess: {(user) in
            print("get profile success")
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("get profile success")
                
                if (user.fullName != nil && user.fullName != Constants.blankSign) {
                    self.fullNameTextField.text = user.fullName
                }
                if (user.grade != nil && user.grade != Constants.blankSign) {
                    self.gradeTextField.text = user.grade
                }
                if (user.department != nil && user.department != Constants.blankSign) {
                    self.departmentTextField.text = user.department
                }
                if (user.hobby != nil && user.hobby != Constants.blankSign) {
                    self.hobbyTextField.text = user.hobby
                }
                
                if user.gender == Constants.Gender.female {
                    self.genderSegmentedControl.selectedSegmentIndex = 0
                }
                else {
                    self.genderSegmentedControl.selectedSegmentIndex = 1
                }
                        
                if (user.shareProfile == true) {
                    self.shareProfileSegmentedControl.selectedSegmentIndex = 0
                }
                else {
                    self.shareProfileSegmentedControl.selectedSegmentIndex = 1
                }
                
                if (user.profilePhoto != nil) {
                    self.profileImage.image = user.profilePhoto
                }
//                else {
//                    //base64 string to NSData
//                    let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions(rawValue: 0))
//                    
//                    //NSData to UIImage
//                    var decodedIamge = UIImage(data: decodedData!)
//                }

            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("load profile error!")
                    let alert = UIAlertController(title: "Unable to load profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }

    // MARK: resize image
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
