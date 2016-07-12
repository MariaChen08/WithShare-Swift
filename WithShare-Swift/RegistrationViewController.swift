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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    @IBAction func createAccount(sender: AnyObject) {
        //cache current user status: Logged In
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "UserLogIn")
    }
    
    

}
