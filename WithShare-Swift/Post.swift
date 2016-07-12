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
    
    var username: String?
    var currentLatitude: Double?
    var currentLongtitude: Double?
    var status: String?
    var activityTitle: String?
    var meetPlace: String?
    var detail: String?
    
    init?() {
        //UTC time
        self.createdAt = NSDate()
//        print(self.createdAt)
    }
    
    
}

