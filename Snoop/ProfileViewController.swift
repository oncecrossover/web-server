//
//  ProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController{

  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var editButton: UIButton!

  @IBOutlet weak var nameLabel: UILabel!

  @IBOutlet weak var aboutLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var rateLabel: UILabel!

  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  var rate:Double = 0.0

  var userModule = User()

  override func viewDidLoad() {
    super.viewDidLoad()
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

  func initView() {
    profilePhoto.image = UIImage(named: "default")
    nameLabel.text = ""
    aboutLabel.text = ""
    titleLabel.text = ""
    rateLabel.text = ""
    activityIndicator.startAnimating()
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    userModule.getProfile(uid) { fullName, title, aboutMe, avatarImage, rate in
      dispatch_async(dispatch_get_main_queue()) {
        self.aboutLabel.text = aboutMe
        self.aboutLabel.font = self.aboutLabel.font.fontWithSize(14)

        self.nameLabel.text = fullName
        self.nameLabel.font = self.nameLabel.font.fontWithSize(14.5)

        self.titleLabel.text = title
        self.titleLabel.font = self.titleLabel.font.fontWithSize(13)

        self.rateLabel.text = String(rate) + " to answer a question"
        if (rate == 0.0) {
          self.rateLabel.text = "Free to answer a question"
        }

        self.rateLabel.font = self.rateLabel.font.fontWithSize(15)
        self.rate = rate

        if (avatarImage.length > 0) {
          self.profilePhoto.image = UIImage(data: avatarImage)
        }
        else {
          self.profilePhoto.image = UIImage(named: "default")
        }

        self.activityIndicator.stopAnimating()
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "segueToProfileEdit") {
      let dvc = segue.destinationViewController as! EditProfileViewController;
      var image = UIImage()
      if (profilePhoto.image != nil) {
        image = profilePhoto.image!
      }
      dvc.profileValues = (name: nameLabel.text, title: titleLabel.text, about: aboutLabel.text,
        avatarImage : image, rate: self.rate)
      
    }
  }

  @IBAction func logoutButtonTapped(sender: AnyObject) {
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
    NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadHome")
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadDiscover")
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "shouldLoadProfile")
    NSUserDefaults.standardUserDefaults().synchronize()
    self.performSegueWithIdentifier("loginView", sender: self)
  }

}
