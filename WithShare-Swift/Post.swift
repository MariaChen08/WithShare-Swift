//
//  Post.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/1/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation
//import GoogleMaps

class Post {
    var id: String?
    var createdAt: NSDate
//    var deviceToken: String?
    var deviceType: DeviceTypeEnum?
    
    var user: User?
    var currentLatitude: Double?
    var currentLongtitude: Double?
    
    var activityTitle: String?
    var meetPlace: String?
    var detail: String?
    
    init?() {
        //UTC time
        self.createdAt = NSDate()
//        print(self.createdAt)
    }
    
    
}

