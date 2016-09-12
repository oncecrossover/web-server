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
    initView()

    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }

  func initView() {
    activityIndicator.startAnimating()
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    userModule.getProfile(uid) { fullName, title, aboutMe, avatarImage, rate in
      dispatch_sync(dispatch_get_main_queue(), {
        self.aboutLabel.text = aboutMe
        self.aboutLabel.font = self.aboutLabel.font.fontWithSize(14)

        self.nameLabel.text = fullName
        self.nameLabel.font = self.nameLabel.font.fontWithSize(14.5)

        self.titleLabel.text = title
        self.titleLabel.font = self.titleLabel.font.fontWithSize(13)

        self.rateLabel.text = String(rate) + " to answer a question"
        self.rateLabel.font = self.rateLabel.font.fontWithSize(15)
        self.rate = rate

        if (avatarImage.length > 0) {
          self.profilePhoto.image = UIImage(data: avatarImage)
        }
        else {
          self.profilePhoto.image = UIImage(named: "default")
        }

        self.activityIndicator.stopAnimating()
      })
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
    NSUserDefaults.standardUserDefaults().synchronize()
    self.performSegueWithIdentifier("loginView", sender: self)
  }

}
