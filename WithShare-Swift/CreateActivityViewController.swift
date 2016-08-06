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
    
    var post:Post?
        
    override func viewDidLoad() {
        print("activity Type after segue: " + activityTypeShow!)
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
        
        user = User(username: username!, password: password!, phoneNumber: phoneNumber!)
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
            if (activityTypeShow == nil ||  activityTypeShow == "Please choose") {
                activityTypeShow = "Not specified"
            }
            if (meetingPlace == nil || meetingPlace == "Please add meeting place") {
                meetingPlace = "Not specified"
            }
            if detail == nil {
                detail = ""
            }
            post = Post()
            if (currentCoordinates != nil) {
                post?.currentLatitude = currentCoordinates!.latitude
                post?.currentLongtitude = currentCoordinates!.longitude
            }
            else {
                post?.currentLatitude = 0
                post?.currentLongtitude = 0
            }
            post?.deviceType = Constants.deviceType
            post?.activityTitle = activityTypeShow
            post?.meetPlace = meetingPlace
            post?.detail = detail
            post?.status = Constants.PostStatus.active
            post?.username = user?.username
            
            
            print("post created:" + post!.username!)
            
            // Upload to server
            ApiManager.sharedInstance.createActivity(user!, post: post!, onSuccess: {(user) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    print("create new activity success!")
                    print("postid: ")
                    print(self.post!.id)
                    self.performSegueWithIdentifier("createActivityExit", sender: self)
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
