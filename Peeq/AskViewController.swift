//
//  AskViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/30/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class AskViewController: UIViewController {

  var profileInfo:(uid: String!, name: String!, title: String!, about: String!, avatarImage:NSData!)

  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var aboutLabel: UILabel!
  @IBOutlet weak var questionView: UITextView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var askButton: UIButton!

  var questionModule = Question()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initView()
  }

  func initView() {
    self.aboutLabel.numberOfLines = 0
    self.aboutLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    self.aboutLabel.sizeToFit()
    self.aboutLabel.text = profileInfo.about
    self.aboutLabel.font = self.aboutLabel.font.fontWithSize(12)

    self.nameLabel.text = profileInfo.name
    self.nameLabel.font = self.nameLabel.font.fontWithSize(15)

    self.titleLabel.text = profileInfo.title
    self.titleLabel.font = self.titleLabel.font.fontWithSize(12)

    if (profileInfo.avatarImage.length > 0) {
      self.profilePhoto.image = UIImage(data: profileInfo.avatarImage)
    }

    self.questionView.layer.borderWidth = 2
    self.questionView.layer.borderColor = UIColor.blackColor().CGColor
    self.questionView.layer.cornerRadius = 4
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func askButtonTapped(sender: AnyObject) {
    let asker = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let responder = profileInfo.uid
    let question = questionView.text
    questionModule.createQuestion(asker!, question: question!, responder: responder!, status: "PENDING"){ resultString in
      var resultMessage = resultString
      if (resultString.isEmpty) {
        resultMessage = "We will notify you once your question is answered"
      }

      //Display success message
      let myAlert = UIAlertController(title: "Thank you for your question", message: resultMessage, preferredStyle: UIAlertControllerStyle.Alert)
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){ action in
        self.dismissViewControllerAnimated(true, completion: nil)
      }

      myAlert.addAction(okAction)
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.presentViewController(myAlert, animated: true, completion: nil)
      }
    }

  }



}
