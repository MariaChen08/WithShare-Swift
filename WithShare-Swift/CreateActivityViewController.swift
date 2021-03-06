//
//  CreateActivityViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 6/29/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit
import GoogleMaps

class CreateActivityViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    //MARK: Properties
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var activityTitleTextField: UITextField!
    @IBOutlet weak var activityTypeButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var editAddressTextField: UITextField!

    @IBOutlet weak var detailTextView: UITextView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var postButton: UIButton!
    
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var userId: Int64?
   
    var activityTitle: String?
    var meetingPlace: String?
    var detail: String?
    
    var pickerDataSource = ["Today", "Tomorrow"]
    var meetingDay: String = "Today"
    var pickerTime: String?
    
    var meetingAttribute: String?
    
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
            activityTitle = post.activityTitle!
            activityTitleTextField.text = activityTitle
            detailTextView.text = post.detail!
            oldPost = post
        }
        
        // set up date-time picker
        self.datePicker.dataSource = self
        self.datePicker.delegate = self
        
        // set up textview
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        let color = UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0).cgColor
        detailTextView.layer.borderColor = color
        detailTextView.layer.borderWidth = 0.5
        detailTextView.layer.cornerRadius = 5
        detailTextView.text = Constants.activityDetailPlaceholder
        detailTextView.textColor = UIColor.lightGray
        detailTextView.delegate = self
        
        //Set up text field
        activityTitleTextField.delegate = self
        activityTitleTextField.tag = 0
        editAddressTextField.delegate = self
        editAddressTextField.tag = 1
        
        // Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
        
        // Retrieve cached user info
        let defaults = UserDefaults.standard
        userId = ((defaults.object(forKey: Constants.NSUserDefaultsKey.id)) as AnyObject).int64Value
        username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
        password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
        
        user = User(username: username!, password: password!)
        user?.phoneNumber = phoneNumber
        user?.id = userId
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 100)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 0:
            activityTitle = textField.text
            if activityTitle != nil {
                activityTitle = activityTitle!.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
            }
        case 1:
            meetingPlace = textField.text
            if meetingPlace != nil {
                meetingPlace = meetingPlace!.trimmingCharacters(
                    in: CharacterSet.whitespacesAndNewlines)
            }
        default:
            print("error create activity text field")
        }
        animateViewMoving(false, moveValue: 100)
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
    
    // MARK: UITextViewDelegate
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        //Hide the keyboard
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        if (textView.text == Constants.activityDetailPlaceholder) {
            textView.text = ""
        }
        
        animateViewMoving(true, moveValue: 200)
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.activityDetailPlaceholder
            textView.textColor = UIColor.lightGray
        }
        else {
            detail = textView.text
        }
        animateViewMoving(false, moveValue: 200)
    }
    
    // MARK: UIPickerview delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        meetingDay = pickerDataSource[row]
    }
    
    //MARK: upload to server
    func createActivity() {
        // Upload to server
        ApiManager.sharedInstance.createActivity(self.user!, post: self.post!, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                print("create new activity success!")
                print("postid: ")
                print(self.post?.id as Any)
            }
        }, onError: {(error) in
            OperationQueue.main.addOperation {
                print("create new activity error!")
                let alert = UIAlertController(title: "Unable to create new activity!", message:
                    "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    func editActivity() {
        self.oldPost?.status = Constants.PostStatus.modified
        // Upload to server
        ApiManager.sharedInstance.editActivity(self.user!, post: self.oldPost!, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                print("edit activity success!")
                print("postid: ")
                print(self.oldPost?.id as Any)
            }
        }, onError: {(error) in
            OperationQueue.main.addOperation {
                print("create new activity error!")
                let alert = UIAlertController(title: "Unable to edit activity!", message:
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

    
    //MARK: Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Popover Select Activity Type Menu
        if segue.identifier == "popoverSelectActivitySegue" {
            let popoverViewController = segue.destination
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
        
        //Post new activity
        if postButton == (sender as? UIButton) {
            guard (activityTitle != nil && !(activityTitle?.isEmpty)!) else {
                let alert = UIAlertController(title: "No activity title", message:
                    "Please add a title to your activity", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            guard (meetingPlace != nil && !(meetingPlace?.isEmpty)!) else {
                let alert = UIAlertController(title: "No meeting place", message:
                    "Please a place to meet for your activity", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            pickerTime = timeFormatter.string(from: timePicker.date)
//            print("pickerTime:")
//            print(pickerTime)
//            print("pickerDay:")
//            print(meetingDay)
            meetingAttribute = meetingDay + ": " + pickerTime! + ", " + meetingPlace!
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
            post?.activityTitle = activityTitle
            post?.meetPlace = meetingAttribute
            post?.detail = detail
            post?.status = Constants.PostStatus.active
            post?.username = user?.username
            
            if oldPost != nil {
                self.editActivity()
            }
            self.createActivity()
            
            // dismiss view controller
            self.navigationController?.popViewController(animated: true);
        }
        
        //Cancel post new activity
        if cancelButton == (sender as? UIBarButtonItem){
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
            self.navigationController?.popViewController(animated: true);
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //MARK: unwind methods
    @IBAction func selectActivityType(_ segue:UIStoryboardSegue) {
        if let sourceViewController = segue.source as? SelectActivityTypeMenu{
            activityTitle = sourceViewController.activityType
            print(sourceViewController.activityType as Any)
            activityTitleTextField.text = activityTitle
        }
    }
}
