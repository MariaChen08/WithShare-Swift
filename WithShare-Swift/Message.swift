//
//  Message.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/18/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

class Message {

    var id: Int64?
    var createdAt: NSDate
    var updatedAt: NSDate?

    
    var senderId: Int64?
    var receiverId: Int64?
    var postId: Int64?
    
    var senderUsername: String?
    var senderFullname: String?
    var receiverUsername: String?
    var receiverFullname: String?
    
    var currentLatitude: Double?
    var currentLongtitude: Double?
    
    var content: String?
    
    // MARK: Initialization
    init?() {
        //UTC time
        self.createdAt = NSDate()
    }

}