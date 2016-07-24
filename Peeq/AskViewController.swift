//
//  AskViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/30/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class AskViewController: UIViewController, UITextViewDelegate {

  var profileInfo:(uid: String!, name: String!, title: String!, about: String!, avatarImage:NSData!)

  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var aboutLabel: UILabel!
  @IBOutlet weak var questionView: UITextView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var askButton: UIButton!

  var questionModule = Question()
  var utility = UIUtility()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initView()
  }

  func initView() {
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


  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }

  @IBAction func askButtonTapped(sender: AnyObject) {
    questionView.resignFirstResponder()
    let asker = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let responder = profileInfo.uid
    let question = questionView.text
    questionModule.createQuestion(asker!, question: question!, responder: responder!, status: "PENDING"){ resultString in
      var resultMessage = resultString
      if (resultString.isEmpty) {
        resultMessage = "We will notify you once your question is answered"
      }

      dispatch_async(dispatch_get_main_queue()){
        self.utility.displayAlertMessage(resultMessage,
          title: "Thank you for your question", sender: self)
      }
    }

  }



}
