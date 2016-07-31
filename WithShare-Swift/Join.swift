//
//  Join.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

class Join {
    var id: String?
    var createdAt: NSDate
    var deviceToken: String?
    var deviceType: String?
    
    var userId: String?
    var postId: String?
    
    var currentLatitude: Double?
    var currentLongtitude: Double?
    
    // MARK: Initialization
    init?() {
        //UTC time
        self.createdAt = NSDate()
        //        print(self.createdAt)
    }

}
