//
//  JoinerDetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/16/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit
import GoogleMaps

class JoinerDetailViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: Properties
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var hobbyLabel: UILabel!
    @IBOutlet weak var numOfPostLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var join: Join?

    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var joiner: User?
    
    var messages = [Message]()
    var post: Post?
    
    var messageToSend: Message?
    var messageContent: String?
    
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
    var refreshControl: UIRefreshControl!
//    lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(JoinerDetailViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
//        
//        return refreshControl
//    }()

    
    override func viewDidLoad() {
        //configure tableview
        tableView.delegate = self
        tableView.dataSource = self
//        self.tableView.addSubview(self.refreshControl)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        refreshControl = UIRefreshControl()
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        
        if let join = join {
            // Retrieve cached user info
            let defaults = NSUserDefaults.standardUserDefaults()
            username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
            password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
            
            senderUsername = username
            senderId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
            
            joiner = User(username: username!, password: password!)
            joiner?.phoneNumber = phoneNumber
            
            user = joiner
            
            joiner!.id = join.userId
            
            post = Post()
            post!.id = join.postId
            self.loadJoinerProfile()
            self.loadMessages()

            refreshControl.addTarget(self, action: #selector(JoinerDetailViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
            tableView.addSubview(refreshControl) // not required when using UITableViewController
        }
        
        //Handle the text field’s user input through delegate callbacks.
        messageTextField.delegate = self
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
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

    
    //MARK: load joiner profile
    func loadJoinerProfile() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(joiner!, onSuccess: {(joiner) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                print("get joiner profile success")
                if (joiner.fullName != nil && joiner.fullName != Constants.blankSign) {
                    self.fullNameLabel.text = joiner.fullName
                }
                else {
                    self.fullNameLabel.text = ""
                }
                if (joiner.grade != nil && joiner.grade != Constants.blankSign) {
                    self.gradeLabel.text = joiner.grade
                }
                else {
                    self.gradeLabel.text = ""
                }
                if (joiner.department != nil && joiner.department != Constants.blankSign) {
                    self.departmentLabel.text = joiner.department
                }
                else {
                    self.departmentLabel.text = ""
                }
                if (joiner.hobby != nil && joiner.hobby != Constants.blankSign) {
                    self.hobbyLabel.text = joiner.hobby
                }
                else {
                    self.hobbyLabel.text = ""
                }
                self.numOfPostLabel.text = String(joiner.numOfPosts!) + " posts"
                if (joiner.profilePhoto != nil) {
                    self.profileImage.image = joiner.profilePhoto
                }
                
                // joiner as message receiver
                self.receiverId = joiner.id
                self.receiverUsername = joiner.username
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
    
    //MARK: load messages
    func loadMessages() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getMessageByPost(user!, post: post!, onSuccess: {(messages) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("get messages success")
                self.messages = messages
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    // Filter messages
                    let countMessages = messages.count
                    var flag = 0
                    if (countMessages > 0) {
                        for index in 0...countMessages-1 {
                            guard ( (messages[index].senderId == self.senderId && messages[index].receiverId == self.joiner!.id) || (messages[index].senderId == self.joiner!.id && messages[index].receiverId == self.senderId) ) else {
                                self.messages.removeAtIndex(index-flag)
                                flag += 1
                                continue
                            }
                        }
                    }                    

                    self.tableView.reloadData()
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

    // MARK: Message Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of joins:")
        print(messages.count)
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PostMessageCustomCell"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostMessageCustomCell
        
        // Fetches the appropriate join for the data source layout.
        let message = messages[indexPath.row]
        if (message.senderFullname != nil && message.senderFullname != Constants.blankSign) {
            cell.messageLabel.text = message.senderFullname
        }
        else {
            cell.messageLabel.text = message.senderUsername
        }
        if (message.content != nil) {
            cell.messageLabel.text =  cell.messageLabel.text! + ": " + message.content!
        }
        
        // Configure and format time label
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        let dateString = dateFormatter.stringFromDate(message.createdAt)
        
        print("tableview:")
        print(dateString)
        
        cell.timeLabel.text = dateString
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //Pull to refresh
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        self.loadMessages()
        refreshControl.endRefreshing()
    }
    
    // MARK: Actions
    @IBAction func sendMessage(sender: AnyObject) {
        messageToSend = Message()
        if (currentCoordinates != nil) {
            messageToSend?.currentLatitude = currentCoordinates!.latitude
            messageToSend?.currentLatitude = (messageToSend?.currentLatitude)?.roundFiveDigits()
            messageToSend?.currentLongtitude = currentCoordinates!.longitude
            messageToSend?.currentLongtitude = (messageToSend?.currentLongtitude)?.roundFiveDigits()
        }
        else {
            messageToSend?.currentLatitude = 0
            messageToSend?.currentLongtitude = 0
        }
        messageToSend?.senderId = senderId
        messageToSend?.senderUsername = senderUsername
        messageToSend?.receiverId = receiverId
        messageToSend?.receiverUsername = receiverUsername
        
        messageToSend?.postId = post?.id
        
        if (messageContent == nil)
        {
            messageContent = ""
        }
        messageToSend?.content = messageContent
        
        print("postid: ")
        print(self.messageToSend?.postId)
        print("senderid: ")
        print(self.messageToSend?.senderId)
        print("sender email: " + (self.messageToSend?.senderUsername)!)
        print("receiverid: ")
        print(self.messageToSend?.receiverId)
        print("receiver email: " + (self.messageToSend?.receiverUsername)!)
        
        // Upload to server
        ApiManager.sharedInstance.createMessage(user!, message: messageToSend!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("create new message success!")
                self.messageTextField.text = ""
                // dismiss view controller
                self.navigationController?.popViewControllerAnimated(true);
                
//                let alert = UIAlertController(title: "Message sent!", message:
//                    "Your message has been sent to " + (self.messageToSend?.receiverUsername)!, preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
//                
//                self.presentViewController(alert, animated: true, completion: nil)
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
    
}


// MARK: - CLLocationManagerDelegate
extension JoinerDetailViewController: CLLocationManagerDelegate {
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

