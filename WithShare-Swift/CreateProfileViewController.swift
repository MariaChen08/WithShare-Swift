//
//  CreateProfileViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 6/26/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController {
    //MARK: Properties
    var user:User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        print(user?.username)
        
    }


}
