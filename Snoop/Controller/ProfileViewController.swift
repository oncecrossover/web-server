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

  lazy var settingsTable: UITableView = {
    let table = UITableView()
    table.backgroundColor = UIColor.white
    table.dataSource = self
    table.delegate = self
    return table
  }()

  fileprivate lazy var earningsView: EarningLabel = {
    let view = EarningLabel()
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
    let uid = UserDefaults.standard.integer(forKey: "uid")
    userModule.getProfile(uid) { fullName, title, aboutMe, avatarUrl, rate, status in
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

  func refresh() {
    initView()
  }
}

//IB Action
extension ProfileViewController {

  func editButtonTapped() {
    isEditButtonClicked = true
    let dvc = EditProfileViewController()
    dvc.profileValues = (name: self.name, title: self.personTitle, about: self.about,
                         avatarUrl : self.avatarUrl, rate: self.rate)
    dvc.isEditingProfile = isEditButtonClicked
    dvc.isSnooper = isSnooper
    dvc.selectedExpertise = self.expertise
    self.navigationController?.pushViewController(dvc, animated: true)
  }

  func applyButtonTapped() {
    isEditButtonClicked = false
    let dvc = EditProfileViewController()
    dvc.profileValues = (name: self.name, title: self.personTitle, about: self.about,
                         avatarUrl : self.avatarUrl, rate: self.rate)
    dvc.isEditingProfile = isEditButtonClicked
    dvc.isSnooper = isSnooper
    self.navigationController?.pushViewController(dvc, animated: true)
  }

  func settingsButtonTapped() {
    let dvc = SettingsViewController()
    self.navigationController?.pushViewController(dvc, animated: true)
  }

  func earningsViewTapped() {
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
        cell.profilePhoto.image = UIImage(named: "default")
      }

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

      self.earningsView.removeFromSuperview()
      let uid = UserDefaults.standard.integer(forKey: "uid")
      Payment().getBalance(uid) { convertedDict in
        if let _ = convertedDict["balance"] as? Double {
          self.earning = convertedDict["balance"] as! Double
          if (self.earning > 0.0) {
            DispatchQueue.main.async {
              self.earningsView.setAmount(self.earning)
              cell.addSubview(self.earningsView)
              self.earningsView.widthAnchor.constraint(equalToConstant: 50).isActive = true
              self.earningsView.heightAnchor.constraint(equalToConstant: 33).isActive = true
              self.earningsView.centerYAnchor.constraint(equalTo: cell.profilePhoto.centerYAnchor).isActive = true
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
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
    let dvc = InterestPickerViewController()
    dvc.isProfile = true
    self.navigationController?.pushViewController(dvc, animated: true)
  }
}

// Private earningnlabel class
private class EarningLabel: UIView {
  let amount: UILabel = {
    let amount = UILabel()
    amount.textAlignment = .center
    amount.textColor = UIColor(white: 0, alpha: 0.7)
    amount.font = UIFont.systemFont(ofSize: 16)
    return amount
  }()

  let label: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.text = "Earnings"
    label.textColor = UIColor.disabledColor()
    label.textAlignment = .center
    return label
  }()

  func setAmount(_ num: Double) {
    amount.text = String(format: "%.2f", num)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    addSubview(amount)
    addSubview(label)

    addConstraintsWithFormat("H:|[v0]|", views: amount)
    addConstraintsWithFormat("H:|[v0]|", views: label)
    addConstraintsWithFormat("V:|[v0(18)]-0-[v1(15)]|", views: amount, label)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
