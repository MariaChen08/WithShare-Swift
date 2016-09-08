//
//  CreateActivityViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 6/29/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit
import GoogleMaps

class CreateActivityViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate{
    //MARK: Properties
    @IBOutlet weak var activityTypeButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var editAddressTextField: UITextField!
    @IBOutlet weak var pickPlaceButton: UIButton!
    @IBOutlet weak var detailTextField: UITextField!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var userId: Int64?
    
    var activityTypeShow: String? = "More"
    var meetingPlace: String? = "Please add meeting place"
    var detail: String?
    
    let locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient?
    var placePicker : GMSPlacePicker?
    var currentCoordinates:CLLocationCoordinate2D?
    //default location to IST, PSU
    var center = CLLocationCoordinate2DMake(40.793958335519726, -77.867923433207636)
    
    var post: Post?
    var oldPost:Post?
    
    var usageLog: UsageLog?
        
    override func viewDidLoad() {
        if let post = post {
            activityTypeShow = post.activityTitle!
            detailTextField.text = post.detail!
            oldPost = post
        }

        activityTypeButton.setTitle(activityTypeShow, forState: .Normal)
        addressLabel.numberOfLines = 0
        
        //Hide edit address text field and show when address label tapped
        editAddressTextField.delegate = self
        editAddressTextField.tag = 0
        editAddressTextField.hidden = true
        addressLabel.userInteractionEnabled = true
        let aSelector : Selector = #selector(CreateActivityViewController.labelTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        addressLabel.addGestureRecognizer(tapGesture)
        
        //Detail text field
        detailTextField.delegate = self
        detailTextField.tag = 1
        
        // Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        
        //Google Map
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //Google Place APIs
        placesClient = GMSPlacesClient.sharedClient()
        
        //Show current place
        placesClient?.currentPlaceWithCallback({
            (placeLikelihoodList: GMSPlaceLikelihoodList?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            self.addressLabel.text = self.meetingPlace
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
//                    print("place name: " + place.name)
                    self.meetingPlace = place.formattedAddress!.componentsSeparatedByString(", ")
                        .joinWithSeparator(", ")
                    self.addressLabel.text = self.meetingPlace
                    UIView.animateWithDuration(0.25) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        })
        
        // Retrieve cached user info
        let defaults = NSUserDefaults.standardUserDefaults()
        userId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
        username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
        password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
        
        user = User(username: username!, password: password!)
        user?.phoneNumber = phoneNumber
        user?.id = userId
    }
    
    //MARK: Navigations
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Popover Select Activity Type Menu
        if segue.identifier == "popoverSelectActivitySegue" {
            let popoverViewController = segue.destinationViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
        
        //Post new activity
        if postButton === sender {
            guard (activityTypeShow != nil &&  activityTypeShow != "Please choose") else {
//                activityTypeShow = "Not specified"
                let alert = UIAlertController(title: "No activity type", message:
                    "Please choose the activity type", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            guard (meetingPlace != nil && meetingPlace != "Please add meeting place") else {
                let alert = UIAlertController(title: "No meeting place", message:
                    "Please specify the meeting place", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            detail = detailTextField.text
            if detail == nil {
                detail = ""
            }
            post = Post()
            
            if (currentCoordinates != nil) {
                post?.currentLatitude = currentCoordinates!.latitude
                post?.currentLatitude = (post?.currentLatitude)?.roundFiveDigits()
                post?.currentLongtitude = currentCoordinates!.longitude
                post?.currentLongtitude = (post?.currentLongtitude)?.roundFiveDigits()
            }
            else {
                post?.currentLatitude = 0
                post?.currentLongtitude = 0
            }
            post?.deviceType = Constants.deviceType
            post?.deviceToken = Constants.deviceToken
            post?.activityTitle = activityTypeShow
            post?.meetPlace = meetingPlace
            post?.detail = detail
            post?.status = Constants.PostStatus.active
            post?.username = user?.username
            
            if oldPost != nil {
                self.editActivity()
            }
            self.createActivity()
            
            // dismiss view controller
            self.navigationController?.popViewControllerAnimated(true);
        }
        
        //Cancel post new activity
        if cancelButton === sender {
            // dismiss view controllers
            usageLog = UsageLog()
            usageLog?.userId = self.user?.id
            usageLog?.code = "CA"
            usageLog?.description = "cancel create activity"
            
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
            if (oldPost != nil) {
                usageLog?.postId = oldPost!.id
            }
            else {
                usageLog?.postId = 5
            }
            
            self.createUsageLog()
            
            self.navigationController?.popViewControllerAnimated(true);
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //MARK: unwind methods
    @IBAction func selectActivityType(segue:UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? SelectActivityTypeMenu{
            activityTypeShow = sourceViewController.activityType
            print(sourceViewController.activityType)
            activityTypeButton.setTitle(activityTypeShow, forState: .Normal)        }
    }
    
    //MARK: label and textfields
    func labelTapped(){
        addressLabel.hidden = true
        editAddressTextField.hidden = false
        editAddressTextField.text = addressLabel.text
    }
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        editAddressTextField.hidden = true
        addressLabel.hidden = false
        addressLabel.text = editAddressTextField.text
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch (textField.tag) {
        case 0:
            meetingPlace = textField.text
            if meetingPlace != nil {
                meetingPlace = meetingPlace!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        case 1:
            detail = textField.text
            if detail != nil {
                detail = detail!.stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }

        default:
            print("error registration textview")
        }
    }

    
    //MARK: Pick nearby places
    @IBAction func pickPlace(sender: AnyObject) {
        if currentCoordinates != nil {
            print("current coordinates detected")
            center = CLLocationCoordinate2DMake(currentCoordinates!.latitude, currentCoordinates!.longitude)
        }
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place attributions \(place.attributions)")
                self.meetingPlace = place.name
                self.addressLabel.text = place.name
            } else {
                print("No place selected")
            }
        })
    }
    
    //MARK: upload to server
    func createActivity() {
        // Upload to server
        ApiManager.sharedInstance.createActivity(self.user!, post: self.post!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("create new activity success!")
                print("postid: ")
                print(self.post?.id)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("create new activity error!")
                    let alert = UIAlertController(title: "Unable to create new activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
      
    }
    
    func editActivity() {
        self.oldPost?.status = Constants.PostStatus.modified
        // Upload to server
        ApiManager.sharedInstance.editActivity(self.user!, post: self.oldPost!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("edit activity success!")
                print("postid: ")
                print(self.oldPost?.id)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("create new activity error!")
                    let alert = UIAlertController(title: "Unable to edit activity!", message:
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
                print(self.usageLog?.id)
            }
            }, onError: {(error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("cannot create usage log error!")
                }
        })
        
    }

}

// MARK: - CLLocationManagerDelegate
extension CreateActivityViewController: CLLocationManagerDelegate {
    // called when the user grants or revokes location permissions
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // verify the user has granted you permission while the app is in use
        if status == .AuthorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    // executes when the location manager receives new location data.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            print("coordinate: \(location.coordinate)")
            currentCoordinates = location.coordinate
            locationManager.stopUpdatingLocation()
        }
        
    }
}
