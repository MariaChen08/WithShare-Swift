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
    
    struct Gender {
        static let female = "female"
        static let male = "male"
        static let blank = ""
    }
    
    struct PostStatus {
        static let active = "active"
        static let modified = "modified"
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
        static let fullname = "full_name"
        static let gender = "gender"
        static let grade = "grade"
        static let department = "department"
        static let hobby = "hobby"
        static let shareProfile = "show_profile"
        static let numOfPosts = "num_of_posts"
        static let profilePhoto = "profile_photo"
    }
    
    struct ServerModeField_Post {
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
}