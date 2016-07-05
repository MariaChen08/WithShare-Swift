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
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var activityTypeShow:String? = "More"
    var meetingPlace:String? = "Please add meeting place"
    
    let locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient?
    var placePicker : GMSPlacePicker?
    var currentCoordinates:CLLocationCoordinate2D?
    //default location to IST, PSU
    var center = CLLocationCoordinate2DMake(40.793958335519726, -77.867923433207636)
    
    var post:Post?
    
    override func viewDidLoad() {
        activityTypeButton.setTitle(activityTypeShow, forState: .Normal)
        addressLabel.numberOfLines = 0
        
        //Hide edit address text field and show when address label tapped
        editAddressTextField.delegate = self
        editAddressTextField.hidden = true
        addressLabel.userInteractionEnabled = true
        let aSelector : Selector = #selector(CreateActivityViewController.labelTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        addressLabel.addGestureRecognizer(tapGesture)
        
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
        
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
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
            
            post = Post()

        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //MARK: unwind methods
    @IBAction func selectActivityType(segue:UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? SelectActivityTypeMenu{
            let activityTypeShow = sourceViewController.activityType
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
