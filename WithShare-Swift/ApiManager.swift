//
//  ApiManager.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/21/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation
import UIKit

class ApiManager: NSObject, URLSessionDelegate {
    // this is the singleton that you use to access use the API
    static let sharedInstance = ApiManager()
    
    // server url
    static let serverUrl = "https://withshare.ist.psu.edu/"
    let cache = NSCache<AnyObject, AnyObject>()
    
    // MARK: HTTP GET and POST
    /**
     The GET call to the backend
     
     - Parameter url: What you want to call, in our case this also has all of the data as parameters to the url
     - Parameter onSuccess: What you want to call in the case it succeeds
     - Parameter onFail: Void - callback function when failed
     */
    func GET(url: String, username: String, password: String, onSuccess: @escaping (_ data: Array<Dictionary<String, AnyObject>>, _ response: URLResponse) -> Void, onError: @escaping (_ error: NSError, _ response: URLResponse) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Basic Authentication with (username + password)
        let userPasswordString = NSString(format: "%@:%@", username, password)
        print(userPasswordString)
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8.rawValue)
        let base64EncodedCredential = userPasswordData!.base64EncodedString(options: [])
        request.addValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        // returns a singleton session based on default configuration
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            var jsonData: Array<Dictionary<String, AnyObject>> = [[:]]
            
