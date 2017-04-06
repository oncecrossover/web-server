//
//  ProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

  @IBOutlet weak var profilePhoto: UIImageView!

  @IBOutlet weak var nameLabel: UILabel!

  @IBOutlet weak var aboutLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  var rate:Int = 0
  var earning:Double = 0

  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var settingsTable: UITableView!
  lazy var expertiseCollection: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 6
    layout.minimumLineSpacing = 6
    let expertiseCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    expertiseCollection.register(ExpertiseCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    expertiseCollection.delegate = self
    expertiseCollection.dataSource = self
    expertiseCollection.backgroundColor = UIColor.white
    expertiseCollection.allowsSelection = false
    return expertiseCollection
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

  var expertise:[ExpertiseModel] = []
}

// oevrride methods
extension ProfileViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    settingsTable.tableFooterView = UIView()
    settingsTable.separatorInset = UIEdgeInsets.zero

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

    applyButton.setTitle("Apply to Take Questions", for: UIControlState())
    applyButton.setTitle("Awaiting Approval", for: .disabled)
    applyButton.layer.cornerRadius = 4

    aboutLabel.font = UIFont.systemFont(ofSize: 14)
    aboutLabel.textColor = UIColor(white: 0, alpha: 0.8)

    nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
    nameLabel.textColor = UIColor(white: 0, alpha: 0.7)

    titleLabel.font = UIFont.systemFont(ofSize: 14)
    titleLabel.textColor = UIColor.secondaryTextColor()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (UserDefaults.standard.object(forKey: "shouldLoadProfile") == nil ||
      UserDefaults.standard.bool(forKey: "shouldLoadProfile") == true) {
      UserDefaults.standard.set(false, forKey: "shouldLoadProfile")
      UserDefaults.standard.synchronize()
      initView()
    }
    else if (nameLabel.text?.isEmpty == true) {
      initView()
    }
  }
}

// Private method
extension ProfileViewController {
  func initView() {
    profilePhoto.image = UIImage(named: "default")
    nameLabel.text = ""
    aboutLabel.text = ""
    titleLabel.text = ""
    activityIndicator.startAnimating()
    let uid = UserDefaults.standard.integer(forKey: "uid")
    userModule.getProfile(uid) { fullName, title, aboutMe, avatarUrl, rate, status in
      DispatchQueue.main.async {
        self.aboutLabel.text = aboutMe
        self.nameLabel.text = fullName
        self.titleLabel.text = title

        self.rate = rate

        if (avatarUrl != nil) {
          self.profilePhoto.sd_setImage(with: URL(string: avatarUrl!))
        }
        else {
          self.profilePhoto.image = UIImage(named: "default")
        }

        self.applyButton.isHidden = false
        self.expertiseCollection.isHidden = true
        self.handleApplyButtonView(status)
        self.loadEarningView()
        self.activityIndicator.stopAnimating()
      }
    }
  }

  fileprivate func loadEarningView() {
    self.earningsView.removeFromSuperview()
    let uid = UserDefaults.standard.integer(forKey: "uid")
    Payment().getBalance(uid) { convertedDict in
      if let _ = convertedDict["balance"] as? Double {
        self.earning = convertedDict["balance"] as! Double
        if (self.earning > 0.0) {
          DispatchQueue.main.async {
            self.earningsView.setAmount(self.earning)
            self.view.addSubview(self.earningsView)
            self.earningsView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            self.earningsView.heightAnchor.constraint(equalToConstant: 33).isActive = true
            self.earningsView.centerYAnchor.constraint(equalTo: self.profilePhoto.centerYAnchor).isActive = true
            self.earningsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
          }
        }
      }
    }
  }
  fileprivate func handleApplyButtonView(_ status: String) {
    if (status == "NA" || status.isEmpty) {
      applyButton.isEnabled = true
      isSnooper = false
    }
    else {
      self.expertise = []
      let uid = UserDefaults.standard.integer(forKey: "uid")
      category.getExpertise(uid) { jsonArray in
        for element in jsonArray as! [[String:AnyObject]] {
          let mappingId = element["id"] as! Int
          let catId = element["catId"] as! Int
          let name = element["catName"] as! String
          self.expertise.append(ExpertiseModel(_id: mappingId, _catId: catId, _name: name))
        }

        if (status == "APPLIED") {
          DispatchQueue.main.async {
            self.applyButton.isEnabled = false
            self.isSnooper = true
          }
        }
        else {
          let frame = self.applyButton.frame
          self.expertiseCollection.frame = frame
          self.applyButton.isHidden = true
          self.expertiseCollection.isHidden = false
          self.view.addSubview(self.expertiseCollection)
          self.isSnooper = true
          DispatchQueue.main.async {
            self.expertiseCollection.reloadData()
          }
        }
      }
    }
  }
}

//IB Action
extension ProfileViewController {

  func editButtonTapped() {
    isEditButtonClicked = true
    let dvc = EditProfileViewController()
    var image = UIImage()
    if (profilePhoto.image != nil) {
      image = profilePhoto.image!
    }
    dvc.profileValues = (name: nameLabel.text, title: titleLabel.text, about: aboutLabel.text,
                         avatarImage : image, rate: self.rate)
    dvc.isEditingProfile = isEditButtonClicked
    dvc.isSnooper = isSnooper
    dvc.selectedExpertise = self.expertise
    self.navigationController?.pushViewController(dvc, animated: true)
  }

  @IBAction func applyButtonTapped(_ sender: AnyObject) {
    isEditButtonClicked = false
    let dvc = EditProfileViewController()
    var image = UIImage()
    if (profilePhoto.image != nil) {
      image = profilePhoto.image!
    }
    dvc.profileValues = (name: nameLabel.text, title: titleLabel.text, about: aboutLabel.text,
                         avatarImage : image, rate: self.rate)
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
// UICollection delegate, datasource, and flowlayout
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.expertise.count + 1
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! ExpertiseCollectionViewCell
    myCell.icon.font = UIFont.systemFont(ofSize: 12)
    if (indexPath.row == 0) {
      myCell.icon.text = "Ask me about:"
      myCell.icon.textColor = UIColor.secondaryTextColor()
      myCell.icon.layer.borderWidth = 0
    }
    else {
      myCell.icon.text = expertise[indexPath.row - 1].name
      myCell.icon.layer.borderWidth = 1
      myCell.isSelected = true
    }

    myCell.clipsToBounds = true
    return myCell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var name = "Ask me about:" as NSString
    if (indexPath.row > 0) {
      let category = expertise[indexPath.row - 1]
      name = category.name as NSString
    }

    let estimatedSize = name.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)])
    return CGSize(width: estimatedSize.width + 8, height: 18)
  }
}

// UITableview delegate and datasource
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 8.0
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! ProfileSettingsTableViewCell
    cell.icon.contentMode = .scaleAspectFit
    cell.category.text = "My Interests"
    cell.icon.image = UIImage(named: "interest")
    return cell
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
    amount.text = "$\(num)"
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
