//
//  Join.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

class Join {
    var id: Int64?
    var createdAt: NSDate
    var updatedAt: NSDate?
    
    var userId: Int64?
    var postId: Int64?
    
    var currentLatitude: Double?
    var currentLongtitude: Double?
    
    var deviceType: String?
    
    // MARK: Initialization
    init?() {
        //UTC time
        self.createdAt = NSDate()
        //        print(self.createdAt)
        self.deviceType = Constants.deviceType
    }

}