            if data != nil {
//                let responseData = String(data: data!, encoding: String.Encoding.utf8)
//                print("Get Body:" + responseData!)
                
                do {
                    jsonData = try (JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as? Array<Dictionary<String, AnyObject>>)!
                }
                catch _ {
                    onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), URLResponse())
                }
                    
            } else {
                onError(NSError(domain: "WithShare", code: -1000, userInfo: ["No data": NSObject()]), URLResponse())
            }
            
            if error != nil {
                onError(error! as NSError, URLResponse())
            } else {
                onSuccess(jsonData, response!)
            }
        })
        
        task.resume()
    }
    
    func GET_singleton(_ url: String, username: String, password: String, onSuccess: @escaping (_ data: [String: AnyObject], _ response: URLResponse) -> Void, onError: @escaping (_ error: NSError, _ response: URLResponse) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Basic Authentication with (username + password)
        let userPasswordString = NSString(format: "%@:%@", username, password)
        print(userPasswordString)
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8.rawValue)
        let base64EncodedCredential = userPasswordData!.base64EncodedString(options: [])
        request.addValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        // returns a singleton session based on default configuration
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? HTTPURLResponse)?.statusCode as Any)
            if data != nil {
//                let responseData = String(data: data!, encoding: String.Encoding.utf8)
//                print("Body:" + responseData!)
                
                do {
                    dataDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                } catch _ {
                    print("Serialization error")
                    onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), URLResponse())
                }
                
            }
            else {
                print("Body null")
            }
            
            if error != nil {
                onError(error! as NSError, URLResponse())
            } else {
                onSuccess(dataDict, response!)
            }
        })
        
        task.resume()
    }

    
    // HTTP POST with Basic Authentication (username + password)
    func POST(_ url: String, username: String, password: String, data: Dictionary<String,AnyObject>, onSuccess: @escaping (_ databack: [String: AnyObject], _ response: URLResponse) -> Void, onError: @escaping (_ error: NSError, _ response: URLResponse) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Basic Authentication with (username + password)
        let userPasswordString = NSString(format: "%@:%@", username, password)
        print(userPasswordString)
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8.rawValue)
        let base64EncodedCredential = userPasswordData!.base64EncodedString(options: [])
        request.addValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions())
        } catch _ {
            onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON request data": NSObject()]), URLResponse())
            return
        }
        
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? HTTPURLResponse)?.statusCode as Any)
            if data != nil {
                let responseData = String(data: data!, encoding: String.Encoding.utf8)
                print("Body:" + responseData!)
                
                do {
                    dataDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                } catch _ {
                    onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), URLResponse())
                }

            }
            else {
                print("Body null")
            }
            
            if (response as? HTTPURLResponse)?.statusCode != 201 {
                onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Server returned error": NSObject()]), URLResponse())
                return
            }
            
            if error != nil {
                onError(error! as NSError, URLResponse())
            } else {
                onSuccess(dataDict, response!)
            }
        })
        
        task.resume()
    }
    
    // HTTP POST with No Authentication
    func POST_simple(_ url: String, data: Dictionary<String,AnyObject>, onSuccess: @escaping (_ databack: [String: AnyObject], _ response: URLResponse) -> Void, onError: @escaping (_ error: NSError, _ response: URLResponse) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions())
        } catch _ {
            onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON request data": NSObject()]), URLResponse())
            return
        }
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? HTTPURLResponse)?.statusCode as Any)
            if data != nil {
                let responseData = String(data: data!, encoding: String.Encoding.utf8)
                print("Body:" + responseData!)
                
                do {
                    dataDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                } catch _ {
                    onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), URLResponse())
                }
                
            }
            else {
                print("Body null")
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 409 {
                onError(NSError(domain: "WithShare: User with that email already exists", code: -1000, userInfo: ["User with that email already exists": NSObject()]), URLResponse())
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode != 201 {
                onError(NSError(domain: "WithShare: Please check network condition or try later", code: -1000, userInfo: ["Server returned error": NSObject()]), URLResponse())
                return
            }
            
            if error != nil {
                onError(error! as NSError, URLResponse())
            } else {
                onSuccess(dataDict, response!)
            }
        })
        
        task.resume()
    }
    
    // HTTP PUT with Basic Authentication (username + password)
    func PUT(_ url: String, username: String, password: String, data: Dictionary<String,AnyObject>, onSuccess: @escaping (_ databack: [String: AnyObject], _ response: URLResponse) -> Void, onError: @escaping (_ error: NSError, _ response: URLResponse) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Basic Authentication with (username + password)
        let userPasswordString = NSString(format: "%@:%@", username, password)
        print(userPasswordString)
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8.rawValue)
        let base64EncodedCredential = userPasswordData!.base64EncodedString(options: [])
        request.addValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions())
        } catch _ {
            onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON request data": NSObject()]), URLResponse())
            return
        }
        
        // returns a singleton session based on default configuration
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? HTTPURLResponse)?.statusCode as Any)
            if data != nil {
                let responseData = String(data: data!, encoding: String.Encoding.utf8)
                print("Body:" + responseData!)
                
                do {
                    dataDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                } catch _ {
                    onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), URLResponse())
                }
                
            }
            else {
                print("Body null")
            }
            
            if ((response as? HTTPURLResponse)?.statusCode != 201 && (response as? HTTPURLResponse)?.statusCode != 200) {
                onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Server returned error": NSObject()]), URLResponse())
                return
            }
            
            if error != nil {
                onError(error! as NSError, URLResponse())
            } else {
                onSuccess(dataDict, response!)
            }
        })
        
        task.resume()
    }
    
    // HTTP POST with No Authentication
    

    
    func PUT_simple(_ url: String, data: Dictionary<String,AnyObject>, onSuccess: @escaping (_ databack: [String: AnyObject], _ response: URLResponse) -> Void, onError: @escaping (_ error: NSError, _ response: URLResponse) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions())
        } catch _ {
            onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON request data": NSObject()]), URLResponse())
            return
        }
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) -> Void in
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? HTTPURLResponse)?.statusCode as Any)
            if data != nil {
                let responseData = String(data: data!, encoding: String.Encoding.utf8)
                print("Body:" + responseData!)
                
                do {
                    dataDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                } catch _ {
                    onError(NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), URLResponse())
                }
                
            }
            else {
                print("Body null")
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 401 {
                onError(NSError(domain: "WithShare: Incorrect username or password", code: -1000, userInfo: ["Incorrect username or password": NSObject()]), URLResponse())
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode != 202 {
                onError(NSError(domain: "WithShare: Please check network condition or try later", code: -1000, userInfo: ["Server returned error": NSObject()]), URLResponse())
                return
            }
            
            if error != nil {
                onError(error! as NSError, URLResponse())
            } else {
                onSuccess(dataDict, response!)
            }
        })
        
        task.resume()
    }

    
    //MARK: User Profile Api
    func signUp(_ user: User, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let specificUrl = "signup/"
        
        // Sign up with 1) psu email, 2) password, 3) phone number, 4) device type (iOS), 5) show profile setting and 6) number of posts (initialized as 0)
        
        let imageData:Data = UIImagePNGRepresentation((user.profilePhoto)!)!
        let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        let userPasswordDictionary: [String: AnyObject] = [Constants.ServerModelField_User.username: user.username! as AnyObject, Constants.ServerModelField_User.password: user.password! as AnyObject, Constants.ServerModelField_User.phoneNumber: user.phoneNumber! as AnyObject, Constants.ServerModelField_User.deviceType: user.deviceType! as AnyObject, Constants.ServerModelField_User.deviceToken: user.deviceToken! as AnyObject, Constants.ServerModelField_User.shareProfile: user.shareProfile! as AnyObject, Constants.ServerModelField_User.numOfPosts: user.numOfPosts! as AnyObject, Constants.ServerModelField_User.profilePhoto: strBase64 as AnyObject]
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("signup url: " + fullUrl)
        
        // make the call
        ApiManager.sharedInstance.POST_simple(fullUrl, data: userPasswordDictionary, onSuccess: {(data, response) in
            print("signup return data:")
            print(data)
            let id = data[Constants.ServerModelField_User.id]
            user.id = id?.int64Value
                onSuccess(user)
            }
            , onError: {(error, response) in
                onError(error)
        })
    }
    
    func signIn(_ user: User, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let specificUrl = "signin/"
        
        // Sign in with 1) psu email, 2) password
        
        let userPasswordDictionary: [String: AnyObject] = [Constants.ServerModelField_User.username: user.username! as AnyObject, Constants.ServerModelField_User.password: user.password! as AnyObject]
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("signin url: " + fullUrl)
        
        // make the call
        ApiManager.sharedInstance.PUT_simple(fullUrl, data: userPasswordDictionary, onSuccess: {(data, response) in
            print("signin return data:")
            print(data)
            let id = data[Constants.ServerModelField_User.id]
            user.id = id?.longLongValue
            onSuccess(user)
        }
            , onError: {(error, response) in
                onError(error)
        })
    }

    func editProfile(_ user: User, profileData: Dictionary<String,AnyObject>, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let specificUrl = "edit_profile/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("edit profile url: " + fullUrl)
        
        ApiManager.sharedInstance.PUT(fullUrl, username: user.username!, password: user.password!, data: profileData, onSuccess: {(response) in
            onSuccess(user)
            }
            , onError: {(error, response) in
                onError(error)
        })
        
    }
    
    func getProfile(_ currentUser: User, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let idField = String(currentUser.id!)
        let specificUrl = "userprofiles/" + idField + "/"
        print(specificUrl)
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        ApiManager.sharedInstance.GET_singleton(fullUrl, username: currentUser.username!, password: currentUser.password!, onSuccess: {(data, response) in
                print("get profile return data:")
//                print(data)
                let user = User(username: "",password: "")
                let id = data[Constants.ServerModelField_User.id] as? NSNumber
                user!.id = id?.int64Value
                user!.username = data[Constants.ServerModelField_User.username] as? String
                user!.phoneNumber = data[Constants.ServerModelField_User.phoneNumber] as? String
                user!.fullName = data[Constants.ServerModelField_User.fullname] as? String
                user!.gender = data[Constants.ServerModelField_User.gender] as? String
                user!.grade = data[Constants.ServerModelField_User.grade] as? String
                user!.department = data[Constants.ServerModelField_User.department] as? String
                user!.hobby = data[Constants.ServerModelField_User.hobby] as? String
                user!.shareProfile = data[Constants.ServerModelField_User.shareProfile] as? Bool
                user!.numOfPosts = data[Constants.ServerModelField_User.numOfPosts] as? Int
            
                // Decode profile image
                if (data[Constants.ServerModelField_User.profilePhoto] != nil) {
                    let base64Image = data[Constants.ServerModelField_User.profilePhoto] as? String
                    if (base64Image != nil) {
                        
                        let decodedImage = Data(base64Encoded: base64Image!, options: NSData.Base64DecodingOptions(rawValue: 0) )
                    
                        user?.profilePhoto = UIImage(data: decodedImage!)
                    }

                }
                onSuccess(user!)
            }
            , onError: {(error, response) in
                onError(error)
        })

    }
    
    //MARK: Post Activities APIs
    func createActivity(_ user: User, post: Post, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let specificUrl = "posts/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("create activity url: " + fullUrl)
        print("user id:" + String(user.id!))
        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(value: user.id! as Int64), Constants.ServerModelField_User.username: user.username! as AnyObject]
        let activityData: [String: AnyObject] = [Constants.ServerModelField_Post.userId: userProfile as AnyObject, Constants.ServerModelField_Post.deviceType: post.deviceType! as AnyObject, Constants.ServerModelField_Post.deviceToken: post.deviceToken! as AnyObject, Constants.ServerModelField_Post.activityType: post.activityTitle! as AnyObject, Constants.ServerModelField_Post.meetLocation: post.meetPlace! as AnyObject, Constants.ServerModelField_Post.detail: post.detail! as AnyObject, Constants.ServerModelField_Post.currentLatitude: post.currentLatitude! as AnyObject,Constants.ServerModelField_Post.currentLongitude: post.currentLongtitude! as AnyObject, Constants.ServerModelField_Post.status: post.status! as AnyObject]
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: activityData, onSuccess: {(data, response) in
                let id = data[Constants.ServerModelField_User.id] 
                post.id = id?.int64Value

                onSuccess(user)
            }
            , onError: {(error, response) in
                onError(error)
        })
        
    }
    
    func editActivity(_ user: User, post: Post, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let idField = String(post.id!)
        let specificUrl = "posts/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("create activity url: " + fullUrl)
        print("user id:" + String(user.id!))
        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(value: user.id! as Int64), Constants.ServerModelField_User.username: user.username! as AnyObject]
        let activityData: [String: AnyObject] = [Constants.ServerModelField_Post.userId: userProfile as AnyObject, Constants.ServerModelField_Post.deviceType: post.deviceType! as AnyObject, Constants.ServerModelField_Post.deviceToken: post.deviceToken! as AnyObject, Constants.ServerModelField_Post.activityType: post.activityTitle! as AnyObject, Constants.ServerModelField_Post.meetLocation: post.meetPlace! as AnyObject, Constants.ServerModelField_Post.detail: post.detail! as AnyObject, Constants.ServerModelField_Post.currentLatitude: post.currentLatitude! as AnyObject,Constants.ServerModelField_Post.currentLongitude: post.currentLongtitude! as AnyObject, Constants.ServerModelField_Post.status: post.status! as AnyObject]
        
        ApiManager.sharedInstance.PUT(fullUrl, username: user.username!, password: user.password!, data: activityData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_User.id]
            post.id = id?.int64Value
            
            onSuccess(user)
            }
            , onError: {(error, response) in
                onError(error)
        })
        
    }


    func getActivity(_ user: User, onSuccess: @escaping (_ posts: [Post]) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        // get yesterday
        let yesterDayDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: Date(), options: [])
        // Format time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = dateFormatter.string(from: yesterDayDate!)
        
        // Construct API URL
        let specificUrl = "posts/?created_at_gt=" + dateString
        let fullUrl = ApiManager.serverUrl + specificUrl        
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(url: fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
                                        // put data into the post objects
                                        var posts = [Post]()
            
                                        for datum in data {
                                            let post = Post()
                                            // ids
                                            let id = datum[Constants.ServerModelField_Post.id] as? NSNumber
                                            post?.id = id?.int64Value
//                                            let userId = datum[Constants.ServerModelField_Post.userId]![Constants.ServerModelField_User.id] as? NSNumber
//                                            post?.userId = userId?.longLongValue
                                            
                                            let userId = (datum[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                                            post?.userId = userId?.int64Value
                                            
                                            let username = (datum[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.username]! as? String
                                            post?.username = username

                                            let createTimeStr = datum[Constants.ServerModelField_Post.createdAt] as! String + "UTC"
                                            let createTime = self.FormatDate(createTimeStr)
                                            post?.createdAt = createTime
                                            let updateTimeStr = datum[Constants.ServerModelField_Post.updatedAt] as! String + "UTC"
                                            let updateTime = self.FormatDate(updateTimeStr)
                                            post?.updatedAt = updateTime
                                            //geo-coordinates
                                            let latStr = datum[Constants.ServerModelField_Post.currentLatitude] as? String
                                            post?.currentLatitude = Double(latStr!)
                                            let longStr = datum[Constants.ServerModelField_Post.currentLongitude] as? String
                                            post?.currentLongtitude = Double(longStr!)
                                            //other string type fields
                                            post?.activityTitle = datum[Constants.ServerModelField_Post.activityType] as? String
                                            post?.deviceToken = datum[Constants.ServerModelField_Post.deviceToken] as? String
                                            post?.deviceType = datum[Constants.ServerModelField_Post.deviceType] as? String
                                            post?.meetPlace = datum[Constants.ServerModelField_Post.meetLocation] as? String
                                            post?.detail = datum[Constants.ServerModelField_Post.detail] as? String
                                            post?.status = datum[Constants.ServerModelField_Post.status] as? String
                                            posts.append(post!)
                                        }
                                        // sort it
                                        posts.sort(by: { $0.updatedAt?.compare($1.updatedAt!) == ComparisonResult.orderedDescending})
                                        onSuccess(posts)
            }, onError: {(error, response) in
                onError(error)
            }
        )

    }
    
    func getMyActivity(_ user: User, onSuccess: @escaping (_ posts: [Post]) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        
        let idField = String(user.id!)
        let specificUrl = "posts/?user_profile=" + idField
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(url: fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var posts = [Post]()
            
            for datum in data {
                let post = Post()
                // ids
                let id = datum[Constants.ServerModelField_Post.id] as? NSNumber
                post?.id = id?.int64Value
                let userId = datum[Constants.ServerModelField_Post.userId] as? NSNumber
                post?.userId = userId?.int64Value
                //time stamps
                let createTimeStr = datum[Constants.ServerModelField_Post.createdAt] as! String + "UTC"
                let createTime = self.FormatDate(createTimeStr)
                post?.createdAt = createTime
                let updateTimeStr = datum[Constants.ServerModelField_Post.updatedAt] as! String + "UTC"
                let updateTime = self.FormatDate(updateTimeStr)
                post?.updatedAt = updateTime
                //geo-coordinates
                let latStr = datum[Constants.ServerModelField_Post.currentLatitude] as? String
                post?.currentLatitude = Double(latStr!)
                let longStr = datum[Constants.ServerModelField_Post.currentLongitude] as? String
                post?.currentLongtitude = Double(longStr!)
                //other string type fields
                post?.activityTitle = datum[Constants.ServerModelField_Post.activityType] as? String
                post?.deviceToken = datum[Constants.ServerModelField_Post.deviceToken] as? String
                post?.deviceType = datum[Constants.ServerModelField_Post.deviceType] as? String
                post?.meetPlace = datum[Constants.ServerModelField_Post.meetLocation] as? String
                post?.detail = datum[Constants.ServerModelField_Post.detail] as? String
                post?.status = datum[Constants.ServerModelField_Post.status] as? String
                posts.append(post!)
            }
            // sort it
            posts.sort(by: { $0.createdAt.compare($1.createdAt) == ComparisonResult.orderedDescending})
            onSuccess(posts)
            }, onError: {(error, response) in
                onError(error)
            }
        )
        
    }
    
    func getPostById(_ user: User, postId: Int64, onSuccess: @escaping (_ post: Post) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        
        let idField = String(postId)
        let specificUrl = "posts/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print(fullUrl)
        
        ApiManager.sharedInstance.GET_singleton(fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
//            print("get post return data:")
//            print(data)
            let post = Post()
            
            let id = data[Constants.ServerModelField_Post.id] as? NSNumber
            post!.id = id?.int64Value
            // user profile
            let userId = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
            post?.userId = userId?.int64Value
            let username = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.username]! as? String
            post?.username = username
            let fullName = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.fullname]! as? String
            post?.fullName = fullName
            let gender = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.gender]! as? String
            post?.postGender = gender
            let grade = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.grade]! as? String
            post?.postGrade = grade
            let department = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.department]! as? String
            post?.postDepartment = department
            let hobby = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.hobby]! as? String
            post?.postHobby = hobby
            let shareProfile = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.shareProfile]! as? Bool
            post?.postShareProfile = shareProfile
            let numOfPosts = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.numOfPosts]! as? Int
            post?.postNumOfPosts = numOfPosts
            
            // Decode profile image
            let base64Image = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.profilePhoto]! as? String
            if (base64Image != nil) {
                    let decodedImage = Data(base64Encoded: base64Image!, options: NSData.Base64DecodingOptions(rawValue: 0) )
                if (decodedImage != nil) {
                    post?.postPhoto = UIImage(data: decodedImage!)
                }
            }
            
            //time stamps
            let createTimeStr = data[Constants.ServerModelField_Post.createdAt] as! String + "UTC"
            let createTime = self.FormatDate(createTimeStr)
            post?.createdAt = createTime
            let updateTimeStr = data[Constants.ServerModelField_Post.updatedAt] as! String + "UTC"
            let updateTime = self.FormatDate(updateTimeStr)
            post?.updatedAt = updateTime
            //geo-coordinates
            let latStr = data[Constants.ServerModelField_Post.currentLatitude] as? String
            post?.currentLatitude = Double(latStr!)
            let longStr = data[Constants.ServerModelField_Post.currentLongitude] as? String
            post?.currentLongtitude = Double(longStr!)
            //other string type fields
            post?.activityTitle = data[Constants.ServerModelField_Post.activityType] as? String
            post?.deviceToken = data[Constants.ServerModelField_Post.deviceToken] as? String
            post?.deviceType = data[Constants.ServerModelField_Post.deviceType] as? String
            post?.meetPlace = data[Constants.ServerModelField_Post.meetLocation] as? String
            post?.detail = data[Constants.ServerModelField_Post.detail] as? String
            post?.status = data[Constants.ServerModelField_Post.status] as? String
            
            onSuccess(post!)
            }
            , onError: {(error, response) in
                onError(error)
        })
        
    }

    
    //MARK: Join Activities APIs
    func createJoinActivity(_ user: User, join: Join, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let specificUrl = "joins/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("join activity url: " + fullUrl)
//        print("user id:" + String(user.id!))
        
        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(value: user.id! as Int64), Constants.ServerModelField_User.username: user.username! as AnyObject]
        
        let joinData: [String: AnyObject] = [Constants.ServerModelField_Join.userId: userProfile as AnyObject, Constants.ServerModelField_Join.postId: NSNumber(value: join.postId! as Int64), Constants.ServerModelField_Join.deviceType: join.deviceType! as AnyObject, Constants.ServerModelField_Join.currentLatitude: join.currentLatitude! as AnyObject,Constants.ServerModelField_Join.currentLongitude: join.currentLongtitude! as AnyObject, Constants.ServerModelField_Join.status: join.status! as AnyObject]
