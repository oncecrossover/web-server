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

  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var settingsTable: UITableView!
  lazy var expertiseCollection: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 6
    layout.minimumLineSpacing = 6
    let expertiseCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    expertiseCollection.registerClass(ExpertiseCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    expertiseCollection.delegate = self
    expertiseCollection.dataSource = self
    expertiseCollection.backgroundColor = UIColor.whiteColor()
    expertiseCollection.allowsSelection = false
    return expertiseCollection
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
    settingsTable.separatorInset = UIEdgeInsetsZero

    let settingsButton = UIButton(type: .Custom)
    settingsButton.setImage(UIImage(named: "settings"), forState: .Normal)
    settingsButton.addTarget(self, action: #selector(settingsButtonTapped), forControlEvents: .TouchUpInside)
    settingsButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsButton)

    let editButton = UIButton(type: .Custom)
    editButton.setImage(UIImage(named: "edit"), forState: .Normal)
    editButton.addTarget(self, action: #selector(editButtonTapped), forControlEvents: .TouchUpInside)
    editButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)

    applyButton.setTitle("Apply to Take Questions", forState: .Normal)
    applyButton.setTitle("Awaiting Approval", forState: .Disabled)
    applyButton.layer.cornerRadius = 4

    aboutLabel.font = UIFont.systemFontOfSize(14)
    aboutLabel.textColor = UIColor(white: 0, alpha: 0.8)

    nameLabel.font = UIFont.boldSystemFontOfSize(18)
    nameLabel.textColor = UIColor(white: 0, alpha: 0.7)

    titleLabel.font = UIFont.systemFontOfSize(14)
    titleLabel.textColor = UIColor.secondaryTextColor()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if (NSUserDefaults.standardUserDefaults().objectForKey("shouldLoadProfile") == nil ||
      NSUserDefaults.standardUserDefaults().boolForKey("shouldLoadProfile") == true) {
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldLoadProfile")
      NSUserDefaults.standardUserDefaults().synchronize()
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
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    userModule.getProfile(uid) { fullName, title, aboutMe, avatarUrl, rate, status in
      dispatch_async(dispatch_get_main_queue()) {
        self.aboutLabel.text = aboutMe
        self.nameLabel.text = fullName
        self.titleLabel.text = title

        self.rate = rate

        if (avatarUrl != nil) {
          self.profilePhoto.sd_setImageWithURL(NSURL(string: avatarUrl!))
        }
        else {
          self.profilePhoto.image = UIImage(named: "default")
        }

        self.applyButton.hidden = false
        self.expertiseCollection.hidden = true
        self.handleApplyButtonView(status)
        self.activityIndicator.stopAnimating()
      }
    }
  }

  private func handleApplyButtonView(status: String) {
    if (status == "NA" || status.isEmpty) {
      applyButton.enabled = true
      isSnooper = false
    }
    else if (status == "APPLIED") {
      applyButton.enabled = false
      isSnooper = true
    }
    else {
      let frame = applyButton.frame
      self.expertiseCollection.frame = frame
      applyButton.hidden = true
      expertiseCollection.hidden = false
      self.view.addSubview(expertiseCollection)
      isSnooper = true
      self.expertise = []
      let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
      category.getExpertise(uid) { jsonArray in
        for element in jsonArray as! [[String:AnyObject]] {
          let mappingId = element["id"] as! Int
          let catId = element["catId"] as! Int
          let name = element["catName"] as! String
          self.expertise.append(ExpertiseModel(_id: mappingId, _catId: catId, _name: name))
        }

        dispatch_async(dispatch_get_main_queue()) {
          self.expertiseCollection.reloadData()
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

  @IBAction func applyButtonTapped(sender: AnyObject) {
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
}
// UICollection delegate, datasource, and flowlayout
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.expertise.count + 1
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let myCell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellId, forIndexPath: indexPath) as! ExpertiseCollectionViewCell
    myCell.icon.font = UIFont.systemFontOfSize(12)
    if (indexPath.row == 0) {
      myCell.icon.text = "Ask me about:"
      myCell.icon.textColor = UIColor.secondaryTextColor()
      myCell.icon.layer.borderWidth = 0
    }
    else {
      myCell.icon.text = expertise[indexPath.row - 1].name
      myCell.icon.layer.borderWidth = 1
      myCell.selected = true
    }

    myCell.clipsToBounds = true
    return myCell
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var name = "Ask me about:" as NSString
    if (indexPath.row > 0) {
      let category = expertise[indexPath.row - 1]
      name = category.name as NSString
    }

    let estimatedSize = name.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(12)])
    return CGSizeMake(estimatedSize.width + 8, 18)
  }
}

// UITableview delegate and datasource
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 8.0
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as! SettingsTableViewCell
    cell.icon.contentMode = .ScaleAspectFit
    if (indexPath.row == 0) {
      cell.category.text = "My Wallet"
      cell.icon.image = UIImage(named: "wallet")
    }
    else if (indexPath.row == 1) {
      cell.category.text = "My Interests"
      cell.icon.image = UIImage(named: "interest")
    }
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem

    if (indexPath.row == 0) {
      let dvc = PaymentViewController()
      self.navigationController?.pushViewController(dvc, animated: true)
    }
    else if (indexPath.row == 1) {
      let dvc = InterestPickerViewController()
      dvc.isProfile = true
      self.navigationController?.pushViewController(dvc, animated: true)
    }
  }
}
