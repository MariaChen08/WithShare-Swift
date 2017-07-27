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
    @IBOutlet weak var meetPlaceLabel: UITextView!
    @IBOutlet weak var detailLabel: UITextView!
    
    @IBOutlet weak var fullNameButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    
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
        fullNameButton.setTitle(">", for: UIControlState.normal)
        activityTitleLabel.text = ""
        meetPlaceLabel.text = ""
        detailLabel.text = ""
        
        activityTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        //Google Map
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //Google Place APIs
        placesClient = GMSPlacesClient.shared()
        
        if let post = post {
            activityTitleLabel.text = post.activityTitle!
            meetPlaceLabel.text = post.meetPlace!
            if (post.detail?.isEmpty == false) {
                detailLabel.text = "detail: " + post.detail!
            }
            else {
                detailLabel.text = "No other info specified about the activity. Join and chat with the initiator about more details."
            }
            
            // Retrieve cached user info
            let defaults = UserDefaults.standard
            username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
            senderUsername = username
            password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
            currentUserId = (defaults.object(forKey: Constants.NSUserDefaultsKey.id) as AnyObject).int64Value
            user = User(username: username!, password: password!)
            user?.phoneNumber = phoneNumber
            
            user?.id = post.userId
            self.loadPostData()
            
            usageLog = UsageLog()
            usageLog?.userId = currentUserId
            usageLog?.postId = post.id
            usageLog?.code = "indexPath: " + String(describing: indexPostion)
            usageLog?.description = "view activity detail"
            usageLog?.currentLatitude = 0
            usageLog?.currentLongtitude = 0
            usageLog?.postId = post.id
            self.createUsageLog()

        }
    }

    //MARK: load detail data
    func loadPostData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(user!, onSuccess: {(user) in
            print("get profile success")
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("get profile success")
                self.receiverId = user.id
                self.receiverUsername = user.username
                
                if (user.fullName != nil && user.fullName != Constants.blankSign) {
                    self.fullNameButton.setTitle(user.fullName! + " >", for: UIControlState.normal)
                }
                
                if (user.profilePhoto != nil) {
                    self.profileImage.image = user.profilePhoto
                }
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("load profile error!")
                    let alert = UIAlertController(title: "Unable to load profile!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
    
    //MARK: Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Join activity
        if segue.identifier == "JoinMessage" {
//        if joinButton === sender as? AnyObject{
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
            
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.firstJoin = true
            messageViewController.currentUserId = currentUserId
            messageViewController.postId = post?.id
            messageViewController.username = username
            // Upload to server
            self.createJoin()
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 180)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        messageContent = textField.text
        if messageContent != nil {
            messageContent = messageContent!.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
        }
        animateViewMoving(false, moveValue: 180)
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    // MARK: join activity
    func createJoin() {
        // Upload to server
        ApiManager.sharedInstance.createJoinActivity(self.user!, join: self.join!, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                print("create new activity success!")
                print("joinid: ")
                print(self.join!.id as Any)
//                self.performSegue(withIdentifier: "JoinMessage", sender: self)
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("join activity error!")
                    let alert = UIAlertController(title: "Unable to join activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
    
    func createUsageLog() {
        // Upload to server
        ApiManager.sharedInstance.usageLog(self.user!, usageLog: self.usageLog!, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                print("create new usage log success!")
                print("usageLogid: ")
                print(self.usageLog?.id as Any)
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("cannot create usage log error!")
                }
        })
        
    }

}

// MARK: - CLLocationManagerDelegate
extension DetailViewController: CLLocationManagerDelegate {
    // called when the user grants or revokes location permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // verify the user has granted you permission while the app is in use
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
//            mapView.myLocationEnabled = true
//            mapView.settings.myLocationButton = true
        }
    }
    
    // executes when the location manager receives new location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
//            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            print("coordinate: \(location.coordinate)")
            currentCoordinates = location.coordinate
            locationManager.stopUpdatingLocation()
        }
        
    }
}

