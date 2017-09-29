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

  let settings = ["Block"]
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
    myCell.label.text = settings[indexPath.row]
    myCell.label.textColor = UIColor(white: 0, alpha: 0.7)

    /* init block switch */
    // a user can't block him/erself
    myCell.blockSwitch.isUserInteractionEnabled = userInfo.loginUserId != userInfo.userId
    if (myCell.blockSwitch.isUserInteractionEnabled) {
      loadIfUserBlocked(uid: userInfo.loginUserId, blockeeId: userInfo.userId) {
        ifUserBlocked in

        DispatchQueue.main.async {
          myCell.blockSwitch.setOn(ifUserBlocked, animated: true)
        }
      }
      myCell.blockSwitch.addTarget(self, action: #selector(SettingUserViewController.blockSwitchValueDidChange(_:)), for: .valueChanged)
    }

    return myCell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
}


extension SettingUserViewController {
  /* load if a user is blocked from backend */
  func loadIfUserBlocked(uid: String?, blockeeId: String?, completion: @escaping (Bool) -> ()) {
    guard let _ = uid, let _ = blockeeId else {
      completion(false)
      return
    }

    let filterString = "uid=\(uid!)&blockeeId=\(blockeeId!)"
    userBlockHTTP.getUserBlocks(filterString) {
      jsonArray in

      for userBlockInfo in jsonArray as! [[String:AnyObject]] {
        let userBlockModel = UserBlockModel(userBlockInfo)
          completion(userBlockModel.blocked == "TRUE" ? true : false)
        break
      }
    }
  }

  func blockSwitchValueDidChange(_ sender : UISwitch!) {
    let blocked = sender.isOn ? "TRUE" : "FALSE"
    userBlockHTTP.createUserBlock(userInfo.loginUserId!, blockeeId: userInfo.userId!, blocked: blocked) {
      result in
    }
  }
}
