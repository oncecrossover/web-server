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

  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var settingsTable: UITableView!
  var userModule = User()
  var segueDouble:(String, String)?
  var isEditButtonClicked = true
}

// oevrride methods
extension ProfileViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    settingsTable.tableFooterView = UIView()
    applyButton.setImage(UIImage(named: "apply"), forState: .Normal)
    applyButton.setImage(UIImage(named: "awaiting"), forState: .Disabled)
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
    userModule.getProfile(uid) { fullName, title, aboutMe, avatarImage, rate, status in
      dispatch_async(dispatch_get_main_queue()) {
        self.aboutLabel.text = aboutMe
        self.aboutLabel.font = self.aboutLabel.font.fontWithSize(12)
        self.aboutLabel.textColor = UIColor.blackColor()

        self.nameLabel.text = fullName
        self.nameLabel.font = self.nameLabel.font.fontWithSize(13)
        self.nameLabel.textColor = UIColor.blackColor()

        self.titleLabel.text = title
        self.titleLabel.font = self.titleLabel.font.fontWithSize(12)
        self.titleLabel.textColor = UIColor(red: 140/255, green: 157/255, blue: 170/255, alpha: 1.0)

        self.rateLabel.text = String(rate) + " to answer a question"
        if (rate == 0.0) {
          self.rateLabel.text = "Free to answer a question"
        }

        self.rateLabel.font = self.rateLabel.font.fontWithSize(13)
        self.rateLabel.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
        self.rate = rate

        if (avatarImage.length > 0) {
          self.profilePhoto.image = UIImage(data: avatarImage)
        }
        else {
          self.profilePhoto.image = UIImage(named: "default")
        }

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
      let label = UILabel(frame: frame)
      applyButton.hidden = true
      self.view.addSubview(label)
      label.text = "Congratulations, you can start taking questions."
      label.textAlignment = .Center
      label.textColor = UIColor(red: 51/255, green: 181/255, blue: 159/255, alpha: 1.0)
      label.numberOfLines = 0
      label.font = UIFont.systemFontOfSize(14)
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
      return 4
    }
    return 1
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if (indexPath.section == 0) {
      let cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as! SettingsTableViewCell
      if (indexPath.row == 0) {
        cell.category.text = "Payment"
        cell.icon.image = UIImage(named: "paymentIcon")
      }
      else if (indexPath.row == 1) {
        cell.category.text = "About"
        cell.icon.image = UIImage(named: "aboutIcon")
      }
      else if (indexPath.row == 2) {
        cell.category.text = "Terms of Service"
        cell.icon.image = UIImage(named: "tosIcon")
      }
      else {
        cell.category.text = "Privacy Policy"
        cell.icon.image = UIImage(named: "privacyIcon")
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
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
      NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadHome")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadDiscover")
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadProfile")
      NSUserDefaults.standardUserDefaults().synchronize()
      self.performSegueWithIdentifier("loginView", sender: self)
    }
    else {
      if (indexPath.row == 0) {
        self.performSegueWithIdentifier("profileToPaymentSegue", sender: self)
      }
      else if (indexPath.row == 1) {
      }
      else if (indexPath.row == 2) {
        segueDouble = ("Terms of Service", "tos")
        self.performSegueWithIdentifier("profileToSettingsSegue", sender: self)
      }
      else {
        segueDouble = ("Privacy Policy", "privacy")
        self.performSegueWithIdentifier("profileToSettingsSegue", sender: self)
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
    else if (segue.identifier == "profileToSettingsSegue") {
      let dvc = segue.destinationViewController as! SettingsViewController
      dvc.navigationTitle = segueDouble?.0
      dvc.fileName = segueDouble?.1
    }
  }
}
