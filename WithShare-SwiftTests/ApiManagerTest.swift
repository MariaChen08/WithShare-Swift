//
//  ApiManagerTest.swift
//  WithShare-Swift
//
//  Created by Ben Hanrahan on Monday 8/1/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import XCTest

@testable import WithShare_Swift

class ApiManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGet() {
        let expectation = expectationWithDescription("Testing GET")
        var didFail = false
        
        ApiManager.sharedInstance.GET("http://localhost:8080/posts/", onSuccess: {(data, response) in
            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNotNil(response, "response should not be nil")
            
            if let httpResponse = response as? NSHTTPURLResponse {
                XCTAssertEqual(httpResponse.statusCode, 200)
                XCTAssertEqual(httpResponse.MIMEType, "application/json")
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
            expectation.fulfill()
        },
        onError: {(error) in
            didFail = true
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(NSTimeInterval.init(250), handler: nil)
        XCTAssertFalse(didFail)
    }
}
