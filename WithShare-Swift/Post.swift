//
//  Post.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/1/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation
import UIKit

class Post {
    var id: Int64?
    var userId: Int64?
    var createdAt: NSDate
    var updatedAt: NSDate?
    
    var deviceToken: String?
    var deviceType: String?
    
    var username: String?
    var activityTitle: String?
    var meetPlace: String?
    var currentLatitude: Double?
    var currentLongtitude: Double?
    var status: String?
    
    var detail: String?
    
    // user profile
    var fullName: String?
    var postGender: String?
    var postGrade: String?
    var postDepartment: String?
    var postHobby: String?
    var postShareProfile: Bool?
    var postNumOfPosts: Int?
    var postPhoto: UIImage?
    
    // MARK: Initialization
    init?() {
        //UTC time
        self.createdAt = NSDate()
//        print(self.createdAt)
    }
    
    
}

