//
//  ApiManager.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/21/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation
import UIKit

class ApiManager: NSObject, NSURLSessionDelegate {
    // this is the singleton that you use to access use the API
    static let sharedInstance = ApiManager()
    
    // server url
    static let serverUrl = "https://withshare.ist.psu.edu/"
    let cache = NSCache()
    
    // MARK: HTTP GET and POST
    /**
     The GET call to the backend
     
     - Parameter url: What you want to call, in our case this also has all of the data as parameters to the url
     - Parameter onSuccess: What you want to call in the case it succeeds
     - Parameter onFail: Void - callback function when failed
     */
    func GET(url: String, username: String, password: String, onSuccess: (data: NSArray, response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Basic Authentication with (username + password)
        let userPasswordString = NSString(format: "%@:%@", username, password)
        print(userPasswordString)
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions([])
        request.addValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        // returns a singleton session based on default configuration
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            var jsonData: NSArray = []
            
            if data != nil {
                let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
//                print("Get Body:" + responseData!)
                
                do {
                    jsonData = try (NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSArray)!
                }
                catch _ {
                    onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), response: NSURLResponse())
                }
                    
            } else {
                onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["No data": NSObject()]), response: NSURLResponse())
            }
            
            if error != nil {
                onError(error: error!, response: NSURLResponse())
            } else {
                onSuccess(data: jsonData, response: response!)
            }
        })
        
        task.resume()
    }
    
    func GET_singleton(url: String, username: String, password: String, onSuccess: (data: [String: AnyObject], response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Basic Authentication with (username + password)
        let userPasswordString = NSString(format: "%@:%@", username, password)
        print(userPasswordString)
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions([])
        request.addValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        // returns a singleton session based on default configuration
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? NSHTTPURLResponse)?.statusCode)
            if data != nil {
                let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
//                print("Body:" + responseData!)
                
                do {
                    dataDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                } catch _ {
                    print("Serialization error")
                    onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), response: NSURLResponse())
                }
                
            }
            else {
                print("Body null")
            }
            
            if error != nil {
                onError(error: error!, response: NSURLResponse())
            } else {
                onSuccess(data: dataDict, response: response!)
            }
        })
        
        task.resume()
    }

    
    // HTTP POST with Basic Authentication (username + password)
    func POST(url: String, username: String, password: String, data: Dictionary<String,AnyObject>, onSuccess: (databack: [String: AnyObject], response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Basic Authentication with (username + password)
        let userPasswordString = NSString(format: "%@:%@", username, password)
        print(userPasswordString)
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions([])
        request.addValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions())
        } catch _ {
            onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON request data": NSObject()]), response: NSURLResponse())
            return
        }
        
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? NSHTTPURLResponse)?.statusCode)
            if data != nil {
                let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
                print("Body:" + responseData!)
                
                do {
                    dataDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                } catch _ {
                    onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), response: NSURLResponse())
                }

            }
            else {
                print("Body null")
            }
            
            if (response as? NSHTTPURLResponse)?.statusCode != 201 {
                onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Server returned error": NSObject()]), response: NSURLResponse())
                return
            }
            
            if error != nil {
                onError(error: error!, response: NSURLResponse())
            } else {
                onSuccess(databack: dataDict, response: response!)
            }
        })
        
        task.resume()
    }
    
    // HTTP POST with No Authentication
    func POST_simple(url: String, data: Dictionary<String,AnyObject>, onSuccess: (databack: [String: AnyObject], response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
        
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
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? NSHTTPURLResponse)?.statusCode)
            if data != nil {
                let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
                print("Body:" + responseData!)
                
                do {
                    dataDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                } catch _ {
                    onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), response: NSURLResponse())
                }
                
            }
            else {
                print("Body null")
            }
            
            if (response as? NSHTTPURLResponse)?.statusCode != 201 {
                onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Server returned error": NSObject()]), response: NSURLResponse())
                return
            }
            
            if error != nil {
                onError(error: error!, response: NSURLResponse())
            } else {
                onSuccess(databack: dataDict, response: response!)
            }
        })
        
        task.resume()
    }
    
    // HTTP PUT with Basic Authentication (username + password)
    func PUT(url: String, username: String, password: String, data: Dictionary<String,AnyObject>, onSuccess: (databack: [String: AnyObject], response: NSURLResponse) -> Void, onError: (error: NSError, response: NSURLResponse) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Basic Authentication with (username + password)
        let userPasswordString = NSString(format: "%@:%@", username, password)
        print(userPasswordString)
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions([])
        request.addValue("Basic \(base64EncodedCredential)", forHTTPHeaderField: "Authorization")
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions())
        } catch _ {
            onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON request data": NSObject()]), response: NSURLResponse())
            return
        }
        
        // returns a singleton session based on default configuration
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            var dataDict: [String: AnyObject] = [:]
            
            print((response as? NSHTTPURLResponse)?.statusCode)
            if data != nil {
                let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
                print("Body:" + responseData!)
                
                do {
                    dataDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                } catch _ {
                    onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Unable to parse JSON return data": NSObject()]), response: NSURLResponse())
                }
                
            }
            else {
                print("Body null")
            }
            
            if ((response as? NSHTTPURLResponse)?.statusCode != 201 && (response as? NSHTTPURLResponse)?.statusCode != 200) {
                onError(error: NSError(domain: "WithShare", code: -1000, userInfo: ["Server returned error": NSObject()]), response: NSURLResponse())
                return
            }
            
            if error != nil {
                onError(error: error!, response: NSURLResponse())
            } else {
                onSuccess(databack: dataDict, response: response!)
            }
        })
        
        task.resume()
    }
    
    //MARK: User Profile Api
    func signUp(user: User, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "signup/"
        
        // Sign up with 1) psu email, 2) password, 3) phone number, 4) device type (iOS), 5) show profile setting and 6) number of posts (initialized as 0)
        
        let imageData:NSData = UIImagePNGRepresentation((user.profilePhoto)!)!
        let strBase64:String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        
        let userPasswordDictionary: [String: AnyObject] = [Constants.ServerModelField_User.username: user.username!, Constants.ServerModelField_User.password: user.password!, Constants.ServerModelField_User.phoneNumber: user.phoneNumber!, Constants.ServerModelField_User.deviceType: user.deviceType!, Constants.ServerModelField_User.deviceToken: user.deviceToken!, Constants.ServerModelField_User.shareProfile: user.shareProfile!, Constants.ServerModelField_User.numOfPosts: user.numOfPosts!, Constants.ServerModelField_User.profilePhoto: strBase64]
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("signup url: " + fullUrl)
        
        // make the call
        ApiManager.sharedInstance.POST_simple(fullUrl, data: userPasswordDictionary, onSuccess: {(data, response) in
            print("signup return data:")
            print(data)
            let id = data[Constants.ServerModelField_User.id]
            user.id = id?.longLongValue
                onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
    }

    func editProfile(user: User, profileData: Dictionary<String,AnyObject>, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "edit_profile/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("edit profile url: " + fullUrl)
        
        ApiManager.sharedInstance.PUT(fullUrl, username: user.username!, password: user.password!, data: profileData, onSuccess: {(response) in
            onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
        
    }
    
    func getProfile(currentUser: User, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let idField = String(currentUser.id!)
        let specificUrl = "userprofiles/" + idField + "/"
        print(specificUrl)
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        ApiManager.sharedInstance.GET_singleton(fullUrl, username: currentUser.username!, password: currentUser.password!, onSuccess: {(data, response) in
                print("get profile return data:")
//                print(data)
                let user = User(username: "",password: "")
                let id = data[Constants.ServerModelField_User.id] as? NSNumber
                user!.id = id?.longLongValue
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
                        
                        let decodedImage = NSData(base64EncodedString: base64Image!, options: NSDataBase64DecodingOptions(rawValue: 0) )
                    
                        user?.profilePhoto = UIImage(data: decodedImage!)
                    }

                }
                onSuccess(user: user!)
            }
            , onError: {(error, response) in
                onError(error: error)
        })

    }
    
    //MARK: Post Activities APIs
    func createActivity(user: User, post: Post, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "posts/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("create activity url: " + fullUrl)
        print("user id:" + String(user.id!))
        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(longLong: user.id!), Constants.ServerModelField_User.username: user.username!]
        let activityData: [String: AnyObject] = [Constants.ServerModelField_Post.userId: userProfile, Constants.ServerModelField_Post.deviceType: post.deviceType!, Constants.ServerModelField_Post.deviceToken: post.deviceToken!, Constants.ServerModelField_Post.activityType: post.activityTitle!, Constants.ServerModelField_Post.meetLocation: post.meetPlace!, Constants.ServerModelField_Post.detail: post.detail!, Constants.ServerModelField_Post.currentLatitude: post.currentLatitude!,Constants.ServerModelField_Post.currentLongitude: post.currentLongtitude!, Constants.ServerModelField_Post.status: post.status!]
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: activityData, onSuccess: {(data, response) in
                let id = data[Constants.ServerModelField_User.id] 
                post.id = id?.longLongValue

                onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
        
    }
    
    func editActivity(user: User, post: Post, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let idField = String(post.id!)
        let specificUrl = "posts/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("create activity url: " + fullUrl)
        print("user id:" + String(user.id!))
        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(longLong: user.id!), Constants.ServerModelField_User.username: user.username!]
        let activityData: [String: AnyObject] = [Constants.ServerModelField_Post.userId: userProfile, Constants.ServerModelField_Post.deviceType: post.deviceType!, Constants.ServerModelField_Post.deviceToken: post.deviceToken!, Constants.ServerModelField_Post.activityType: post.activityTitle!, Constants.ServerModelField_Post.meetLocation: post.meetPlace!, Constants.ServerModelField_Post.detail: post.detail!, Constants.ServerModelField_Post.currentLatitude: post.currentLatitude!,Constants.ServerModelField_Post.currentLongitude: post.currentLongtitude!, Constants.ServerModelField_Post.status: post.status!]
        
        ApiManager.sharedInstance.PUT(fullUrl, username: user.username!, password: user.password!, data: activityData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_User.id]
            post.id = id?.longLongValue
            
            onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
        
    }


    func getActivity(user: User, onSuccess: (posts: [Post]) -> Void, onError: (error: NSError) -> Void) {
        // get yesterday
        let yesterDayDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])
        // Format time
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let dateString = dateFormatter.stringFromDate(yesterDayDate!)
        
        // Construct API URL
        let specificUrl = "posts/?created_at_gt=" + dateString
        let fullUrl = ApiManager.serverUrl + specificUrl        
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
                                        // put data into the post objects
                                        var posts = [Post]()
            
                                        for datum in data {
                                            let post = Post()
                                            // ids
                                            let id = datum[Constants.ServerModelField_Post.id] as? NSNumber
                                            post?.id = id?.longLongValue
//                                            let userId = datum[Constants.ServerModelField_Post.userId]![Constants.ServerModelField_User.id] as? NSNumber
//                                            post?.userId = userId?.longLongValue
                                            
                                            let userId = (datum[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                                            post?.userId = userId?.longLongValue
                                            
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
                                        posts.sortInPlace({ $0.updatedAt?.compare($1.updatedAt!) == NSComparisonResult.OrderedDescending})
                                        onSuccess(posts: posts)
            }, onError: {(error, response) in
                onError(error: error)
            }
        )

    }
    
    func getMyActivity(user: User, onSuccess: (posts: [Post]) -> Void, onError: (error: NSError) -> Void) {
        
        let idField = String(user.id!)
        let specificUrl = "posts/?user_profile=" + idField
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var posts = [Post]()
            
            for datum in data {
                let post = Post()
                // ids
                let id = datum[Constants.ServerModelField_Post.id] as? NSNumber
                post?.id = id?.longLongValue
                let userId = datum[Constants.ServerModelField_Post.userId] as? NSNumber
                post?.userId = userId?.longLongValue
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
            posts.sortInPlace({ $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedDescending})
            onSuccess(posts: posts)
            }, onError: {(error, response) in
                onError(error: error)
            }
        )
        
    }
    
    func getPostById(user: User, postId: Int64, onSuccess: (post: Post) -> Void, onError: (error: NSError) -> Void) {
        
        let idField = String(postId)
        let specificUrl = "posts/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print(fullUrl)
        
        ApiManager.sharedInstance.GET_singleton(fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            print("get post return data:")
            print(data)
            let post = Post()
            
            let id = data[Constants.ServerModelField_Post.id] as? NSNumber
            post!.id = id?.longLongValue
            // user profile
            let userId = (data[Constants.ServerModelField_Post.userId] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
            post?.userId = userId?.longLongValue
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
                    let decodedImage = NSData(base64EncodedString: base64Image!, options: NSDataBase64DecodingOptions(rawValue: 0) )
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
            
            onSuccess(post: post!)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
        
    }

    
    //MARK: Join Activities APIs
    func createJoinActivity(user: User, join: Join, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "joins/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("join activity url: " + fullUrl)
        print("user id:" + String(user.id!))
        
        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(longLong: user.id!), Constants.ServerModelField_User.username: user.username!]
        
        let joinData: [String: AnyObject] = [Constants.ServerModelField_Join.userId: userProfile, Constants.ServerModelField_Join.postId: NSNumber(longLong: join.postId!), Constants.ServerModelField_Join.deviceType: join.deviceType!, Constants.ServerModelField_Join.currentLatitude: join.currentLatitude!,Constants.ServerModelField_Join.currentLongitude: join.currentLongtitude!, Constants.ServerModelField_Join.status: join.status!]
        print(joinData)
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: joinData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_Join.id]
            join.id = id?.longLongValue
            
            onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
        
    }
    
    func confirmJoinActivity(user: User, join: Join, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let idField = String(join.id!)
        let specificUrl = "joins/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("join activity url: " + fullUrl)
        print("user id:" + String(user.id!))
        print(join.status)
        
        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(longLong: user.id!), Constants.ServerModelField_User.username: user.username!]
        
        let joinData: [String: AnyObject] = [Constants.ServerModelField_Join.userId: userProfile, Constants.ServerModelField_Join.postId: NSNumber(longLong: join.postId!), Constants.ServerModelField_Join.deviceType: join.deviceType!, Constants.ServerModelField_Join.currentLatitude: join.currentLatitude!,Constants.ServerModelField_Join.currentLongitude: join.currentLongtitude!, Constants.ServerModelField_Join.status: Constants.JoinStatus.confirm]

        
        ApiManager.sharedInstance.PUT(fullUrl, username: user.username!, password: user.password!, data: joinData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_Join.id]
            join.id = id?.longLongValue
            
            onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
        
    }

    
    func getJoinById(user: User, post: Post, onSuccess: (joins: [Join]) -> Void, onError: (error: NSError) -> Void) {
        
        let idField = String(post.id!)
        let specificUrl = "joins_by_post/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var joins = [Join]()
            
            for datum in data {
                let join = Join()
                // ids
                let id = datum[Constants.ServerModelField_Join.id] as? NSNumber
                join?.id = id?.longLongValue
                
                // user profile
                let userId = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                join?.userId = userId?.longLongValue
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
                join?.postId = postId?.longLongValue
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
            joins.sortInPlace({ $0.updatedAt?.compare($1.updatedAt!) == NSComparisonResult.OrderedDescending})
            onSuccess(joins: joins)
            }, onError: {(error, response) in
                onError(error: error)
            }
        )
        
    }

    func getJoinByUser(user: User, onSuccess: (joins: [Join]) -> Void, onError: (error: NSError) -> Void) {
        
        let idField = String(user.id!)
        let specificUrl = "joins/?user_profile=" + idField
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var joins = [Join]()
            
            for datum in data {
                let join = Join()
                // ids
                let id = datum[Constants.ServerModelField_Join.id] as? NSNumber
                join?.id = id?.longLongValue
                
                // user profile
                let userId = (datum[Constants.ServerModelField_Join.userId] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                join?.userId = userId?.longLongValue
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
                join?.postId = postId?.longLongValue
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
            joins.sortInPlace({ $0.updatedAt?.compare($1.updatedAt!) == NSComparisonResult.OrderedDescending})
            onSuccess(joins: joins)
            }, onError: {(error, response) in
                onError(error: error)
            }
        )
        
    }

    //MARK: Message API
    func createMessage(user: User, message: Message, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "create_message/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("join activity url: " + fullUrl)
        print("user id:" + String(user.id!))
        
        let senderProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(longLong: message.senderId!), Constants.ServerModelField_User.username: message.senderUsername!]
        
        let receiverProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(longLong: message.receiverId!), Constants.ServerModelField_User.username: message.receiverUsername!]
        
