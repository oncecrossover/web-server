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

  func initView() {
    self.askButton.backgroundColor = UIColor.defaultColor()
    var text = "$\(profileInfo.rate) to ask"
    if (profileInfo.rate == 0) {
      text = "Free to ask"
    }
    self.askButton.setTitle(text, forState: .Normal)
    self.aboutLabel.text = profileInfo.about
    self.aboutLabel.font = UIFont.systemFontOfSize(12)

    self.nameLabel.text = profileInfo.name
    self.nameLabel.font = UIFont.systemFontOfSize(14)

    self.titleLabel.text = profileInfo.title
    self.titleLabel.font = UIFont.systemFontOfSize(12)
    self.titleLabel.textColor = UIColor.secondaryTextColor()

    if let avatarUrl = profileInfo.avatarUrl {
      self.profilePhoto.sd_setImageWithURL(NSURL(string: avatarUrl))
    }
    else {
      self.profilePhoto.image = UIImage(named: "default")
    }

    self.questionView.layer.borderWidth = 1
    self.questionView.layer.borderColor = UIColor.lightGrayColor().CGColor
    self.questionView.layer.cornerRadius = 4
    self.questionView.clipsToBounds = true

    // Mimic a palceholder for text view
    self.questionView.text = placeholder
    self.questionView.textColor = UIColor.secondaryTextColor()
    self.questionView.font = UIFont.systemFontOfSize(13)

    self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(AskViewController.dismissKeyboard(_:))))
  }


  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  func textViewDidBeginEditing(textView: UITextView) {
    if (self.questionView.textColor == UIColor.secondaryTextColor()) {
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
      self.questionView.textColor = UIColor.secondaryTextColor()
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
  @IBAction func askButtonTapped(sender: AnyObject) {
    if (questionView.text! == placeholder) {
      utility.displayAlertMessage("questions cannot be empty", title: "Alert", sender: self)
    }
    else {
      self.performSegueWithIdentifier("askToPayment", sender: self)
    }
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
