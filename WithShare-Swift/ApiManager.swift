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
                print("Get Body:" + responseData!)
                
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
                print("Body:" + responseData!)
                
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


    
    //MARK: User Profile Api
    func signUp(user: User, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "signup/"
        
        // Sign up with 1) psu email, 2) password, 3) phone number, 4) device type (iOS), 5) show profile setting and 6) number of posts (initialized as 0)
        let userPasswordDictionary: [String: AnyObject] = [Constants.ServerModelField_User.username: user.username!, Constants.ServerModelField_User.password: user.password!, Constants.ServerModelField_User.phoneNumber: user.phoneNumber!, Constants.ServerModelField_User.deviceType: user.deviceType!, Constants.ServerModelField_User.shareProfile: user.shareProfile!, Constants.ServerModelField_User.numOfPosts: user.numOfPosts!]
        
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
                print(data)
            let user = User(username: "",password: "",phoneNumber: "")
//                for datum in data {
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
//                }
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
        let activityData: [String: AnyObject] = [Constants.ServerModelField_Post.userId: NSNumber(longLong: user.id!), Constants.ServerModelField_Post.deviceType: post.deviceType!, Constants.ServerModelField_Post.activityType: post.activityTitle!, Constants.ServerModelField_Post.meetLocation: post.meetPlace!, Constants.ServerModelField_Post.detail: post.detail!, Constants.ServerModelField_Post.currentLatitude: post.currentLatitude!,Constants.ServerModelField_Post.currentLongitude: post.currentLongtitude!, Constants.ServerModelField_Post.status: post.status!]
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: activityData, onSuccess: {(data, response) in
                let id = data[Constants.ServerModelField_User.id] 
                post.id = id?.longLongValue

                onSuccess(user: user)
            }
            , onError: {(error, response) in
                onError(error: error)
        })
        
    }

    func getActivity(user: User, onSuccess: (posts: [Post]) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "posts/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        
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
                                            let createTimeStr = datum[Constants.ServerModelField_Post.createdAt] as! String
                                            let createTime = self.FormatDate(createTimeStr)
                                            post?.createdAt = createTime
                                            let updateTimeStr = datum[Constants.ServerModelField_Post.updatedAt] as! String
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
                let createTimeStr = datum[Constants.ServerModelField_Post.createdAt] as! String
                let createTime = self.FormatDate(createTimeStr)
                post?.createdAt = createTime
                let updateTimeStr = datum[Constants.ServerModelField_Post.updatedAt] as! String
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
    
    //MARK: Join Activities APIs
    func createJoinActivity(user: User, join: Join, onSuccess: (user: User) -> Void, onError: (error: NSError) -> Void) {
        let specificUrl = "joins/"
        
        let fullUrl = ApiManager.serverUrl + specificUrl
        print("join activity url: " + fullUrl)
        print("user id:" + String(user.id!))
        let joinData: [String: AnyObject] = [Constants.ServerModelField_Join.userId: NSNumber(longLong: join.userId!), Constants.ServerModelField_Join.postId: NSNumber(longLong: join.postId!), Constants.ServerModelField_Join.deviceType: join.deviceType!, Constants.ServerModelField_Post.currentLatitude: join.currentLatitude!,Constants.ServerModelField_Post.currentLongitude: join.currentLongtitude!]
        
        ApiManager.sharedInstance.POST(fullUrl, username: user.username!, password: user.password!, data: joinData, onSuccess: {(data, response) in
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
        
        ApiManager.sharedInstance.GET(fullUrl, username: user.username!, password: user.password!, onSuccess: {(data, response) in
            // put data into the post objects
            var joins = [Join]()
            
            for datum in data {
                let join = Join()
                // ids
                let id = datum[Constants.ServerModelField_Join.id] as? NSNumber
                join?.id = id?.longLongValue
                let userId = datum[Constants.ServerModelField_Join.userId] as? NSNumber
                join?.userId = userId?.longLongValue
                let postId = datum[Constants.ServerModelField_Join.postId] as? NSNumber
                join?.postId = postId?.longLongValue
                //time stamps
                let createTimeStr = datum[Constants.ServerModelField_Join.createdAt] as! String
                let createTime = self.FormatDate(createTimeStr)
                join?.createdAt = createTime
                let updateTimeStr = datum[Constants.ServerModelField_Join.updatedAt] as! String
                let updateTime = self.FormatDate(updateTimeStr)
                join?.updatedAt = updateTime
                //geo-coordinates
                let latStr = datum[Constants.ServerModelField_Join.currentLatitude] as? String
                join?.currentLatitude = Double(latStr!)
                let longStr = datum[Constants.ServerModelField_Join.currentLongitude] as? String
                join?.currentLongtitude = Double(longStr!)
                //other string type fields
                join?.deviceType = datum[Constants.ServerModelField_Join.deviceType] as? String
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
                let userId = datum[Constants.ServerModelField_Join.userId] as? NSNumber
                join?.userId = userId?.longLongValue
                let postId = datum[Constants.ServerModelField_Join.postId] as? NSNumber
                join?.postId = postId?.longLongValue
                //time stamps
                let createTimeStr = datum[Constants.ServerModelField_Join.createdAt] as! String
                let createTime = self.FormatDate(createTimeStr)
                join?.createdAt = createTime
                let updateTimeStr = datum[Constants.ServerModelField_Join.updatedAt] as! String
                let updateTime = self.FormatDate(updateTimeStr)
                join?.updatedAt = updateTime
                //geo-coordinates
                let latStr = datum[Constants.ServerModelField_Join.currentLatitude] as? String
                join?.currentLatitude = Double(latStr!)
                let longStr = datum[Constants.ServerModelField_Join.currentLongitude] as? String
                join?.currentLongtitude = Double(longStr!)
                //other string type fields
                join?.deviceType = datum[Constants.ServerModelField_Join.deviceType] as? String
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


    
    //MARK: Miscellaneous Formatting
    func FormatDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
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