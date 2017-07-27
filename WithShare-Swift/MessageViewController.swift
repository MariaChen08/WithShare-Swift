//
//  MessageViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 5/4/17.
//  Copyright © 2017 Jiawei Chen. All rights reserved.
//

import Foundation
import JSQMessagesViewController

final class MessageViewController: JSQMessagesViewController {
    
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    var postId: Int64?
    var firstJoin: Bool = false
    
    override func viewDidLoad() {
        self.senderId = String(describing: currentUserId)
        self.senderDisplayName = username
        self.tabBarController?.tabBar.isHidden = true
    }
}
