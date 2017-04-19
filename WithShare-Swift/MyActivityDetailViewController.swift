//
//  MyActivityDetailViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class MyActivityDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var meetPlaceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var closePostButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var joins = [Join]()
//    var joiners = [User]()
    
    var post: Post?
    var user: User?
//    var joiner: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    //table pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MyActivityDetailViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        if let post = post {
            activityTitleLabel.text = post.activityTitle!
            meetPlaceLabel.text = "meet@ " + post.meetPlace!
            if (post.detail?.isEmpty == false) {
                detailLabel.text = "detail: " + post.detail!
            }
            else {
                detailLabel.text = post.detail!
            }

            if (post.status == Constants.PostStatus.closed) {
                closePostButton.isEnabled = false
                closePostButton.setTitle("closed", for: UIControlState())
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Retrieve cached user info
        let defaults = UserDefaults.standard
        username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
        password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = (defaults.object(forKey: Constants.NSUserDefaultsKey.id) as AnyObject?)?.int64Value
        user = User(username: username!, password: password!)
        user?.phoneNumber = phoneNumber
        
//        user?.id = post?.userId
        user?.id = currentUserId
        
        self.loadMyJoinData()
        
    }
    
    //Pull to refresh
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        self.loadMyJoinData()
        refreshControl.endRefreshing()
    }

    
    // MARK: Joiner Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of joins:")
        print(joins.count)
        return joins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "JoinedUserCustomCell"
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! JoinedUserCustomCell
        
        // Fetches the appropriate join for the data source layout.
        let join = joins[indexPath.row]
        
        if (join.fullName != nil && join.fullName != Constants.blankSign) {
            cell.userNameLabel.text = join.fullName
        }
        else {
            cell.userNameLabel.text = join.username
        }
        
        if (join.status == Constants.JoinStatus.interested) {
            cell.userNameLabel.text = cell.userNameLabel.text! + "(interested)"
        }
        
        // Configure and format time label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let dateFormatterFull = DateFormatter()
        dateFormatterFull.dateStyle = DateFormatter.Style.short
        dateFormatterFull.timeStyle = .short
        
        let cal = Calendar.current
        var components = (cal as NSCalendar).components([.era, .year, .month, .day], from:Date())
        let today = cal.date(from: components)!
        
        components = (cal as NSCalendar).components([.era, .year, .month, .day], from:join.createdAt)
        let otherDate = cal.date(from: components)!
        
        print(join.createdAt)
        print("Joined at: " + dateFormatterFull.string(from: join.createdAt))
        
        cell.joinTimeLabel.text = ""
        
        if (today == otherDate) {
            cell.joinTimeLabel.text =  dateFormatter.string(from: join.createdAt) + " Today"
        }
        else {
            cell.joinTimeLabel.text =  dateFormatterFull.string(from: join.createdAt)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: load joiners
    func loadMyJoinData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getJoinById(user!, post: post!, onSuccess: {(joins) in
            self.joins = joins
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("load joiners error!")
                    let alert = UIAlertController(title: "Unable to load joiners!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
    
    //MARK: Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJoinerDetailSegue" {
            let joinerDetailViewController = segue.destination as! JoinerDetailViewController
            // Get the cell that generated this segue.
            if let selectedActivityCell = sender as? JoinedUserCustomCell {
                let indexPath = tableView.indexPath(for: selectedActivityCell)!
                let selectedActivity = joins[indexPath.row]
                joinerDetailViewController.join = selectedActivity
            }
        }
        else if segue.identifier == "editPostSegue" {
            let postViewController = segue.destination as! CreateActivityViewController
            postViewController.post = self.post
        }
    }
    
    //MARK: Actions
    @IBAction func closeActivity(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Close activity?", message:
            "Do you confirm to close the activity?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.confirmCloseActivity()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editPost(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "editPostSegue", sender: self)
    }
    
    func confirmCloseActivity() {
        self.post?.status = Constants.PostStatus.closed
        //        print(self.post?.status)
        // Upload to server
        ApiManager.sharedInstance.editActivity(self.user!, post: self.post!, onSuccess: {(user) in
            OperationQueue.main.addOperation {
                print("close activity success!")
                print("postid: ")
                print(self.post?.id as Any)
                self.closePostButton.isEnabled = false
                self.closePostButton.setTitle("closed", for: UIControlState())
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("close activity error!")
                    let alert = UIAlertController(title: "Unable to close activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
        })

    }
    
}
