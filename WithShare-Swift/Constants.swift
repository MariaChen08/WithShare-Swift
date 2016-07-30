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
    
    struct Gender {
        static let female = "female"
        static let male = "male"
        static let blank = ""
    }
    
    struct NSUserDefaultsKey {
        static let logInStatus = "UserLogIn"
        static let username = "UserName"
        static let password = "Password"
        static let phoneNumber = "PhoneNumber"
        static let shareProfile = "ShareProfile"
        static let fullName = "FullName"
        static let gender = "Gender"
        static let grade = "Grade"
        static let department = "Department"
        static let hobby = "Hobby"
//        static let numOfPosts = "NumOfPosts"
    }
    
    struct ServerModelField_User {
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
    }
    
    struct ServerModeField_Post {
        static let 
    }
}