//
//  StringExtensions.swift
//  Transport Share
//
//  Created by Ben Hanrahan on 12/6/15.
//  Copyright © 2015 PSU CHCI. All rights reserved.
//

import Foundation

extension String {
    
    // To check text field or String is blank or not
    func isBlank() -> Bool {
        let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return trimmed.isEmpty
    }
    
    // Validate Email
    func isPSUEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    // validate PhoneNumber
    func isPhoneNumber() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "\\(\\d{3}\\)\\s\\d{3}-\\d{4}", options: [])
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }

}