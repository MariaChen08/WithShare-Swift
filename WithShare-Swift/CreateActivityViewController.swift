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
    
    var activityTypeShow:String? = "More"
    var currentPlace:String? = "Please add meeting place"
    
    let locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient?
    
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
            self.addressLabel.text = self.currentPlace
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    print("place name: " + place.name)
                    self.currentPlace = place.formattedAddress!.componentsSeparatedByString(", ")
                        .joinWithSeparator(", ")
                    self.addressLabel.text = self.currentPlace
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
            
            locationManager.stopUpdatingLocation()
        }
        
    }
}