//        print(joinData)
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: joinData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_Join.id]
            join.id = id?.int64Value
            
            onSuccess(user)
            }
            , onError: {(error, response) in
                onError(error)
        })
        
    }
    
    func confirmJoinActivity(_ user: User, join: Join, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let idField = String(join.id!)
        let specificUrl = "joins/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("join activity url: " + fullUrl)
//        print("user id:" + String(user.id!))
        print(join.status as Any)
        
        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(value: user.id! as Int64), Constants.ServerModelField_User.username: user.username! as AnyObject]
        
        let joinData: [String: AnyObject] = [Constants.ServerModelField_Join.userId: userProfile as AnyObject, Constants.ServerModelField_Join.postId: NSNumber(value: join.postId! as Int64), Constants.ServerModelField_Join.deviceType: join.deviceType! as AnyObject, Constants.ServerModelField_Join.currentLatitude: join.currentLatitude! as AnyObject,Constants.ServerModelField_Join.currentLongitude: join.currentLongtitude! as AnyObject, Constants.ServerModelField_Join.status: Constants.JoinStatus.confirm as AnyObject]

        
        ApiManager.sharedInstance.PUT(fullUrl, username: user.username!, password: user.password!, data: joinData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_Join.id]
            join.id = id?.int64Value
            
            onSuccess(user)
            }
            , onError: {(error, response) in
                onError(error)
        })
        
    }

    
    func getJoinById(_ user: User, post: Post, onSuccess: @escaping (_ joins: [Join]) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        
        let idField = String(post.id!)
        let specificUrl = "joins_by_post/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(url: fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var joins = [Join]()
            
            for datum in data {
                let join = Join()
                // ids
                let id = datum[Constants.ServerModelField_Join.id] as? NSNumber
                join?.id = id?.int64Value
                
                // user profile
                let userId = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                join?.userId = userId?.int64Value
                let username = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.username]! as? String
                join?.username = username
                let fullName = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.fullname]! as? String
                join?.fullName = fullName
                let gender = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.gender]! as? String
                join?.joinerGender = gender
                let grade = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.grade]! as? String
                join?.joinerGrade = grade
                let department = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.department]! as? String
                join?.joinerDepartment = department
                let hobby = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.hobby]! as? String
                join?.joinerHobby = hobby
                let shareProfile = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.shareProfile]! as? Bool
                join?.joinerShareProfile = shareProfile
                let numOfPosts = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.numOfPosts]! as? Int
                join?.joinerNumOfPosts = numOfPosts
                
                // post info
                let postId = datum[Constants.ServerModelField_Join.postId] as? NSNumber
                join?.postId = postId?.int64Value
                let postName = datum[Constants.ServerModelField_Join.postName] as? String
                join?.postName = postName
                
                //time stamps
                let createTimeStr = datum[Constants.ServerModelField_Join.createdAt] as! String + "UTC"
                let createTime = self.FormatDate(createTimeStr)
                join?.createdAt = createTime
                let updateTimeStr = datum[Constants.ServerModelField_Join.updatedAt] as! String + "UTC"
                let updateTime = self.FormatDate(updateTimeStr)
                join?.updatedAt = updateTime
                //geo-coordinates
                let latStr = datum[Constants.ServerModelField_Join.currentLatitude] as? String
                join?.currentLatitude = Double(latStr!)
                let longStr = datum[Constants.ServerModelField_Join.currentLongitude] as? String
                join?.currentLongtitude = Double(longStr!)
                //other string type fields
                join?.deviceType = datum[Constants.ServerModelField_Join.deviceType] as? String
                join?.status = datum[Constants.ServerModelField_Join.status] as? String
                joins.append(join!)
            }
            // sort it
            joins.sort(by: { $0.updatedAt?.compare($1.updatedAt!) == ComparisonResult.orderedDescending})
            onSuccess(joins)
            }, onError: {(error, response) in
                onError(error)
            }
        )
        
    }

    func getJoinByUser(_ user: User, onSuccess: @escaping (_ joins: [Join]) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        
        let idField = String(user.id!)
        let specificUrl = "joins/?user_profile=" + idField
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(url: fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var joins = [Join]()
            
            for datum in data {
                let join = Join()
                // ids
                let id = datum[Constants.ServerModelField_Join.id] as? NSNumber
                join?.id = id?.int64Value
                
                // user profile
                let userId = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                join?.userId = userId?.int64Value
                let username = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.username]! as? String
                join?.username = username
                let fullName = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.fullname]! as? String
                join?.fullName = fullName
                let gender = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.gender]! as? String
                join?.joinerGender = gender
                let grade = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.grade]! as? String
                join?.joinerGrade = grade
                let department = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.department]! as? String
                join?.joinerDepartment = department
                let hobby = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.hobby]! as? String
                join?.joinerHobby = hobby
                let shareProfile = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.shareProfile]! as? Bool
                join?.joinerShareProfile = shareProfile
                let numOfPosts = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.numOfPosts]! as? Int
                join?.joinerNumOfPosts = numOfPosts
                
                // post info
                let postId = datum[Constants.ServerModelField_Join.postId] as? NSNumber
                join?.postId = postId?.int64Value
                let postName = datum[Constants.ServerModelField_Join.postName] as? String
                join?.postName = postName
                
                //time stamps
                let createTimeStr = datum[Constants.ServerModelField_Join.createdAt] as! String + "UTC"
                let createTime = self.FormatDate(createTimeStr)
                join?.createdAt = createTime
                let updateTimeStr = datum[Constants.ServerModelField_Join.updatedAt] as! String + "UTC"
                let updateTime = self.FormatDate(updateTimeStr)
                join?.updatedAt = updateTime
                //geo-coordinates
                let latStr = datum[Constants.ServerModelField_Join.currentLatitude] as? String
                join?.currentLatitude = Double(latStr!)
                let longStr = datum[Constants.ServerModelField_Join.currentLongitude] as? String
                join?.currentLongtitude = Double(longStr!)
                //other string type fields
                join?.deviceType = datum[Constants.ServerModelField_Join.deviceType] as? String
                join?.status = datum[Constants.ServerModelField_Join.status] as? String
                joins.append(join!)
            }
            // sort it
            joins.sort(by: { $0.updatedAt?.compare($1.updatedAt!) == ComparisonResult.orderedDescending})
            onSuccess(joins)
            }, onError: {(error, response) in
                onError(error)
            }
        )
        
    }

    //MARK: Message API
    func createMessage(_ user: User, message: Message, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let specificUrl = "create_message/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("join activity url: " + fullUrl)
//        print("user id:" + String(user.id!))
        
        let senderProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(value: message.senderId! as Int64), Constants.ServerModelField_User.username: message.senderUsername! as AnyObject]
        
        let receiverProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(value: message.receiverId! as Int64), Constants.ServerModelField_User.username: message.receiverUsername! as AnyObject]
        
