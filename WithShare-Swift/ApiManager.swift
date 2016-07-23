//
//  ApiManager.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/21/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

class ApiManager: NSObject, NSURLSessionDelegate {
    // this is the singleton that you use to access use the API
    static let sharedInstance = ApiManager()
    
    // server url: local test at the moment
    static let serverUrl = "http://localhost:8000/"
    let cache = NSCache()
    
    // MARK: HTTP GET and POST
    /**
     The GET call to the backend
     
     - Parameter url: What you want to call, in our case this also has all of the data as parameters to the url
     - Parameter onSuccess: What you want to call in the case it succeeds
     - Parameter onFail: Void - callback function when failed
     */
    func GET(url: String, onSuccess: (data: NSArray, response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        // returns a singleton session based on default configuration
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            var jsonData: NSArray = []
            
            do {
                if data != nil {
                    jsonData = try (NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSArray)!
                } else {
                    onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["No data": NSObject()]), response: NSURLResponse())
                }
            } catch _ {
                onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON response": NSObject()]), response: response!)
                return
            }
            
            if error != nil {
                onError(error: error!, response: NSURLResponse())
            } else {
                onSuccess(data: jsonData, response: response!)
            }
        })
        
        task.resume()
    }
    
    // HTTP POST with Basic Authentication (username + password)
    func POST(url: String, username: String, password: String, data: Dictionary<String,String>, onSuccess: (response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Basic Authentication with (username + password)
        let userPasswordString = username + ":" + password //"username@gmail.com:password"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions([])
        let authString = "Basic \(base64EncodedCredential)"
        request.addValue(authString, forHTTPHeaderField: "Authorization")
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions())
        } catch _ {
            onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON request data": NSObject()]), response: NSURLResponse())
            return
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if (response as? NSHTTPURLResponse)?.statusCode != 201 {
                print((response as? NSHTTPURLResponse)?.statusCode)
                onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Server returned error": NSObject()]), response: NSURLResponse())
                return
            }
            
            if error != nil {
                onError(error: error!, response: response!)
            } else {
                onSuccess(response: response!)
            }
        })
        
        task.resume()
    }
    
    // HTTP POST with No Authentication
    func POST_simple(url: String, data: Dictionary<String,String>, onSuccess: (response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions())
        } catch _ {
            onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON request data": NSObject()]), response: NSURLResponse())
            return
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if (response as? NSHTTPURLResponse)?.statusCode != 201 {
                print((response as? NSHTTPURLResponse)?.statusCode)
                onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Server returned error": NSObject()]), response: NSURLResponse())
                return
            }
            
            if error != nil {
                onError(error: error!, response: response!)
            } else {
                onSuccess(response: response!)
            }
        })
        
        task.resume()
    }

    
    //MARK: User Profile Api
//    func signUp(user: User, onSuccess: (response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
    func signUp(user: User) {
        let specificUrl = "signup/"
        
//        let encodedUsername = self.base64Encode(user.username!)
//        let encodedPassword = self.base64Encode(user.password!)
//        let encodedPhoneNumber = self.base64Encode(user.phoneNumber!)
//        let userPasswordDictionary: [String: String] = ["email": encodedUsername, "password": encodedPassword, "phone_number": encodedPhoneNumber]
        let userPasswordDictionary: [String: String] = ["email": user.username!, "password": user.password!, "phone_number": user.phoneNumber!]
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("signup url: " + fullUrl)
        
        // make the call
        ApiManager.sharedInstance.POST_simple(fullUrl, data: userPasswordDictionary, onSuccess: {(response) in
//                if response["status_message"] as! String == "Account Already Exists" {
//                    let error = NSError(domain: "transitShare", code: -1000, userInfo: ["user already exists": NSObject()])
//                    onError(error: error)
//                } else {
//                    onSuccess(user: User)
//                }
                print(response)
            }
            , onError: {(error, response) in
                print(response)
                print(error)
                // do nothing
        })
    
    }

    
    
    //MARK: Miscellaneous Formatting
    func FormatDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.dateFromString(dateString)!
    }
    
    /**
     Encoded a string in base 64
     
     - Parameter toEncode: whatever it is you want to encode
     
     - Returns: the encoded string as an NSObject
     */
    func base64Encode(toEncode: String) -> String {
        print("encoding \(toEncode)")
        let utf8Data = toEncode.dataUsingEncoding(NSUTF8StringEncoding)
        return utf8Data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }

    
}