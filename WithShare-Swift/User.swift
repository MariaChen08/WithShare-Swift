//
//  User.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/18/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation
import UIKit

class User {
    //MARK: Properties
    
    var id: String?
    var phoneKey: String?
    
    var emailAddress: String
    var password: String
    
    var firstName: String?
    var lastName: String?
    var title: String?
    var phoneNumber: String?
    var gender: GenderEnum?
    var profilePhoto: UIImage?
    
    // MARK: Initialization
    init?(id: String?, emailAddress: String, password: String, firstName: String?, lastName: String?, title: String?, phoneNumber: String?, gender: GenderEnum?, profilePhoto: UIImage?) {
        
        // Initialize stored properties.
        self.id = id
//        self.phoneKey = phoneKey

        self.emailAddress = emailAddress
        self.password = password
        
        self.firstName = firstName
        self.lastName = lastName
        self.title = title
        self.phoneNumber = phoneNumber
        self.gender = gender
        self.profilePhoto = profilePhoto
        
//         Initialization should fail if there is not valid PSU email or no password.
//        if password.isEmpty || emailAddress. {
//            return nil
//        }
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
    
    // MARK: Types
    struct PropertyKey {
        static let idKey = "id"
//        static let phoneKeyKey = "phoneKey"
        
        static let  emailAddressKey = "emailAddress"
        static let  passwordKey = "password"
        
        static let  firstNameKey = "firstName"
        static let  lastNameKey = "lastName"
        static let  titleKey = "title"
        static let  phoneNumberKey = "phoneNumber"
        static let  genderKey = "gender"
        static let  profilePhotoKey = "profilePhoto"

    }

}
