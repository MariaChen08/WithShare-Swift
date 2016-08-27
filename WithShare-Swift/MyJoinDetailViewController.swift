//
//  MyJoinDetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/16/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit
import GoogleMaps

class MyJoinDetailViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    //MARK: Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var gradeLabel: UILabel!
    
    @IBOutlet weak var departmentLabel: UILabel!
    
    @IBOutlet weak var hobbyLabel: UILabel!
    
    @IBOutlet weak var numOfPostLabel: UILabel!
    
    @IBOutlet weak var activityTitleLabel: UILabel!
    
    @IBOutlet weak var meetPlaceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var joinButton: UIBarButtonItem!
    
    var join: Join?
    var post: Post?
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    var messages = [Message]()
    
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
    
    //table pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MyJoinDetailViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    

    
    
    override func viewDidLoad() {
        //configure tableview
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.addSubview(self.refreshControl)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        // Initial blank page
        fullNameLabel.text = ""
        gradeLabel.text = ""
        departmentLabel.text = ""
        numOfPostLabel.text = ""
        activityTitleLabel.text = ""
        meetPlaceLabel.text = ""
        detailLabel.text = ""
        
        activityTitleLabel.font = UIFont.boldSystemFontOfSize(18.0)

        
        if let join = join {
            if (join.status == Constants.JoinStatus.confirm) {
                self.joinButton.title = "";
                self.joinButton.enabled = false;
            }
            
            // Retrieve cached user info
            let defaults = NSUserDefaults.standardUserDefaults()
            username = defaults.stringForKey(Constants.NSUserDefaultsKey.username)
            password = defaults.stringForKey(Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.stringForKey(Constants.NSUserDefaultsKey.phoneNumber)
            currentUserId = (defaults.objectForKey(Constants.NSUserDefaultsKey.id))?.longLongValue
            
            senderId = currentUserId
            senderUsername = username
            
            user = User(username: username!, password: password!)
            user?.id = currentUserId
            user?.phoneNumber = phoneNumber
            
            post = Post()
            post!.id = join.postId
            
            self.loadPostData()
            self.loadMessages()
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
    
    //MARK: load detail data
    func loadPostData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getPostById(user!, postId: self.post!.id!, onSuccess: {(post) in
            print("get post profile success")
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.receiverId = post.userId
                self.receiverUsername = post.username
                // load user profile
                if (post.fullName != nil && post.fullName != Constants.blankSign) {
                    self.fullNameLabel.text = post.fullName
                }
                else {
                    self.fullNameLabel.text = ""
                }
                if (post.postGrade != nil && post.postGrade != Constants.blankSign) {
                    self.gradeLabel.text = post.postGrade
                }
                else {
                    self.gradeLabel.text = ""
                }
                if (post.postDepartment != nil && post.postDepartment != Constants.blankSign) {
                    self.departmentLabel.text = post.postDepartment
                }
                else {
                    self.departmentLabel.text = ""
                }
                if (post.postHobby != nil && post.postHobby != Constants.blankSign) {
                    self.hobbyLabel.text = post.postHobby
                }
                else {
                    self.hobbyLabel.text = ""
                }
                self.numOfPostLabel.text = String(post.postNumOfPosts!) + " posts"
                
                // load post
                self.activityTitleLabel.text = post.activityTitle!
                self.meetPlaceLabel.text = "meet@ " + post.meetPlace!
                self.detailLabel.text = post.detail!
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

    @IBAction func confirmJoin(sender: AnyObject) {
        self.join?.status = Constants.JoinStatus.confirm
        print(self.join?.status)
        // Upload to server
        ApiManager.sharedInstance.confirmJoinActivity(self.user!, join: self.join!, onSuccess: {(user) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("confirm new activity success!")
                print("joinid: ")
                print(self.join!.id)
                self.joinButton.enabled = false
                let alert = UIAlertController(title: "Join activity Success!", message:
                    "Thank you for joining:" + self.post!.activityTitle!, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
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
    
    //MARK: load messages
    func loadMessages() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getMessageByPost(user!, post: post!, onSuccess: {(messages) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                print("get messages success")
                self.messages = messages
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    // Filter messages
                    let countMessages = messages.count
                    var flag = 0
                    for index in 0...countMessages-1 {
                        guard ( (messages[index].senderId == self.senderId && messages[index].receiverId == self.receiverId) || (messages[index].senderId == self.receiverId && messages[index].receiverId == self.senderId) ) else {
                            self.messages.removeAtIndex(index-flag)
                            flag += 1
                            continue
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
        let cellIdentifier = "MyJoinMessageCustomCell"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MyJoinMessageCustomCell
        
        // Fetches the appropriate join for the data source layout.
        let message = messages[indexPath.row]
//        message.isExpanded = !message.isExpanded
        
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

    //MARK: Actions
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
                
                let alert = UIAlertController(title: "Message sent!", message:
                    "Your message has been sent to " + (self.messageToSend?.receiverUsername)!, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                
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
    
}

// MARK: - CLLocationManagerDelegate
extension MyJoinDetailViewController: CLLocationManagerDelegate {
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