//        let messageData: [String: AnyObject] = [Constants.ServerModelField_Message.sender: senderProfile, Constants.ServerModelField_Message.receiver: receiverProfile, Constants.ServerModelField_Message.currentLatitude: message.currentLatitude!, Constants.ServerModelField_Message.currentLongitude: message.currentLongtitude!, Constants.ServerModelField_Message.content: message.content!]
        
        let messageData: [String: AnyObject] = [Constants.ServerModelField_Message.sender: senderProfile as AnyObject, Constants.ServerModelField_Message.receiver: receiverProfile as AnyObject, Constants.ServerModelField_Message.postId: NSNumber(value: message.postId! as Int64), Constants.ServerModelField_Message.currentLatitude: message.currentLatitude! as AnyObject, Constants.ServerModelField_Message.currentLongitude: message.currentLongtitude! as AnyObject, Constants.ServerModelField_Message.content: message.content! as AnyObject]
        
        
//        print(messageData)
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: messageData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_Message.id]
            message.id = id?.int64Value
            
            onSuccess(user)
            }
            , onError: {(error, response) in
                onError(error)
        })
    }

    func getMessageByPost(_ user: User, post: Post, onSuccess: @escaping (_ messages: [Message]) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        
        let idField = String(post.id!)
        let specificUrl = "message_by_post/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(url: fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var messages = [Message]()
            
            for datum in data {
                let message = Message()
                // ids
                let id = datum[Constants.ServerModelField_Message.id] as? NSNumber
                message?.id = id?.int64Value
                //sender profile
                let senderId = (datum[Constants.ServerModelField_Message.sender] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                message?.senderId = senderId?.int64Value
                let senderUsername = (datum[Constants.ServerModelField_Message.sender] as! NSDictionary)[Constants.ServerModelField_User.username]! as? String
                message?.senderUsername = senderUsername
                let senderFullname = (datum[Constants.ServerModelField_Message.sender] as! NSDictionary)[Constants.ServerModelField_User.fullname]! as? String
                message?.senderFullname = senderFullname
                //receiver profile
                let receiverId = (datum[Constants.ServerModelField_Message.receiver] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                message?.receiverId = receiverId?.int64Value
                let receiverUsername = (datum[Constants.ServerModelField_Message.receiver] as! NSDictionary)[Constants.ServerModelField_User.username]! as? String
                message?.receiverUsername = receiverUsername
                let receiverFullname = (datum[Constants.ServerModelField_Message.receiver] as! NSDictionary)[Constants.ServerModelField_User.fullname]! as? String
                message?.receiverFullname = receiverFullname
                
                let postId = datum[Constants.ServerModelField_Message.postId] as? NSNumber
                message?.postId = postId?.int64Value
                //time stamps
                let createTimeStr = datum[Constants.ServerModelField_Message.createdAt] as! String + "UTC"
                let createTime = self.FormatDate(createTimeStr)
                message?.createdAt = createTime

                //geo-coordinates
                let latStr = datum[Constants.ServerModelField_Message.currentLatitude] as? String
                message?.currentLatitude = Double(latStr!)
                let longStr = datum[Constants.ServerModelField_Message.currentLongitude] as? String
                message?.currentLongtitude = Double(longStr!)
                //other string type fields
                message?.content = datum[Constants.ServerModelField_Message.content] as? String
                messages.append(message!)
            }
            // sort it
            messages.sort(by: { $0.createdAt.compare($1.createdAt) == ComparisonResult.orderedDescending})
            onSuccess(messages)
            }, onError: {(error, response) in
                onError(error)
            }
        )
        
    }
    
    //MARK: Usage Log
    func usageLog(_ user:User, usageLog: UsageLog, onSuccess: @escaping (_ user: User) -> Void, onError: @escaping (_ error: NSError) -> Void) {
        let specificUrl = "usagelogs/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("create usage log url: " + fullUrl)
//        print("user id:" + String(user.id!))@escaping
//        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(longLong: user.id!), Constants.ServerModelField_User.username: user.username!]
        
        let usageData: [String: AnyObject] = [Constants.ServerModelField_UsageLog.userId: NSNumber(value: usageLog.userId! as Int64), Constants.ServerModelField_UsageLog.postId: NSNumber(value: usageLog.postId! as Int64), Constants.ServerModelField_UsageLog.code: usageLog.code! as AnyObject, Constants.ServerModelField_UsageLog.description: usageLog.description! as AnyObject, Constants.ServerModelField_UsageLog.currentLatitude: usageLog.currentLatitude! as AnyObject,Constants.ServerModelField_UsageLog.currentLongitude: usageLog.currentLongtitude! as AnyObject]
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: usageData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_UsageLog.id]
            usageLog.id = id?.int64Value
            
            onSuccess(user)
            }
            , onError: {(error, response) in
                onError(error)
        })
        
    }

    
    //MARK: Miscellaneous Formatting
    func FormatDate(_ dateString: String) -> Date {
        print("server time:" + dateString)
//        dateString = dateString + "UTC"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'zzz"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        print("NSDate:")
        print(dateFormatter.date(from: dateString)!)
        return dateFormatter.date(from: dateString)!
    }
    
    /**
     Encoded a string in base 64
     
     - Parameter toEncode: whatever it is you want to encode
     
     - Returns: the encoded string as an NSObject
     */
    func base64Encode(_ toEncode: String) -> String {
//        print("encoding \(toEncode)")
        let utf8Data = toEncode.data(using: String.Encoding.utf8)
        return utf8Data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }

    
}
