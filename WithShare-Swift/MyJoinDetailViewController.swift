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
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        //configure tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        refreshControl = UIRefreshControl()
        
        // Initial blank page
        fullNameLabel.text = ""
        gradeLabel.text = ""
        departmentLabel.text = ""
        numOfPostLabel.text = ""
        activityTitleLabel.text = ""
        meetPlaceLabel.text = ""
        detailLabel.text = ""
        
        activityTitleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        if let join = join {
            if (join.status == Constants.JoinStatus.confirm) {
                self.joinButton.title = "";
                self.joinButton.isEnabled = false;
                
            }
            
            // Retrieve cached user info
            let defaults = UserDefaults.standard
            username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
            password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
            currentUserId = ((defaults.object(forKey: Constants.NSUserDefaultsKey.id)) as AnyObject).int64Value
            
            senderId = currentUserId
            senderUsername = username
            
            receiverId = join.userId
            receiverUsername = join.username
            
            user = User(username: username!, password: password!)
            user?.id = currentUserId
            user?.phoneNumber = phoneNumber
            
            post = Post()
            post!.id = join.postId
            
            self.loadPostData()
            self.loadMessages()
            
            refreshControl.addTarget(self, action: #selector(MyJoinDetailViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
            tableView.addSubview(refreshControl) // not required when using UITableViewController
        }
        
        //Handle the text field’s user input through delegate callbacks.
        messageTextField.delegate = self
        //Close keyboard by clicking anywhere else
        self.hideKeyboardWhenTappedAround()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 60)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        messageContent = textField.text
        if messageContent != nil {
            messageContent = messageContent!.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
        }
        animateViewMoving(false, moveValue: 60)
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
    
    //MARK: load detail data
    func loadPostData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getPostById(user!, postId: self.post!.id!, onSuccess: {(post) in
            print("get post profile success")
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.post = post
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
                
                if (post.postPhoto != nil) {
                    self.photoImageView.image = post.postPhoto
                }
                
                // load post
                self.activityTitleLabel.text = post.activityTitle!
                self.meetPlaceLabel.text = "meet@ " + post.meetPlace!
                self.detailLabel.text = post.detail!
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
    
    @IBAction func confirmJoin(_ sender: AnyObject) {
        self.join?.status = Constants.JoinStatus.confirm
        print(self.join?.status as Any)
        // Upload to server
        ApiManager.sharedInstance.confirmJoinActivity(self.user!, join: self.join!, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                print("confirm new activity success!")
                print("joinid: ")
                print(self.join?.id as Any)
                self.joinButton.isEnabled = false
                let alert = UIAlertController(title: "Join activity Success!", message:
                    "Thank you for joining:" + self.join!.postName!, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
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
    
    //MARK: load messages
    func loadMessages() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getMessageByPost(user!, post: post!, onSuccess: {(messages) in
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("get messages success")
                self.messages = messages
                OperationQueue.main.addOperation {
                    // Filter messages
                    let countMessages = messages.count
                    var flag = 0
                    if (countMessages > 0) {
                        for index in 0...countMessages-1 {
                            guard ( (messages[index].senderId == self.senderId && messages[index].receiverId == self.receiverId) || (messages[index].senderId == self.receiverId && messages[index].receiverId == self.senderId) ) else {
                                self.messages.remove(at: index-flag)
                                flag += 1
                                continue
                            }
                        }

                    }
                    self.tableView.reloadData()
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
    
    // MARK: Message Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of joins:")
        print(messages.count)
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyJoinMessageCustomCell"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyJoinMessageCustomCell
        
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = .short
        
        let dateString = dateFormatter.string(from: message.createdAt)
        
        print(dateString)
        
        cell.timeLabel.text = dateString
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //Pull to refresh
        func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        self.loadMessages()
        refreshControl.endRefreshing()
    }

    //MARK: Actions
    @IBAction func sendMessage(_ sender: AnyObject) {
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
        print(self.messageToSend?.postId as Any)
        print("senderid: ")
        print(self.messageToSend?.senderId as Any)
//        print("sender email: " + (self.messageToSend?.senderUsername)!)
        print("receiverid: ")
        print(self.messageToSend?.receiverId as Any)
//        print("receiver email: " + (self.messageToSend?.receiverUsername)!)
        
        // Upload to server
        ApiManager.sharedInstance.createMessage(user!, message: messageToSend!, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                print("create new message success!")
                
                self.messageTextField.text = ""
                // dismiss view controller
                self.navigationController?.popViewController(animated: true);
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("create new message error!")
                    let alert = UIAlertController(title: "Unable to send!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
        })

    }
    
}

// MARK: - CLLocationManagerDelegate
extension MyJoinDetailViewController: CLLocationManagerDelegate {
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


