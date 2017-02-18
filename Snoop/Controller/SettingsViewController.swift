//
//  SettingsViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/17/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

  lazy var settingsTable: UITableView = {
    let table = UITableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.dataSource = self
    table.delegate = self
    table.rowHeight = 50
    table.separatorInset = UIEdgeInsetsZero
    table.tableFooterView = UIView()
    table.tableHeaderView = UIView()
    table.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
    return table
  }()

  let settings = ["Contact us", "Terms of Service", "Privacy Policy"]
  let settingsDict = ["Contact us" : "about", "Terms of Service" : "tos", "Privacy Policy" : "privacy"]
  let cellId = "regularCell"
  let userModule = User()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.title = "Settings"

    view.addSubview(settingsTable)

    // Setup constraints for table
    settingsTable.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
    settingsTable.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
    settingsTable.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    settingsTable.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
  }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40.0
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier(self.cellId)!
    if (indexPath.section == 0) {
      myCell.textLabel?.text = settings[indexPath.row]
      myCell.textLabel?.textColor = UIColor.blackColor()
    }
    else {
      myCell.textLabel?.textColor = UIColor.defaultColor()
      myCell.textLabel?.text = "Log Out"
    }

    myCell.textLabel?.textAlignment = .Left
    myCell.accessoryType = .DisclosureIndicator
    return myCell
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return 3
    }
    return 1
  }

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if (section == 0) {
      let headerView = UILabel()
      headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
      headerView.text = "About"
      headerView.textAlignment = .Center
      headerView.textColor = UIColor.defaultColor()
      return headerView
    }

    let headerView = UIView()
    headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    return headerView
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (indexPath.section == 0) {
      let title = settings[indexPath.row]
      let dvc = DocumentViewController()
      dvc.fileName = settingsDict[title]
      dvc.title = title
      self.navigationController?.pushViewController(dvc, animated: true)
    }
  }
}
