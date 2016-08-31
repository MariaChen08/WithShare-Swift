//
//  DetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var meetPlaceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var hobbyLabel: UILabel!
    @IBOutlet weak var numOfPostLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    @IBOutlet weak var sendMessageLabel: UILabel!
    @IBOutlet weak var joinButton: UIBarButtonItem!
    @IBOutlet weak var messageTextField: UITextField!
    
    var post: Post?
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    var senderId: Int64?
    var senderUsername: String?
    var receiverId: Int64?
    var receiverUsername: String?
    
    let locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient?
    var placePicker : GMSPlacePicker?
    var currentCoordinates:CLLocationCoordinate2D?
    //default location to IST, PSU
    var center = CLLocationCoordinate2DMake(40.793958335519726, -77.867923433207636)
    
    var join: Join?
    var message: Message?
    var messageContent: String?
    
    var indexPostion: Int?
    var usageLog: UsageLog?
    
    override func viewDidLoad() {
        // Initial blank page
        fullNameLabel.text = ""
        gradeLabel.text = ""
        departmentLabel.text = ""
        numOfPostLabel.text = ""
        activityTitleLabel.text = ""
        meetPlaceLabel.text = ""
        detailLabel.text = ""
        
        activityTitleLabel.font = UIFont.boldSystemFontOfSize(18.0)
        
        //Handle the text field’s user input through delegate callbacks.
        messageTextField.delegate = self
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        
        
        //Google Map
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //Google Place APIs
        placesClient = GMSPlacesClient.sharedClient()
        
        if let post = post {
            activityTitleLabel.text = post.activityTitle!
            meetPlaceLabel.text = "meet@ " + post.meetPlace!
            if (post.detail?.isEmpty == false) {
                detailLabel.text = "detail: " + post.detail!
            }
            else {
                detailLabel.text = post.detail!
            }
            
            // Retrieve cached user info
            let defaults = NSUserDefaults.standardUserDefaults()
            username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
            senderUsername = username
            password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
            currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
            user = User(username: username!, password: password!)
            user?.phoneNumber = phoneNumber
            
            user?.id = post.userId
            self.loadPostData()
            
            usageLog = UsageLog()
            usageLog?.userId = currentUserId
            usageLog?.postId = post.id
            usageLog?.code = "indexPath: " + String(indexPostion)
            usageLog?.description = "view activity detail"
            
            if (currentCoordinates != nil) {
                usageLog?.currentLatitude = currentCoordinates!.latitude
                usageLog?.currentLatitude = (usageLog?.currentLatitude)?.roundFiveDigits()
                usageLog?.currentLongtitude = currentCoordinates!.longitude
                usageLog?.currentLongtitude = (usageLog?.currentLongtitude)?.roundFiveDigits()
            }
            else {
                usageLog?.currentLatitude = 0
                usageLog?.currentLongtitude = 0
            }
            usageLog?.postId = post.id
            self.createUsageLog()

        }
        
       
        
        
    }

    //MARK: load detail data
    func loadPostData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(user!, onSuccess: {(user) in
            print("get profile success")
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("get profile success")
                self.receiverId = user.id
                self.receiverUsername = user.username
                
                if (user.gender == Constants.Gender.female) {
                    self.sendMessageLabel.text = "Send her a message:"
                }
                else if (user.gender == Constants.Gender.male) {
                    self.sendMessageLabel.text = "Send him a message:"
                }
                else {
                    self.sendMessageLabel.text = "Send a message:"
                }
                
                if (user.fullName != nil && user.fullName != Constants.blankSign) {
                    self.fullNameLabel.text = user.fullName
                }
                else {
                    self.fullNameLabel.text = ""
                }
                if (user.grade != nil && user.grade != Constants.blankSign) {
                    self.gradeLabel.text = user.grade
                }
                else {
                    self.gradeLabel.text = ""
                }
                if (user.department != nil && user.department != Constants.blankSign) {
                    self.departmentLabel.text = user.department
                }
                else {
                    self.departmentLabel.text = ""
                }
                if (user.hobby != nil && user.hobby != Constants.blankSign) {
                    self.hobbyLabel.text = user.hobby
                }
                else {
                    self.hobbyLabel.text = ""
                }
                self.numOfPostLabel.text = String(user.numOfPosts!) + " posts"
                
                if (user.profilePhoto != nil) {
                    self.profileImage.image = user.profilePhoto
                }
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("load profile error!")
                    let alert = UIAlertController(title: "Unable to load profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
    //MARK: Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Join activity
        if joinButton === sender {
            join = Join()
            if (currentCoordinates != nil) {
                join?.currentLatitude = currentCoordinates!.latitude
                join?.currentLatitude = (join?.currentLatitude)?.roundFiveDigits()
                join?.currentLongtitude = currentCoordinates!.longitude
                join?.currentLongtitude = (join?.currentLongtitude)?.roundFiveDigits()
            }
            else {
                join?.currentLatitude = 0
                join?.currentLongtitude = 0
            }
            join?.userId = currentUserId
            join?.postId = post?.id
            join?.status = Constants.JoinStatus.confirm
            
            // Upload to server
            self.createJoin()
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        messageContent = textField.text
        if messageContent != nil {
            messageContent = messageContent!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
    }
    
    
    //MARK: Actions
    @IBAction func sendMessage(sender: AnyObject) {
        message = Message()
        if (currentCoordinates != nil) {
            message?.currentLatitude = currentCoordinates!.latitude
            message?.currentLatitude = (message?.currentLatitude)?.roundFiveDigits()
            message?.currentLongtitude = currentCoordinates!.longitude
            message?.currentLongtitude = (message?.currentLongtitude)?.roundFiveDigits()
        }
        else {
            message?.currentLatitude = 0
            message?.currentLongtitude = 0
        }
        message?.senderId = currentUserId
        message?.senderUsername = senderUsername
        message?.receiverId = receiverId
        message?.receiverUsername = receiverUsername
        
        message?.postId = post?.id
        
        if (messageContent == nil)
        {
            messageContent = ""
        }
        message?.content = messageContent
        
        print("postid: ")
        print(self.message?.postId)
        print("senderid: ")
        print(self.message?.senderId)
        print("sender email: " + (self.message?.senderUsername)!)
        print("receiverid: ")
        print(self.message?.receiverId)
        print("receiver email: " + (self.message?.receiverUsername)!)
        
        join = Join()
        if (currentCoordinates != nil) {
            join?.currentLatitude = currentCoordinates!.latitude
            join?.currentLatitude = (join?.currentLatitude)?.roundFiveDigits()
            join?.currentLongtitude = currentCoordinates!.longitude
            join?.currentLongtitude = (join?.currentLongtitude)?.roundFiveDigits()
        }
        else {
            join?.currentLatitude = 0
            join?.currentLongtitude = 0
        }
        join?.userId = currentUserId
        join?.postId = post?.id

        
        // Upload to server
        ApiManager.sharedInstance.createMessage(user!, message: message!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("create new message success!")
                
                let alert = UIAlertController(title: "Message sent!", message:
                    "Do you confirm to join the activity? Or just interested at the moment?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Yes, join", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    self.join?.status = Constants.JoinStatus.confirm
                    self.createJoin()
                    }))
                alert.addAction(UIAlertAction(title: "No, just interested", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    self.join?.status = Constants.JoinStatus.interested
                    self.createJoin()
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("create new message error!")
                    let alert = UIAlertController(title: "Unable to send!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
    // MARK: confirm join or just interested
    func createJoin() {
        // Upload to server
        ApiManager.sharedInstance.createJoinActivity(self.user!, join: self.join!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("create new activity success!")
                print("joinid: ")
                print(self.join!.id)
                self.performSegueWithIdentifier("joinActivityExit", sender: self)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("join activity error!")
                    let alert = UIAlertController(title: "Unable to join activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
    func createUsageLog() {
        // Upload to server
        ApiManager.sharedInstance.usageLog(self.user!, usageLog: self.usageLog!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("create new usage log success!")
                print("usageLogid: ")
                print(self.usageLog!.id)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("cannot create usage log error!")
                }
        })
        
    }

}

// MARK: - CLLocationManagerDelegate
extension DetailViewController: CLLocationManagerDelegate {
    // called when the user grants or revokes location permissions
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // verify the user has granted you permission while the app is in use
        if status == .AuthorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
//            mapView.myLocationEnabled = true
//            mapView.settings.myLocationButton = true
        }
    }
    
    // executes when the location manager receives new location data.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
//            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            print("coordinate: \(location.coordinate)")
            currentCoordinates = location.coordinate
            locationManager.stopUpdatingLocation()
        }
        
    }
}

