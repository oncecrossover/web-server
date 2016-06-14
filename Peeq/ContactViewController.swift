//
//  ContactViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 6/4/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var contactTableview: UITableView!
  var profileList: [String] = ["Bowen", "Followers", "Following"]
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return profileList.count
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath)
    myCell.textLabel?.text = profileList[indexPath.row]
    return myCell
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Profile"
  }
}
