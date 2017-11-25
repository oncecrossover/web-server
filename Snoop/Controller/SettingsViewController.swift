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
    table.separatorInset = UIEdgeInsets.zero
    table.tableFooterView = UIView()
    table.tableHeaderView = UIView()
    table.register(SettingsTableViewCell.self, forCellReuseIdentifier: self.cellId)
    table.register(SettingsTableHeaderViewCell.self, forHeaderFooterViewReuseIdentifier: self.headerCellId)
    return table
  }()

  let settings = ["Contact us", "Terms of Service", "Privacy Policy"]
  let settingsDict = ["Contact us" : "about", "Terms of Service" : "tos", "Privacy Policy" : "privacy"]
  let cellId = "settingsCell"
  let headerCellId = "headerCell"

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.title = "Settings"

    view.addSubview(settingsTable)

    // Setup constraints for table
    settingsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    settingsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    settingsTable.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    settingsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
  }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40.0
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCell(withIdentifier: self.cellId) as! SettingsTableViewCell
    myCell.selectionStyle = .none
    if (indexPath.section == 0) {
      myCell.label.text = settings[indexPath.row]
      myCell.label.textColor = UIColor(white: 0, alpha: 0.7)
    }
    else {
      myCell.label.textColor = UIColor.defaultColor()
      myCell.label.text = "Log Out"
    }

    myCell.accessoryType = .disclosureIndicator
    return myCell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return 3
    }
    return 1
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if (section == 0) {
      let myCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerCellId) as! SettingsTableHeaderViewCell
      return myCell
    }

    let headerView = UIView()
    headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    return headerView
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath.section == 0) {
      let title = settings[indexPath.row]
      let dvc = DocumentViewController()
      dvc.fileName = settingsDict[title]
      dvc.title = title
      self.navigationController?.pushViewController(dvc, animated: true)
    }
    else if (indexPath.section == 1) {
      let uid = UserDefaults.standard.string(forKey: "uid")
      UserDefaults.standard.removeObject(forKey: "uid")
      UserDefaults.standard.removeObject(forKey: "accessToken")
      UserDefaults.standard.removeObject(forKey: "accessTokenSecret")
      UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
      UserDefaults.standard.set(true, forKey: "shouldLoadHome")
      UserDefaults.standard.set(true, forKey: "shouldLoadDiscover")
      UserDefaults.standard.set(true, forKey: "shouldLoadProfile")
      UserDefaults.standard.set(true, forKey: "shouldLoadQuestions")
      UserDefaults.standard.set(true, forKey: "shouldLoadAnswers")
      UserDefaults.standard.set(true, forKey: "shouldLoadSnoops")
      UserDefaults.standard.synchronize()
      let currentNavigationController = self.navigationController
      let currentTabBarController = self.tabBarController
      let vc = UINavigationController(rootViewController: LoginViewController())
      self.present(vc, animated: true) {
        _ = currentNavigationController?.popViewController(animated: false)
        currentTabBarController?.selectedIndex = 0
        User().updateDeviceToken(uid!, token: "") { result in
        }
      }
    }
  }
}
