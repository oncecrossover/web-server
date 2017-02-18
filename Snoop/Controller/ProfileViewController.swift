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
  @IBOutlet weak var editButton: UIButton!

  @IBOutlet weak var nameLabel: UILabel!

  @IBOutlet weak var aboutLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var rateLabel: UILabel!

  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  var rate:Double = 0.0

  @IBOutlet weak var answerLabel: UILabel!
  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var settingsTable: UITableView!
  var approvedLabel = UILabel()
  var userModule = User()
  var segueDouble:(String, String)?
  var isEditButtonClicked = true
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
    let rightBarItem = UIBarButtonItem(customView: settingsButton)
    navigationItem.rightBarButtonItem = rightBarItem

    applyButton.setTitle("Apply to Take Questions", forState: .Normal)
    applyButton.setTitle("Awaiting Approval", forState: .Disabled)
    applyButton.layer.cornerRadius = 4

    answerLabel.text = "to answer a question"
    answerLabel.textColor = UIColor.disabledColor()
    answerLabel.textAlignment = .Left

    aboutLabel.font = UIFont.systemFontOfSize(14)
    aboutLabel.textColor = UIColor.blackColor()

    nameLabel.font = UIFont.boldSystemFontOfSize(18)
    nameLabel.textColor = UIColor.blackColor()

    titleLabel.font = UIFont.systemFontOfSize(14)
    titleLabel.textColor = UIColor.secondaryTextColor()

    rateLabel.font = UIFont.systemFontOfSize(14)
    rateLabel.textColor = UIColor.redColor()
    rateLabel.textAlignment = .Right
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
    rateLabel.text = ""
    activityIndicator.startAnimating()
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    userModule.getProfile(uid) { fullName, title, aboutMe, avatarUrl, rate, status in
      dispatch_async(dispatch_get_main_queue()) {
        self.aboutLabel.text = aboutMe
        self.nameLabel.text = fullName
        self.titleLabel.text = title

        self.rateLabel.text = "$ " + String(rate)
        if (rate == 0.0) {
          self.rateLabel.text = "$ 0.0"
        }

        self.rate = rate

        if (avatarUrl != nil) {
          self.profilePhoto.image = UIImage(data: NSData(contentsOfURL: NSURL(string: avatarUrl!)!)!)
        }
        else {
          self.profilePhoto.image = UIImage(named: "default")
        }

        self.applyButton.hidden = false
        self.approvedLabel.hidden = true
        self.handleApplyButtonView(status)
        self.activityIndicator.stopAnimating()
      }
    }
  }

  private func handleApplyButtonView(status: String) {
    if (status == "NA" || status.isEmpty) {
      applyButton.enabled = true
    }
    else if (status == "APPLIED") {
      applyButton.enabled = false
    }
    else {
      let frame = applyButton.frame
      approvedLabel.frame = frame
      applyButton.hidden = true
      approvedLabel.hidden = false
      self.view.addSubview(approvedLabel)
      approvedLabel.text = "Congratulations, you can start taking questions."
      approvedLabel.textAlignment = .Left
      approvedLabel.textColor = UIColor(red: 51/255, green: 181/255, blue: 159/255, alpha: 1.0)
      approvedLabel.numberOfLines = 0
      approvedLabel.font = UIFont.systemFontOfSize(14)
    }
  }
}

//IB Action
extension ProfileViewController {

  @IBAction func editButtonTapped(sender: AnyObject) {
    isEditButtonClicked = true
    self.performSegueWithIdentifier("segueToProfileEdit", sender: self)
  }

  @IBAction func applyButtonTapped(sender: AnyObject) {
    isEditButtonClicked = false
    self.performSegueWithIdentifier("segueToProfileEdit", sender: self)
  }

  func settingsButtonTapped() {
    let dvc = SettingsViewController()
    self.navigationController?.pushViewController(dvc, animated: true)
  }
}

// UITableview delegate and datasource
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 8.0
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return 2
    }
    return 1
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if (indexPath.section == 0) {
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
    else {
      let cell = tableView.dequeueReusableCellWithIdentifier("regularCell")! as UITableViewCell
      cell.textLabel?.text = "Log Out"
      cell.textLabel?.textColor = UIColor(red: 51/255, green: 181/255, blue: 159/255, alpha: 1.0)
      cell.textLabel?.textAlignment = .Center
      return cell
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (indexPath.section == 1) {
      let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
      NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadHome")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadDiscover")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadProfile")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadQuestions")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadAnswers")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadSnoops")
      NSUserDefaults.standardUserDefaults().synchronize()
      userModule.updateDeviceToken(uid, token: "") { result in
        dispatch_async(dispatch_get_main_queue()) {
          self.performSegueWithIdentifier("loginView", sender: self)
        }
      }
    }
    else {
      let backItem = UIBarButtonItem()
      backItem.title = "Back"
      navigationItem.backBarButtonItem = backItem

      if (indexPath.row == 0) {

        let dvc = PaymentViewController()
        self.navigationController?.pushViewController(dvc, animated: true)
      }
    }
  }
}
// Action segue related methods
extension ProfileViewController {
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "segueToProfileEdit") {
      let dvc = segue.destinationViewController as! EditProfileViewController
      var image = UIImage()
      if (profilePhoto.image != nil) {
        image = profilePhoto.image!
      }
      dvc.profileValues = (name: nameLabel.text, title: titleLabel.text, about: aboutLabel.text,
        avatarImage : image, rate: self.rate)
      dvc.isEditingProfile = isEditButtonClicked
      
    }
  }
}
