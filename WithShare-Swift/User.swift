//
//  User.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/18/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation
import UIKit

class User {
    //MARK: Properties
    
    var id: Int64?
    var createdAt: NSDate
    var updatedAt: NSDate?
    
    var username: String?
    var password: String?
    
    var phoneNumber: String?
    var shareProfile: Bool?
    var deviceType: String?
    var deviceToken: String?
    
    var fullName: String?
    var gender: String?
    var grade: String?
    var department: String?
    var hobby: String?
    
    var profilePhoto: UIImage?
    
    var numOfPosts: Int?
    
    // MARK: Initialization
    init?(username: String, password: String) {
        //UTC time
        self.createdAt = NSDate()
        self.username = username
        self.password = password
//        self.phoneNumber = phoneNumber
    }
    
}
