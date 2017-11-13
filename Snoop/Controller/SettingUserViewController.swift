//
//  SettingUserViewController.swfit
//  Snoop
//
//  Created by Bingo Zhou on 9/13/17.
//  Copyright © 2017 Snoop Technologies Inc. All rights reserved.
//

import Foundation


class SettingUserViewController: UIViewController {

  var userInfo: (loginUserId: String?, userId: String?)
  lazy var userBlockHTTP = UserBlock()
  lazy var userFollowHTTP = UserFollow()

  lazy var settingsTable: UITableView = {
    let table = UITableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.dataSource = self
    table.delegate = self
    table.rowHeight = 50
    table.separatorInset = UIEdgeInsets.zero
    table.tableFooterView = UIView()
    table.tableHeaderView = UIView()
    table.register(SettingUserTableViewCell.self, forCellReuseIdentifier: self.cellId)
    return table
  }()

  let settingTitles = ["Follow", "Block"]
  let cellId = "settingsCell"

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

extension SettingUserViewController: UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCell(withIdentifier: self.cellId) as! SettingUserTableViewCell

    myCell.selectionStyle = .none
    myCell.label.text = settingTitles[indexPath.row]
    myCell.label.textColor = UIColor(white: 0, alpha: 0.7)

    /* init switch */
    // a user can't block/follow him/erself
    myCell.uiSwitch.isUserInteractionEnabled = userInfo.loginUserId != userInfo.userId
    if (myCell.uiSwitch.isUserInteractionEnabled) {
      if (indexPath.row == 0) { // follow
        loadIfUserIsFollowed(userInfo.loginUserId, userInfo.userId) {
          ifOptIn in

          self.setSwitch(ifOptIn, myCell: myCell)
        }

        myCell.uiSwitch.addTarget(self, action: #selector(SettingUserViewController.followSwitchValueDidChange(_:)
          ), for: .valueChanged)
      } else if (indexPath.row == 1) { // block
        loadIfUserIsBlocked(userInfo.loginUserId, userInfo.userId) {
          ifOptIn in

          self.setSwitch(ifOptIn, myCell: myCell)
        }

        myCell.uiSwitch.addTarget(self, action: #selector(SettingUserViewController.blockSwitchValueDidChange(_:)
          ), for: .valueChanged)
      }
    }

    return myCell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
}

extension SettingUserViewController {
  func setSwitch(_ ifOptIn: Bool, myCell: SettingUserTableViewCell) {
    DispatchQueue.main.async {
      myCell.uiSwitch.setOn(ifOptIn, animated: true)
    }
  }

  /* load if a user is blocked from backend */
  func loadIfUserIsBlocked(_ uid: String?, _ blockeeId: String?, completion: @escaping (Bool) -> ()) {
    guard let _ = uid, let _ = blockeeId else {
      completion(false)
      return
    }

    let filterString = "uid=\(uid!)&blockeeId=\(blockeeId!)"
    userBlockHTTP.getUserBlocks(filterString) {
      jsonArray in

      for entry in jsonArray as! [[String:AnyObject]] {
        let model = UserBlockModel(entry)
          completion(model.blocked == "TRUE" ? true : false)
        break
      }
    }
  }

  /* load if a user is followed from backend */
  func loadIfUserIsFollowed(_ uid: String?, _ followeeId: String?, completion: @escaping (Bool) -> ()) {
    guard let _ = uid, let _ = followeeId else {
      completion(false)
      return
    }

    let filterString = "uid=\(uid!)&followeeId=\(followeeId!)"
    userFollowHTTP.getUserFollows(filterString) {
      jsonArray in

      for entry in jsonArray as! [[String:AnyObject]] {
        let model = UserFollowModel(entry)
        completion(model.followed == "TRUE" ? true : false)
        break
      }
    }
  }

  @objc func blockSwitchValueDidChange(_ sender : UISwitch!) {
    let isOn = sender.isOn ? "TRUE" : "FALSE"
    userBlockHTTP.createUserBlock(userInfo.loginUserId!, blockeeId: userInfo.userId!, blocked: isOn) {
      result in
    }
  }

  @objc func followSwitchValueDidChange(_ sender : UISwitch!) {
    let isOn = sender.isOn ? "TRUE" : "FALSE"
    userFollowHTTP.createUserFollow(userInfo.loginUserId!, followeeId: userInfo.userId!, followed: isOn) {
      result in
    }
  }
}
