//
//  Constants.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/30/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

struct Constants {
    static let deviceType = "iOS"
    
    static let blankSign = "not specified"
    
    static var deviceToken = ""
    
    static let termOfService = "WithShare is a Penn State research project investigating supporting co-production services and experience through mobile and ubiquitous technologies. By installing and using the application, you agree to share your experiences and uses of the app. Your participation is voluntary and confidential; your data will be stored securely, and destroyed at the end of the research project. There is no compensation other than free access to the app."
    
    struct Gender {
        static let female = "female"
        static let male = "male"
        static let blank = ""
    }
    
    struct PostStatus {
        static let active = "active"
        static let modified = "modified"
        static let closed = "closed"
    }
    
    struct JoinStatus {
        static let confirm = "confirmed"
        static let interested = "interested"
    }
    
    struct activityTypes {
        static let eatOut = "Eat Out"
        static let physicalActivity = "Physical Activities"
        static let groupStudy = "Group Study"
        static let socializing = "Socializing"
        static let more = "More"
        static let count = 5
    }
    
    struct NSUserDefaultsKey {
        static let logInStatus = "UserLogIn"
        static let id = "ID"
        static let username = "UserName"
        static let password = "Password"
        static let phoneNumber = "PhoneNumber"
        static let shareProfile = "ShareProfile"
        static let fullName = "FullName"
        static let gender = "Gender"
        static let grade = "Grade"
        static let department = "Department"
        static let hobby = "Hobby"
    }
    
    struct ServerModelField_User {
        static let id = "id"
        static let createdAt = "created_at"
        static let updatedAt = "updated_at"
        static let username = "email"
        static let password = "password"
        static let phoneNumber = "phone_number"
        static let deviceType = "device_type"
        static let deviceToken = "device_token"
        static let fullname = "full_name"
        static let gender = "gender"
        static let grade = "grade"
        static let department = "department"
        static let hobby = "hobby"
        static let shareProfile = "show_profile"
        static let numOfPosts = "num_of_posts"
        static let profilePhoto = "profile_photo"
    }
    
    struct ServerModelField_Post {
        static let id = "id"
        static let createdAt = "created_at"
        static let updatedAt = "updated_at"
        static let userId = "user_profile"
        static let deviceType = "device_type"
        static let deviceToken = "device_token"
        static let activityType = "activity_type"
        static let meetLocation = "meet_location"
        static let detail = "detail"
        static let currentLatitude = "current_latitude"
        static let currentLongitude = "current_longitude"
        static let status = "status"
    }
    
    struct ServerModelField_Join {
        static let id = "id"
        static let createdAt = "created_at"
        static let updatedAt = "updated_at"
        static let userId = "user_profile"
        static let postId = "post"
        static let postName = "post_name"
        static let deviceType = "device_type"
        static let currentLatitude = "current_latitude"
        static let currentLongitude = "current_longitude"
        static let status = "status"
    }

    struct ServerModelField_Message {
        static let id = "id"
        static let createdAt = "created_at"
        static let sender = "sender"
        static let receiver = "receiver"
        static let postId = "post"
        static let currentLatitude = "sender_latitude"
        static let currentLongitude = "sender_longitude"
        static let content = "content"
    }
    
    struct ServerModelField_UsageLog {
        static let id = "id"
        static let createdAt = "created_at"
        static let userId = "user_profile"
        static let postId = "post"
        static let code = "code"
        static let description = "description"
        static let currentLatitude = "current_latitude"
        static let currentLongitude = "current_longitude"
    }

}
