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
    
    var username: String?
    var username_saved: String?
    var password: String?
    var password_saved: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Disable Login button until input
        signInButton.enabled = false
        
        //Disable getting back in not logged in
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        //Desable tabbar in not logged in
        self.tabBarController?.tabBar.hidden = true
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        
        //Handle the text field’s user input through delegate callbacks.
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.tag = 0
        passwordTextField.tag = 1
        
        emailTextField.keyboardType = .EmailAddress
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
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
        default:
            print("error registration textview")
        }
    }

    
    @IBAction func emailEditingDidEnd(sender: AnyObject) {
        // check fields here
//        username = self.emailTextField.text
        self.enableSignIn()
    }
    
    @IBAction func passwordEditingDidEnd(sender: AnyObject) {
        // check fields here
//        password = self.passwordTextField.text
        self.enableSignIn()
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
    }
        
    //MARK: Actions
    
    @IBAction func signIn(sender: AnyObject) {
        username = self.emailTextField.text!
        password = self.passwordTextField.text!
        
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        username_saved = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password_saved = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        
        if (username_saved == username && password_saved == password) {
            defaults.setBool(true, forKey: Constants.NSUserDefaultsKey.logInStatus)
            self.performSegueWithIdentifier("logInSegue", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Unable to sign in!", message:
                                    "Incorrect passwork, please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)

        }
    }
    
    // Tests wether the signInButton should be enabled or not
    func enableSignIn() {
        if self.passwordTextField.text!.isBlank() || self.emailTextField.text!.isBlank() {
            signInButton.enabled = false
        } else {
            signInButton.enabled = true
        }
    }
    
}
        
 
