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

  var userModule = User()

  override func viewDidLoad() {
    super.viewDidLoad()
    initView()

    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    initView()
  }

  func initView() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    userModule.getProfile(uid) { fullName, title, aboutMe, avatarImage in
      dispatch_sync(dispatch_get_main_queue(), {
        self.aboutLabel.text = aboutMe
        self.aboutLabel.font = self.aboutLabel.font.fontWithSize(12)

        self.nameLabel.text = fullName
        self.nameLabel.font = self.nameLabel.font.fontWithSize(15)

        self.titleLabel.text = title
        self.titleLabel.font = self.titleLabel.font.fontWithSize(12)

        if (avatarImage.length > 0) {
          self.profilePhoto.image = UIImage(data: avatarImage)
        }
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
        avatarImage : image)
      
    }
  }

  @IBAction func logoutButtonTapped(sender: AnyObject) {
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
    NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
    NSUserDefaults.standardUserDefaults().synchronize()
    self.performSegueWithIdentifier("loginView", sender: self)
  }

}