//        let messageData: [String: AnyObject] = [Constants.ServerModelField_Message.sender: senderProfile, Constants.ServerModelField_Message.receiver: receiverProfile, Constants.ServerModelField_Message.currentLatitude: message.currentLatitude!, Constants.ServerModelField_Message.currentLongitude: message.currentLongtitude!, Constants.ServerModelField_Message.content: message.content!]
        
        let messageData: [String: AnyObject] = [Constants.ServerModelField_Message.sender: senderProfile, Constants.ServerModelField_Message.receiver: receiverProfile, Constants.ServerModelField_Message.postId: NSNumber(longLong: message.postId!), Constants.ServerModelField_Message.currentLatitude: message.currentLatitude!, Constants.ServerModelField_Message.currentLongitude: message.currentLongtitude!, Constants.ServerModelField_Message.content: message.content!]
        
        
        print(messageData)
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: messageData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_Message.id]
            message.id = id?.longLongValue
            
            onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
    }

    func getMessageByPost(user: User, post: Post, onSuccess: (messages: [Message]) -> Void, onError: (error: NSError) -> Void) {
        
        let idField = String(post.id!)
        let specificUrl = "message_by_post/" + idField + "/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print(fullUrl)
        
        ApiManager.sharedInstance.GET(fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var messages = [Message]()
            
            for datum in data {
                let message = Message()
                // ids
                let id = datum[Constants.ServerModelField_Message.id] as? NSNumber
                message?.id = id?.longLongValue
                //sender profile
                let senderId = (datum[Constants.ServerModelField_Message.sender] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                message?.senderId = senderId?.longLongValue
                let senderUsername = (datum[Constants.ServerModelField_Message.sender] as! NSDictionary)[Constants.ServerModelField_User.username]! as? String
                message?.senderUsername = senderUsername
                let senderFullname = (datum[Constants.ServerModelField_Message.sender] as! NSDictionary)[Constants.ServerModelField_User.fullname]! as? String
                message?.senderFullname = senderFullname
                //receiver profile
                let receiverId = (datum[Constants.ServerModelField_Message.receiver] as! NSDictionary)[Constants.ServerModelField_User.id]! as? NSNumber
                message?.receiverId = receiverId?.longLongValue
                let receiverUsername = (datum[Constants.ServerModelField_Message.receiver] as! NSDictionary)[Constants.ServerModelField_User.username]! as? String
                message?.receiverUsername = receiverUsername
                let receiverFullname = (datum[Constants.ServerModelField_Message.receiver] as! NSDictionary)[Constants.ServerModelField_User.fullname]! as? String
                message?.receiverFullname = receiverFullname
                
                let postId = datum[Constants.ServerModelField_Message.postId] as? NSNumber
                message?.postId = postId?.longLongValue
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
            messages.sortInPlace({ $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedDescending})
            onSuccess(messages: messages)
            }, onError: {(error, response) in
                onError(error: error)
            }
        )
        
    }
    
    //MARK: Usage Log
    func usageLog(user:User, usageLog: UsageLog, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "usagelogs/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("create usage log url: " + fullUrl)
//        print("user id:" + String(user.id!))
//        let userProfile: [String: AnyObject] = [Constants.ServerModelField_User.id: NSNumber(longLong: user.id!), Constants.ServerModelField_User.username: user.username!]
        
        let usageData: [String: AnyObject] = [Constants.ServerModelField_UsageLog.userId: NSNumber(longLong: usageLog.userId!), Constants.ServerModelField_UsageLog.postId: NSNumber(longLong: usageLog.postId!), Constants.ServerModelField_UsageLog.code: usageLog.code!, Constants.ServerModelField_UsageLog.description: usageLog.description!, Constants.ServerModelField_UsageLog.currentLatitude: usageLog.currentLatitude!,Constants.ServerModelField_UsageLog.currentLongitude: usageLog.currentLongtitude!]
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: usageData, onSuccess: {(data, response) in
            let id = data[Constants.ServerModelField_UsageLog.id]
            usageLog.id = id?.longLongValue
            
            onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
        
    }

    
    //MARK: Miscellaneous Formatting
    func FormatDate(dateString: String) -> NSDate {
        print("server time:" + dateString)
//        dateString = dateString + "UTC"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'zzz"
        dateFormatter.timeZone = NSTimeZone()
        print("NSDate:")
        print(dateFormatter.dateFromString(dateString)!)
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