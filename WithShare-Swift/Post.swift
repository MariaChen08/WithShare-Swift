//
//  Post.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/1/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

class Post {
    var id: String?
    var createdAt: NSDate
    var deviceToken: String?
    var deviceType: String?
    
    var username: String?
    var activityTitle: String?
    var meetPlace: String?
    var currentLatitude: Double?
    var currentLongtitude: Double?
    var status: String?
    
    var detail: String?
    
    // MARK: Initialization
    init?() {
        //UTC time
        self.createdAt = NSDate()
//        print(self.createdAt)
    }
    
    
}

