//
//  LoginViewController.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/17/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var withShareLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var user: User?
    var username: String?
    var username_saved: String?
    var password: String?
    var password_saved: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Login button
        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true
        
        //Disable Login button until input
        signInButton.isEnabled = false
        
        //Disable getting back in not logged in
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        //Desable tabbar in not logged in
        self.tabBarController?.tabBar.isHidden = true
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        
        //Handle the text field’s user input through delegate callbacks.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.tag = 0
        passwordTextField.tag = 1
        
        emailTextField.keyboardType = .emailAddress
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
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
        case 1:
            password = textField.text
        default:
            print("error registration textview")
        }
    }

    
    @IBAction func emailEditingDidEnd(_ sender: AnyObject) {
        // check fields here
//        username = self.emailTextField.text
        self.enableSignIn()
    }
    
    @IBAction func passwordEditingDidEnd(_ sender: AnyObject) {
        // check fields here
//        password = self.passwordTextField.text
        self.enableSignIn()
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
    }
        
    //MARK: Actions
    
    @IBAction func signIn(_ sender: AnyObject) {
        username = self.emailTextField.text!
        password = self.passwordTextField.text!
        user = User(username: username!, password: password!)
        
        ApiManager.sharedInstance.signIn(user!,
                                         onSuccess: {(user) in
                                            
                                            OperationQueue.main.addOperation {
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                print("signin success!")
                                                print("userid: ")
                                                print(user.id as Any)
                                                
                                                //cache current user status: Logged In
                                                let defaults = UserDefaults.standard
                                                defaults.set(true, forKey: Constants.NSUserDefaultsKey.logInStatus)
                                                defaults.set(NSNumber(value: user.id!), forKey: Constants.NSUserDefaultsKey.id)
                                                defaults.set(user.username, forKey: Constants.NSUserDefaultsKey.username)
                                                defaults.set(user.password, forKey: Constants.NSUserDefaultsKey.password)
                                                defaults.set(true, forKey: Constants.NSUserDefaultsKey.shareProfile)
                                                self.performSegue(withIdentifier: "logInSegue", sender: self)
                                                
                                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                
                                            }
                                            
                                            
        }, onError: {(error) in
            OperationQueue.main.addOperation {
                print("signin error!")
                print(error.userInfo)
                //                    let alert = UIAlertController(title: "Signin Failed", message:
                //                        error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let alert = UIAlertController(title: "Signin Failed", message:
                    "Incorrect username or password. If you have problem signing in, please contact jzc245@ist.psu.edu", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        })    }
    
    // Tests wether the signInButton should be enabled or not
    func enableSignIn() {
        if self.passwordTextField.text!.isBlank() || self.emailTextField.text!.isBlank() {
            signInButton.isEnabled = false
        } else {
            signInButton.isEnabled = true
        }
    }
    
}
        
 
