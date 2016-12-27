//
//  AskViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/30/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class AskViewController: UIViewController, UITextViewDelegate {

  var profileInfo:DiscoverModel!

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var profilePhoto: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var aboutLabel: UILabel!
  @IBOutlet weak var questionView: UITextView!
  @IBOutlet weak var nameLabel: UILabel!

  @IBOutlet weak var askButton: UIButton!

  var contentOffset: CGPoint = CGPointZero
  var placeholder: String = "Pay to ask this celebrity question. No answer, no charge. If someone snoops the recorded answer, you will get a cut of the fee"

  var questionModule = Question()
  var utility = UIUtility()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initView()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let originalImage = UIImage(named: "ask")
    self.askButton.layoutIfNeeded()
    let x = self.askButton.frame.size.width * 0.3
    let y = self.askButton.frame.size.height * 0.3
    let textColor = UIColor.whiteColor()
    let textFont = UIFont.systemFontOfSize(18)
    let textPoint = CGPointMake(x, y)
    var text = "$\(profileInfo.rate) to ask"
    if (profileInfo.rate == 0.0) {
      text = "Free to ask"
    }

    self.askButton.setImage(utility.addTextToImage(text, inImage: originalImage!, atPoint: textPoint,
      textColor: textColor, textFont: textFont), forState: .Normal)
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
    else {
      self.profilePhoto.image = UIImage(named: "default")
    }

    self.questionView.layer.borderWidth = 1
    self.questionView.layer.borderColor = UIColor.lightGrayColor().CGColor

    // Mimic a palceholder for text view
    self.questionView.text = placeholder
    self.questionView.textColor = UIColor.lightGrayColor()

    self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(AskViewController.dismissKeyboard(_:))))
  }


  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  func textViewDidBeginEditing(textView: UITextView) {
    if (self.questionView.textColor == UIColor.lightGrayColor()) {
      self.questionView.text = ""
      self.questionView.textColor = UIColor.blackColor()
    }

    self.scrollView.scrollEnabled = true
    self.contentOffset = self.scrollView.contentOffset
    self.scrollView.setContentOffset(CGPointMake(0, self.contentOffset.y + 120), animated: true)
  }

  func textViewDidEndEditing(textView: UITextView) {
    if (self.questionView.text.isEmpty) {
      self.questionView.text = placeholder
      self.questionView.textColor = UIColor.lightGrayColor()
    }
    
    self.scrollView.setContentOffset(self.contentOffset, animated: true)
  }

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "askToPayment") {
      let dvc = segue.destinationViewController as! ChargeViewController;
      let askerId = NSUserDefaults.standardUserDefaults().stringForKey("email")
      dvc.submittedQuestion = (amount: profileInfo.rate, type: "ASKED",
        question: questionView.text!, askerId: askerId!, responderId: profileInfo.uid)
      dvc.isSnooped = false
    }
  }

  func dismissKeyboard(sender:UIGestureRecognizer) {
    self.view.endEditing(true)
  }

}
