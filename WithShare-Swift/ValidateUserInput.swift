//
//  ValidateUserInput.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/2/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

class ValidateUserInput {
    
    //MARK: Properties
    var input: String
    var trimmedInput: String
    
    //MARK: Initialization
    init(input: String) {
        // Initialize stored properties.
        self.input = input
        self.trimmedInput = input.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    // MARK: Methods
    
    // if input is empty
    func isEmpty() -> Bool {
        return trimmedInput.isEmpty
    }
    
    // if input is a valid email
    func isValidEmail() -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: trimmedInput)
    }
    
    //if psu.edu suffix
    func isEduSuffix() -> Bool {
        let startIndex = trimmedInput.characters.index(trimmedInput.endIndex, offsetBy: -7)
        let endIndex = trimmedInput.endIndex
        let range = startIndex..<endIndex   // same as let range = Range(start: startIndex, end: endIndex)
        let suffix = trimmedInput[range]
        return (suffix == "psu.edu")
        
    }
    
}
