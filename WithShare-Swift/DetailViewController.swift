//
//  DetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var meetPlaceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var sendMessageLabel: UILabel!
    
    var post:Post?
    
    override func viewDidLoad() {
        if let post = post {
            activityTitleLabel.text = "Activity Title: " + post.activityTitle!
            meetPlaceLabel.text = "meet@ " + post.meetPlace!
            detailLabel.text = post.detail!
        }
    }

}
