//
//  UsageLog.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/29/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

class UsageLog {
    var id: Int64?
    var createdAt: NSDate
    
    var userId: Int64?
    var username: String?
    
    var postId: Int64?
    
    var code: String?
    var description: String?
    
    var currentLatitude: Double?
    var currentLongtitude: Double?
    
    // MARK: Initialization
    init?() {
        //UTC time
        self.createdAt = NSDate()
    }
    
}
