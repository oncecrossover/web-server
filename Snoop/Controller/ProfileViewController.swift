//
//  ProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  var rate:Int = 0
  var earning:Double = 0

  var avatarUrl: String?
  var name = ""
  var personTitle = ""
  var about = ""
  var status = ""

  var refreshControl: UIRefreshControl = UIRefreshControl()

  var fullScreenImageView : FullScreenImageView = FullScreenImageView()

  lazy var userFollowHTTP: UserFollow = {
    let result = UserFollow()
    return result
  }()

  lazy var settingsTable: UITableView = {
    let table = UITableView()
    table.backgroundColor = UIColor.white
    table.dataSource = self
    table.delegate = self
    return table
  }()

  fileprivate lazy var earningsView: VerticalPairLabelView = {
    let view = VerticalPairLabelView()
    view.label.text = "earnings"
    let gesture = UITapGestureRecognizer(target: self, action: #selector(earningsViewTapped))
    view.addGestureRecognizer(gesture)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var userModule = User()
  lazy var category = Category()
  var isEditButtonClicked = true
  var isSnooper = false

  let cellId = "expertiseCell"
  let profileCellId = "profileCell"
  let settingsCellId = "settingsCell"

  var expertise:[ExpertiseModel] = []
}

// oevrride methods
extension ProfileViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(settingsTable)
    view.addConstraintsWithFormat("H:|[v0]|", views: settingsTable)
    view.addConstraintsWithFormat("V:|[v0]|", views: settingsTable)
    settingsTable.tableFooterView = UIView()
    settingsTable.separatorInset = UIEdgeInsets.zero
    settingsTable.register(ProfileTableViewCell.self, forCellReuseIdentifier: self.profileCellId)
    settingsTable.register(ProfileSettingsTableViewCell.self, forCellReuseIdentifier: self.settingsCellId)
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    settingsTable.addSubview(refreshControl)

    let settingsButton = UIButton(type: .custom)
    settingsButton.setImage(UIImage(named: "settings"), for: UIControlState())
    settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    settingsButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsButton)

    let editButton = UIButton(type: .custom)
    editButton.setImage(UIImage(named: "edit"), for: UIControlState())
    editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    editButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (UserDefaults.standard.object(forKey: "shouldLoadProfile") == nil ||
      UserDefaults.standard.bool(forKey: "shouldLoadProfile") == true) {
      UserDefaults.standard.set(false, forKey: "shouldLoadProfile")
      UserDefaults.standard.synchronize()
      initView()
    }
    else if (self.name.isEmpty) {
      initView()
    }
  }
}

// Private method
extension ProfileViewController {
  func initView() {
    let uid = UserDefaults.standard.string(forKey: "uid")
    userModule.getProfile(uid!) { fullName, title, aboutMe, avatarUrl, rate, status in
      self.rate = rate
      self.name = fullName
      self.personTitle = title
      self.about = aboutMe
      self.avatarUrl = avatarUrl
      self.status = status
      DispatchQueue.main.async {
        self.settingsTable.reloadData()
        self.refreshControl.endRefreshing()
      }
    }
  }

  @objc func refresh() {
    initView()
  }
}

//IB Action
extension ProfileViewController {

  @objc func editButtonTapped() {
    isEditButtonClicked = true
    let dvc = EditProfileViewController()
    dvc.profileValues = (name: self.name, title: self.personTitle, about: self.about,
                         avatarUrl : self.avatarUrl, rate: self.rate)
    dvc.isEditingProfile = isEditButtonClicked
    dvc.isSnooper = isSnooper
    dvc.selectedExpertise = self.expertise
    self.navigationController?.pushViewController(dvc, animated: true)
  }

  @objc func applyButtonTapped() {
    isEditButtonClicked = false
    let dvc = EditProfileViewController()
    dvc.profileValues = (name: self.name, title: self.personTitle, about: self.about,
                         avatarUrl : self.avatarUrl, rate: self.rate)
    dvc.isEditingProfile = isEditButtonClicked
    dvc.isSnooper = isSnooper
    self.navigationController?.pushViewController(dvc, animated: true)
  }

  @objc func settingsButtonTapped() {
    let dvc = SettingsViewController()
    self.navigationController?.pushViewController(dvc, animated: true)
  }

  @objc func earningsViewTapped() {
    let vc = EarningsViewController()
    vc.earning = self.earning
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

// UITableview delegate and datasource
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath.section == 0) {
      return 240
    }
    else {
      return 44
    }
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.section == 0) {
      let cell = tableView.dequeueReusableCell(withIdentifier: self.profileCellId) as! ProfileTableViewCell
      cell.profileViewController = self
      if let url = self.avatarUrl {
        cell.profilePhoto.sd_setImage(with: URL(string: url)!)
      }
      else {
        cell.profilePhoto.cosmeticizeImage(cosmeticHints: self.name)
      }

      /* setup avatar interaction */
      cell.profilePhoto.isUserInteractionEnabled = true;
      let tap = UITapGestureRecognizer(target: fullScreenImageView, action: #selector(fullScreenImageView.imageTapped))
      cell.profilePhoto.addGestureRecognizer(tap)

      cell.nameLabel.text = self.name
      cell.titleLabel.text = self.personTitle
      cell.aboutLabel.text = self.about
      if (!status.isEmpty) {
        if (status != "APPROVED") {
          isSnooper = false
          cell.applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
          if (status == "APPLIED") {
            isSnooper = true
          }
        }
        else {
          isSnooper = true
        }

        cell.handleApplyButton(status: self.status)
      }

      let uid = UserDefaults.standard.string(forKey: "uid")

      /* set followers and following */
      userFollowHTTP.getUserFollowersByUid(uid!) {
        result in
        DispatchQueue.main.async {
          cell.followers.setAmount(fromInt: result)
        }
      }
      userFollowHTTP.getUserFollowingByUid(uid!) {
        result in
        DispatchQueue.main.async {
          cell.following.setAmount(fromInt: result)
        }
      }

      self.earningsView.removeFromSuperview()
      Payment().getBalance(uid!) { convertedDict in
        if let _ = convertedDict["balance"] as? Double {
          self.earning = convertedDict["balance"] as! Double
          if (self.earning > 0.0) {
            DispatchQueue.main.async {
              self.earningsView.setAmount(fromDouble: self.earning)
              cell.addSubview(self.earningsView)
              self.earningsView.widthAnchor.constraint(equalToConstant: 50).isActive = true
              self.earningsView.heightAnchor.constraint(equalToConstant: 33).isActive = true
              self.earningsView.topAnchor.constraint(equalTo: cell.profilePhoto.topAnchor).isActive = true
              self.earningsView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30).isActive = true
            }
          }
        }
      }
      return cell
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: self.settingsCellId) as! ProfileSettingsTableViewCell
      cell.icon.contentMode = .scaleAspectFit
      cell.category.text = "My Interests"
      cell.icon.image = UIImage(named: "interest")
      return cell
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath.section == 1) {
      let backItem = UIBarButtonItem()
      backItem.title = "Back"
      navigationItem.backBarButtonItem = backItem
      let dvc = InterestPickerViewController()
      dvc.isProfile = true
      self.navigationController?.pushViewController(dvc, animated: true)
    }
  }
}
