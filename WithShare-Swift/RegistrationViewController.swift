//
//  RegistrationViewController.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/20/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate{
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var createPasswordTextField: UITextField!
    
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    var user: User?
    var username: String?
    var password: String?
    var retypePassword: String?
    var phoneNumber: String?
    var alertMessage: String?
    var validRegisterInfo: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Handle the text field’s user input through delegate callbacks.
        emailTextField.delegate = self
        createPasswordTextField.delegate = self
        retypePasswordTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        emailTextField.keyboardType = .EmailAddress
        phoneNumberTextField.keyboardType = .PhonePad
        
        emailTextField.tag = 0
        createPasswordTextField.tag = 1
        retypePasswordTextField.tag = 2
        phoneNumberTextField.tag = 3
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            username = textField.text
            if username != nil {
                username = username!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 1:
            password = textField.text
        case 2:
            retypePassword = textField.text
        case 3:
            phoneNumber = textField.text
//            print("phoneNumber: " + phoneNumber!)
        default:
            print("error registration textview")
        }
    }

    // format phone number input: (xxx) xxx-xxxx
    // http://stackoverflow.com/questions/1246439/uitextfield-for-phone-number
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 3 {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            phoneNumber = textField.text
            return false
        }
        else
        {
            return true
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "createAccountSegue") {
            if let createProfileViewController = segue.destinationViewController as? CreateProfileViewController {
                createProfileViewController.user = self.user!
            }
        }
    }
    
    
    // MARK: Actions
    @IBAction func createAccount(sender: AnyObject) {
//        print("phoneNumber: " + phoneNumber!)
        if (username == nil || !ValidateUserInput(input: username!).isValidEmail() || !ValidateUserInput(input: username!).isEduSuffix()) {
            alertMessage = "Please enter your PSU email."
            print(alertMessage)
        }
        else if (password == nil || (password!.isBlank() == true)) {
            alertMessage = "Please create WithShare password."
            print(alertMessage)
        }
        else if (retypePassword == nil || !(retypePassword == password)) {
            alertMessage = "Retype password does not match."
            print(alertMessage)
        }
        else if (phoneNumber == nil) {
            alertMessage = "Please enter your phone number. It will help people to contact you when they want to join your activity. We won't disclose your phone number in any occasion."
            print(alertMessage)
        }
        else {
            validRegisterInfo = true
        }
        
        if validRegisterInfo {
            //create user account
            user = User(username: username!, password: password!, phoneNumber: phoneNumber!)

            user!.deviceType = Constants.deviceType
            user!.shareProfile = true
            user!.numOfPosts = 0
            
            
            //register user to server
            ApiManager.sharedInstance.signUp(user!,
                                             onSuccess: {(user) in
                                                
                                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                                    print("signup success!")
                                                    self.performSegueWithIdentifier("createAccountSegue", sender: self)
                                                    
                                                    //cache current user status: Logged In
                                                    let defaults = NSUserDefaults.standardUserDefaults()
                                                    defaults.setBool(true, forKey: Constants.NSUserDefaultsKey.logInStatus)
                                                    defaults.setObject(user.username, forKey: Constants.NSUserDefaultsKey.username)
                                                    defaults.setObject(user.password, forKey: Constants.NSUserDefaultsKey.password)
                                                    defaults.setObject(user.phoneNumber, forKey: Constants.NSUserDefaultsKey.phoneNumber)
                                                    defaults.setBool(true, forKey: Constants.NSUserDefaultsKey.shareProfile)
                                                    
                                                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                                }

                                                
                }, onError: {(error) in
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        print("signup error!")
                        let alert = UIAlertController(title: "Signup Failed", message:
                        "Signup Failed", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            })

        }
        else {
            // create the alert
            let alert = UIAlertController(title: "Ooooops", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)

        }
    }
    
}
