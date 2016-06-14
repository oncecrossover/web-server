//
//  SettingsViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 6/5/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var settingsTableview: UITableView!
  var accountList: [String] = ["Email", "Password", "Full Name"]
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if (section == 0){
      return "Account Info"
    }
    return nil
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return 3
    }
    else {
      return 1
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    print("\(indexPath.section) \(indexPath.row)");
    
    
    if (indexPath.section == 0) {
      let myCell = tableView.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath)
      myCell.textLabel?.text = accountList[indexPath.row]
      return myCell
    }
    else {
      let myCell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath)
      //            myCell.textLabel?.text = "Log Out"
      return myCell
    }
  }
  
  @IBAction func logoutButtonTapped(sender: AnyObject) {
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
    NSUserDefaults.standardUserDefaults().synchronize()
    self.performSegueWithIdentifier("settingsToLoginView", sender: self)
  }
}
