//
//  WithShare_SwiftTests.swift
//  WithShare-SwiftTests
//
//  Created by Jiawei Chen on 6/26/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import XCTest
@testable import WithShare_Swift

class WithShare_SwiftTests: XCTestCase {
    //MARK: WithShare tests
    func testInputValidation () {
        //is valid psu email
        let input = " abc@ist.psu.edu"
        let testInput = ValidateUserInput(input: input)
        let testEmpty = testInput.isEmpty()
        let testEmail = testInput.isValidEmail()
        let testSuffix = testInput.isEduSuffix()
        XCTAssert(testEmpty == false, "test empty")
        XCTAssert(testEmail == true, "test email")
        XCTAssert(testSuffix == true, "test suffix")
        
        //is empty
        let emptyInput = "   "
        let testEmptyInput = ValidateUserInput(input: emptyInput)
        let testEmptyEmtpy = testEmptyInput.isEmpty()
        XCTAssert(testEmptyEmtpy == true, "test empty")
        
        //not email
        let noEmailInput = "abcde"
        let testEmailInput = ValidateUserInput(input: noEmailInput)
        let testEmailEmail = testEmailInput.isValidEmail()
        XCTAssert(testEmailEmail == false, "test email")
        
        //not psu.edu suffix
        let noSuffixInput = "abc@gmail.edu"
        let testSuffixInput = ValidateUserInput(input: noSuffixInput)
        let testSuffixSuffix = testSuffixInput.isEduSuffix()
        XCTAssert(testSuffixSuffix == false, "test suffix")
        
        //check phone number
        let noPhoneInput = "a23"
        let testPhonePhone = noPhoneInput.isPhoneNumber()
        XCTAssert(testPhonePhone == false, "test suffix")
    }
    
    func testApiManager() {
        let user = User(username: "test@psu.edu",password: "testPassword", phoneNumber: "8148148888")

        //ApiManager.sharedInstance.signUp(user!)
    }
}
