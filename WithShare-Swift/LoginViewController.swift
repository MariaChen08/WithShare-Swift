//
//  LoginViewController.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/17/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var withShareLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var user: User?
    var username: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Disable getting back in not logged in
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        //Desable tabbar in not logged in
        self.tabBarController?.tabBar.hidden = true
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func emailTextFieldDidEndEditing(emailTextField: UITextField) {
//        enableSignIn()
    }
    
    @IBAction func emailEditingDidEnd(sender: AnyObject) {
        // check fields here
        username = self.emailTextField.text
    }
    
    @IBAction func passwordEditingDidEnd(sender: AnyObject) {
        // check fields here
        password = self.passwordTextField.text
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
    }
    
    /* Tests wether the signInButton should be enabled or not  */
    func enableSignIn() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(user!, onSuccess: {(user) in
            print("get profile success")
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("get profile success")
                self.signInButton.enabled = true
                
                //cache current user status: Logged In
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: Constants.NSUserDefaultsKey.logInStatus)
                defaults.setObject(self.username, forKey: Constants.NSUserDefaultsKey.username)
                defaults.setObject(self.password, forKey: Constants.NSUserDefaultsKey.password)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("sign in error!")
                    let alert = UIAlertController(title: "Unable to sign in!", message:
                        "Incorrect passwork or please check network condition.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })

        
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.user?.username = self.emailTextField.text!
        self.user?.password = self.passwordTextField.text!
    }
    
    //MARK: Actions
    
    @IBAction func signIn(sender: AnyObject) {
        username = self.emailTextField.text!
        password = self.passwordTextField.text!
        user = User(username: username!, password: password!)
        
        //cache current user status: Logged In
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: Constants.NSUserDefaultsKey.logInStatus)
        defaults.setObject(self.username, forKey: Constants.NSUserDefaultsKey.username)
        defaults.setObject(self.password, forKey: Constants.NSUserDefaultsKey.password)
        
//        enableSignIn()
        self.performSegueWithIdentifier("logInSegue", sender: self)
    }
    
}
        
 
