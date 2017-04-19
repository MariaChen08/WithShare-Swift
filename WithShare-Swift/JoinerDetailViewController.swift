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
            let defaults = UserDefaults.standard
            username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
            password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
            phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
            
            senderUsername = username
            senderId = (defaults.object(forKey: Constants.NSUserDefaultsKey.id) as AnyObject).int64Value
            
            joiner = User(username: username!, password: password!)
            joiner?.phoneNumber = phoneNumber
            
            user = joiner
            
            joiner!.id = join.userId
            
            post = Post()
            post!.id = join.postId
            self.loadJoinerProfile()
            self.loadMessages()

            refreshControl.addTarget(self, action: #selector(JoinerDetailViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        messageContent = textField.text
        if messageContent != nil {
            messageContent = messageContent!.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines)
        }
    }

    
    //MARK: load joiner profile
    func loadJoinerProfile() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getProfile(joiner!, onSuccess: {(joiner) in
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                OperationQueue.main.addOperation {
                    print("load profile error!")
                    let alert = UIAlertController(title: "Unable to load profile!", message:
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
                print("get messages success")
                self.messages = messages
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    // Filter messages
                    let countMessages = messages.count
                    var flag = 0
                    if (countMessages > 0) {
                        for index in 0...countMessages-1 {
                            guard ( (messages[index].senderId == self.senderId && messages[index].receiverId == self.joiner!.id) || (messages[index].senderId == self.joiner!.id && messages[index].receiverId == self.senderId) ) else {
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
        let cellIdentifier = "PostMessageCustomCell"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PostMessageCustomCell
        
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = .short
        
        let dateString = dateFormatter.string(from: message.createdAt)
        
        print("tableview:")
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
    
    // MARK: Actions
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
        print("sender email: " + (self.messageToSend?.senderUsername)!)
        print("receiverid: ")
        print(self.messageToSend?.receiverId as Any)
        print("receiver email: " + (self.messageToSend?.receiverUsername)!)
        
        // Upload to server
        ApiManager.sharedInstance.createMessage(user!, message: messageToSend!, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                print("create new message success!")
                self.messageTextField.text = ""
                // dismiss view controller
                self.navigationController?.popViewController(animated: true);
                
//                let alert = UIAlertController(title: "Message sent!", message:
//                    "Your message has been sent to " + (self.messageToSend?.receiverUsername)!, preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
//                
//                self.presentViewController(alert, animated: true, completion: nil)
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
extension JoinerDetailViewController: CLLocationManagerDelegate {
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

