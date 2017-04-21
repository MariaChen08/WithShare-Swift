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
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var logInButton: UIButton!
    
    
    var user: User?
    var username: String?
    var password: String?
    var retypePassword: String?
    var alertMessage: String?
    var validRegisterInfo: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Sign Up button
        createAccountButton.layer.cornerRadius = 5
        createAccountButton.layer.masksToBounds = true
        
        //Disable Sign Up button
        createAccountButton.isEnabled = false
        
        //Handle the text field’s user input through delegate callbacks.
        emailTextField.delegate = self
        createPasswordTextField.delegate = self
        retypePasswordTextField.delegate = self
        
        emailTextField.keyboardType = .emailAddress
        
        emailTextField.tag = 0
        createPasswordTextField.tag = 1
        retypePasswordTextField.tag = 2
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 0:
            username = textField.text
            if username != nil {
                username = username!.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
            }
            self.enableSignUp()
        case 1:
            password = textField.text
            self.enableSignUp()
        case 2:
            retypePassword = textField.text
            self.enableSignUp()

        default:
            print("error registration textview")
        }
    }

    // format phone number input: (xxx) xxx-xxxx
    // http://stackoverflow.com/questions/1246439/uitextfield-for-phone-number
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 3 {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            
            return false
        }
        else
        {
            return true
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "createAccountSegue") {
            if let createProfileViewController = segue.destination as? CreateProfileViewController {
                createProfileViewController.user = self.user!
            }
        }
    }
    
    // MARK: Actions
    @IBAction func createAccount(_ sender: AnyObject) {
        
        if (username == nil || !ValidateUserInput(input: username!).isValidEmail() || !ValidateUserInput(input: username!).isEduSuffix()) {
            alertMessage = "Please enter your PSU email."
            print(alertMessage as Any)
        }
        else if (password == nil || (password!.isBlank() == true)) {
            alertMessage = "Please create WithShare password."
            print(alertMessage as Any)
        }
        else if (retypePassword == nil || !(retypePassword == password)) {
            alertMessage = "Retype password does not match."
            print(alertMessage as Any)
        }
        else {
            validRegisterInfo = true
        }
        
        if validRegisterInfo {
            //create user account
            user = User(username: username!, password: password!)

            // MARK: TO DO device Token issue
//            user?.deviceToken = Constants.deviceToken
            user?.deviceToken = UIDevice.current.identifierForVendor!.uuidString
            user?.deviceType = Constants.deviceType
            user?.shareProfile = true
            user?.numOfPosts = 0
            user?.profilePhoto = UIImage(named: "EmptyProfile")
            
            //register user to server
            ApiManager.sharedInstance.signUp(user!,
                                             onSuccess: {(user) in
                                                
                                                OperationQueue.main.addOperation {
                                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                    print("signup success!")
                                                    print("userid: ")
                                                    print(user.id as Any)
                                                    
                                                    //cache current user status: Logged In
                                                    let defaults = UserDefaults.standard
                                                    defaults.set(true, forKey: Constants.NSUserDefaultsKey.logInStatus)
                                                    defaults.set(NSNumber(value: user.id! as Int64), forKey: Constants.NSUserDefaultsKey.id)
                                                    defaults.set(user.username, forKey: Constants.NSUserDefaultsKey.username)
                                                    defaults.set(user.password, forKey: Constants.NSUserDefaultsKey.password)
                                                    defaults.set(user.phoneNumber, forKey: Constants.NSUserDefaultsKey.phoneNumber)
                                                    defaults.set(true, forKey: Constants.NSUserDefaultsKey.shareProfile)
                                                    
                                                    let alert = UIAlertController(title: "Signup Success!", message:
                                                        Constants.termOfService, preferredStyle: UIAlertControllerStyle.alert)
                                                    alert.addAction(UIAlertAction(title: "Agree to terms.", style: UIAlertActionStyle.default,handler: { (action: UIAlertAction!) in
                                                        self.performSegue(withIdentifier: "createAccountSegue", sender: self)
                                                    }))

                                                    
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                    
                                                }

                                                
                }, onError: {(error) in
                    OperationQueue.main.addOperation {
                        print("signup error!")
                        print(error.userInfo)
                        let alert = UIAlertController(title: "Signup Failed", message:
                        error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                        self.present(alert, animated: true, completion: nil)
                    }
            })

        }
        else {
            // create the alert
            let alert = UIAlertController(title: "Signup Error", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    /* Tests wether the signUpButton should be enabled or not  */
    func enableSignUp() {
        if self.createPasswordTextField.text!.isBlank() || self.retypePasswordTextField.text!.isBlank(){
            createAccountButton.isEnabled = false
        } else {
            createAccountButton.isEnabled = true
        }
    }

    
}
