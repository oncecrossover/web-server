//
//  AskViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/30/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class AskViewController: UIViewController {

  var uid:String = ""

  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var aboutLabel: UILabel!
  @IBOutlet weak var questionView: UITextView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var askButton: UIButton!

  var userModule = User()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initView()
  }

  func initView() {
    print("uid is : \(uid)")
    userModule.getProfile(uid) { fullName, title, aboutMe in
      dispatch_sync(dispatch_get_main_queue(), {
        self.aboutLabel.numberOfLines = 0
        self.aboutLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.aboutLabel.sizeToFit()
        self.aboutLabel.text = aboutMe
        self.aboutLabel.font = self.aboutLabel.font.fontWithSize(12)

        self.nameLabel.text = fullName
        self.nameLabel.font = self.nameLabel.font.fontWithSize(15)

        self.titleLabel.text = title
        self.titleLabel.font = self.titleLabel.font.fontWithSize(12)

        let imageUrl = NSURL(string: "http://swiftdeveloperblog.com//wp-content//uploads//2015//08//1_thumb.jpg?v2=1")
        let imageData = NSData(contentsOfURL: imageUrl!)
        if (imageData != nil) {
          self.profilePhoto.image = UIImage(data: imageData!)
        }
        self.profilePhoto.layer.cornerRadius = (self.profilePhoto.frame.size.width) / 2
        self.profilePhoto.clipsToBounds = true
        self.profilePhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.profilePhoto.layer.borderWidth = 2

        self.questionView.layer.borderWidth = 2
        self.questionView.layer.borderColor = UIColor.blackColor().CGColor
        self.questionView.layer.cornerRadius = 4

        self.askButton.layer.cornerRadius = 4

        
      })
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }




}
