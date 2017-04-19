//
//  MyJoinTableViewController.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/15/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

class MyJoinTableViewController: UITableViewController {
    //MARK: Properties
    var joins = [Join]()
    
    var user: User?
    var username: String?
    var password: String?
    var phoneNumber: String?
    var currentUserId: Int64?
    
    //    var loggedIn:Bool = false
    //    var activityTypeTitle = "All Activities"
    
    override func viewDidLoad() {
        
        //        //Check if logged in
        //        let prefs = NSUserDefaults.standardUserDefaults()
        //        loggedIn = prefs.boolForKey("UserLogIn")
        //
        //        if !loggedIn {
        //            performSegueWithIdentifier("needLogInSegue", sender: self)
        //            //            self.navigationItem.hidesBackButton = true
        //        }
        
        // Retrieve cached user info
        let defaults = UserDefaults.standard
        username = defaults.string(forKey: Constants.NSUserDefaultsKey.username)
        password = defaults.string(forKey: Constants.NSUserDefaultsKey.password)
        phoneNumber = defaults.string(forKey: Constants.NSUserDefaultsKey.phoneNumber)
        currentUserId = (defaults.object(forKey: Constants.NSUserDefaultsKey.id) as AnyObject?)?.int64Value
        
        user = User(username: username!, password: password!)
        user?.phoneNumber = phoneNumber
        user?.id = currentUserId
        
        self.loadMyJoinData()
        
        self.refreshControl?.addTarget(self, action: #selector(MyJoinTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // if there are no posts something bad happened and we should try again
        self.loadMyJoinData()
    }
    
    //MARK: Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMyJoinDetailSegue" {
            let joinDetailViewController = segue.destination as! MyJoinDetailViewController
            // Get the cell that generated this segue.
            if let selectedJoinCell = sender as? MyJoinTableViewCell {
                let indexPath = tableView.indexPath(for: selectedJoinCell)!
                let selectedJoin = joins[indexPath.row]
                joinDetailViewController.join = selectedJoin
            }
        }
    }
    
    
    func adaptivePresentationStyleForPresentationController(_ controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //MARK: Manage Data Source
    func loadMyJoinData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ApiManager.sharedInstance.getJoinByUser(user!, onSuccess: {(joins) in
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
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.loadMyJoinData()
        refreshControl.endRefreshing()
    }
    
    
    //MARK: present dynamic data in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MyJoinTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyJoinTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let join = joins[indexPath.row]
        
        cell.activityTitleLabel.text = join.postName

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
        
        var joinQuote: String
        if (join.status == Constants.JoinStatus.interested) {
            joinQuote = "Message initially sent:"
            cell.activityTitleLabel.text = join.postName! + "\n" + "(Interested)"
        }
        else {
            joinQuote = "Joined at:"
        }
        
        if (today == otherDate) {
            cell.joinTimeLabel.text = joinQuote +  dateFormatter.string(from: join.createdAt) + " Today"
        }
        else {
            cell.joinTimeLabel.text =  joinQuote + dateFormatterFull.string(from: join.createdAt)
        }
        
        return cell
    }

}
