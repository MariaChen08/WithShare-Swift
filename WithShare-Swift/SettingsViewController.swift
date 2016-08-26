//
//  SettingsViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/11/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
    
    var profileDict = [Constants.ServerModelField_User.username: "", Constants.ServerModelField_User.fullname: "", Constants.ServerModelField_User.grade: "", Constants.ServerModelField_User.department: "", Constants.ServerModelField_User.hobby : "", Constants.ServerModelField_User.gender: "", Constants.ServerModelField_User.profilePhoto: "", Constants.ServerModelField_User.shareProfile: true]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
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
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        profileImage.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        
        fullNameTextField.resignFirstResponder()
        gradeTextField.resignFirstResponder()
        departmentTextField.resignFirstResponder()
        hobbyTextField.resignFirstResponder()
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
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
//        let defaults = NSUserDefaults.standardUserDefaults()
        
        if fullName != nil {
            fullNameTextField.text = fullName
//            defaults.setObject(fullName, forKey: Constants.NSUserDefaultsKey.fullName)
            profileDict[Constants.ServerModelField_User.fullname] = fullName
        }
        else {
            fullNameTextField.text = "Edit your full name.."
            profileDict[Constants.ServerModelField_User.fullname] = Constants.blankSign
        }
        if grade != nil {
            gradeTextField.text = grade
//            defaults.setObject(grade, forKey: Constants.NSUserDefaultsKey.grade)
            profileDict[Constants.ServerModelField_User.grade] = grade
        }
        else {
            gradeTextField.text = "e.g. freshman, senior, etc."
            profileDict[Constants.ServerModelField_User.grade] = Constants.blankSign
        }
        if department != nil {
            departmentTextField.text = department
//            defaults.setObject(department, forKey: Constants.NSUserDefaultsKey.department)
            profileDict[Constants.ServerModelField_User.department] = department
        }
        else {
            departmentTextField.text = "department"
            profileDict[Constants.ServerModelField_User.department] = Constants.blankSign
        }
        if hobby != nil {
            hobbyTextField.text = hobby
//            defaults.setObject(hobby, forKey: Constants.NSUserDefaultsKey.hobby)
            profileDict[Constants.ServerModelField_User.hobby] = hobby
        }
        else {
            hobbyTextField.text = "e.g. basketball, music, etc."
            profileDict[Constants.ServerModelField_User.hobby] = Constants.blankSign
        }
//        defaults.setObject(gender, forKey: Constants.NSUserDefaultsKey.gender)
        profileDict[Constants.ServerModelField_User.gender] = gender
//        defaults.setBool(shareProfile, forKey: Constants.NSUserDefaultsKey.shareProfile)
        profileDict[Constants.ServerModelField_User.shareProfile] = shareProfile
        
        if (profileImage.image != nil) {
            user?.profilePhoto = profileImage.image
            // down scale photo
            user?.profilePhoto = resizeImage((user?.profilePhoto!)!, newWidth: 200)
            // Base64 encode photo
            let imageData:NSData = UIImagePNGRepresentation((user?.profilePhoto)!)!
            let strBase64 = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            profileDict[Constants.ServerModelField_User.profilePhoto] = strBase64
        }
        
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
    
    //MARK: load detail data
    func loadProfileData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(user!, onSuccess: {(user) in
            print("get profile success")
            NSOperationQueue.mainQueue().addOperationWithBlock {
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

    // MARK: resize image
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
