//
//  CreateActivityViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 6/29/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class CreateActivityViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var activityTypeButton: UIButton!
    var activityType:String? = "More"
    
    override func viewDidLoad() {
        activityTypeButton.setTitle(activityType, forState: .Normal)
    }

}
