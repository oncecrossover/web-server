//
//  ProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController{
//  var userEmail: String!
//  var fullname = "Bowen Zhang"
//  var userTitle = "Entrepreneur"
//  var about = "I am a software engineer turned entrepreneur and I love programming"


  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var editButton: UIButton!

  @IBOutlet weak var nameLabel: UILabel!

  @IBOutlet weak var aboutLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
//    userEmail = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    initView()

    // Do any additional setup after loading the view.
  }

  func initView() {
    aboutLabel.numberOfLines = 0
    aboutLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    aboutLabel.sizeToFit()
    aboutLabel.text = NSUserDefaults.standardUserDefaults().stringForKey("about")
    aboutLabel.font = aboutLabel.font.fontWithSize(12)

    nameLabel.text = NSUserDefaults.standardUserDefaults().stringForKey("name")
    nameLabel.font = nameLabel.font.fontWithSize(15)

    titleLabel.text = NSUserDefaults.standardUserDefaults().stringForKey("title")
    titleLabel.font = titleLabel.font.fontWithSize(12)

    profilePhoto.layer.cornerRadius = (profilePhoto.frame.size.width) / 2
    profilePhoto.clipsToBounds = true
    profilePhoto.layer.borderColor = UIColor.blackColor().CGColor
    profilePhoto.layer.borderWidth = 2
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "segueToProfileEdit") {
      let dvc = segue.destinationViewController as! EditProfileViewController;
      dvc.profileValues = (name: nameLabel.text, title: titleLabel.text, about: aboutLabel.text)
      
    }
  }

  @IBAction func backFromModal(segue: UIStoryboardSegue) {
    // Switch to the second tab (tabs are numbered 0, 1, 2)
    self.tabBarController?.selectedIndex = 3
    initView()
  }

}
