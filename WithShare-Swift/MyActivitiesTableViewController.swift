//
//  MyActivitiesTableViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/31/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class MyActivitiesTableViewController: UITableViewController {
    
    //MARK: Properties
    var posts = [Post]()
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
//    var loggedIn:Bool = false
//    var activityTypeTitle = "All Activities"
    
    override func viewDidLoad() {
        
        self.loadMyPostData()
        
        self.refreshControl?.addTarget(self, action: #selector(MyActivitiesTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // if there are no disciplines something bad happened and we should try again
        self.loadMyPostData()
    }
    
    //MARK: Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMyPostDetailSegue" {
            let activityDetailViewController = segue.destination as! MyActivityDetailViewController
            // Get the cell that generated this segue.
            if let selectedActivityCell = sender as? MyPostTableViewCell {
                let indexPath = tableView.indexPath(for: selectedActivityCell)!
                let selectedActivity = posts[indexPath.row]
                activityDetailViewController.post = selectedActivity
            }
        }
    }
    
    @IBAction func backMyActivityUnwindToList(_ sender: UIStoryboardSegue) {
        if sender.source is MyActivityDetailViewController {
            print("from my post detail view")
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(_ controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    // Manage Data Source
    func loadMyPostData() {
        // Retrieve cached user info
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
        self.password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
        self.phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
        self.currentUserId = (defaults.object(forKey: Constants.NSUserDefaultsKey.id) as AnyObject).int64Value
        
        self.user = User(username: username!, password: password!)
        self.user?.phoneNumber = phoneNumber
        self.user?.id = currentUserId

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getMyActivity(self.user!, onSuccess: {(posts) in
            self.posts = posts
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                // Filter posts
                let countPosts = posts.count
                var flag = 0
                if (countPosts > 0) {
                    for index in 0...countPosts-1 {
                        if (posts[index].status == Constants.PostStatus.modified) {
                            self.posts.remove(at: index-flag)
                            flag += 1
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
            }, onError: {(error) in
                OperationQueue.main.addOperation {
                    print("load activity error!")
                    let alert = UIAlertController(title: "Unable to load activity!", message:
                        "Please check network condition or try later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
    
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.loadMyPostData()
        refreshControl.endRefreshing()
    }
    
    //MARK: unwind segues
    @IBAction func editPostUnwindToList(_ segue:UIStoryboardSegue) {
        self.loadMyPostData()
    }
    
    
    //MARK: present dynamic data in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyPostTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyPostTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let post = posts[indexPath.row]
        // Configure cells
        cell.ActivityTitleLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        cell.ActivityTitleLabel.text = post.activityTitle!
        cell.DetailLabel.text = post.detail
        cell.MeetLocationLabel.text = "meet@: " + post.meetPlace!
        
        // Configure and format time label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let dateFormatterFull = DateFormatter()
        dateFormatterFull.dateStyle = DateFormatter.Style.short
        dateFormatterFull.timeStyle = .short
        
        let cal = Calendar.current
        var components = (cal as NSCalendar).components([.era, .year, .month, .day], from:Date())
        let today = cal.date(from: components)!
        
        components = (cal as NSCalendar).components([.era, .year, .month, .day], from:post.createdAt)
        let otherDate = cal.date(from: components)!
        
        if (today == otherDate) {
            cell.TimeLabel.text =  dateFormatter.string(from: post.createdAt) + " Today"
        }
        else {
            cell.TimeLabel.text =  dateFormatterFull.string(from: post.createdAt)
        }
        
        // gray out closed activity
        if (post.status == Constants.PostStatus.closed) {
            cell.ActivityTitleLabel.textColor = UIColor.gray
            cell.DetailLabel.textColor = UIColor.gray
            cell.MeetLocationLabel.textColor = UIColor.gray
            cell.TimeLabel.textColor = UIColor.gray

        }
        else {
            cell.ActivityTitleLabel.textColor = UIColor.black
            cell.DetailLabel.textColor = UIColor.black
            cell.MeetLocationLabel.textColor = UIColor.black
            cell.TimeLabel.textColor = UIColor.black
        }
        
        return cell
    }
    
}
