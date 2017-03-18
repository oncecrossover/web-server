//
//  EarningsViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/16/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class EarningsViewController: UIViewController {
  var earning:Double!
  var contentOffset: CGPoint = CGPointZero
  let scrollView: UIScrollView = {
    let view = UIScrollView()
    view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    return view
  }()

  let slogan: UIImageView = {
    let slogan = UIImageView()
    slogan.contentMode = .ScaleAspectFill
    slogan.image = UIImage(named: "slogan")
    return slogan
  }()

  let explainer: UIImageView = {
    let explainer = UIImageView()
    explainer.contentMode = .ScaleAspectFill
    explainer.image = UIImage(named: "work")
    return explainer
  }()

  private lazy var input: EarningsView = {
    let view = EarningsView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setAmount(self.earning)
    view.updateButton.addTarget(self, action: #selector(updateButtonTapped), forControlEvents: .TouchUpInside)
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()
    self.navigationItem.title = "My Earnings"
    view.addSubview(scrollView)
    view.addConstraintsWithFormat("H:|[v0]|", views: scrollView)
    view.addConstraintsWithFormat("V:|[v0]|", views: scrollView)

    scrollView.addSubview(slogan)
    scrollView.addSubview(explainer)
    scrollView.addSubview(input)

    input.paypalEmail.delegate = self
    input.paypalEmail.addTarget(self, action: #selector(checkEmail), forControlEvents: .EditingChanged)

    scrollView.addConstraintsWithFormat("V:|[v0(100)]-2-[v1(196)]-6-[v2(140)]|", views: slogan, explainer, input)
    let width = Int(view.frame.width)
    scrollView.addConstraintsWithFormat("H:|[v0(\(width))]|", views: slogan)
    scrollView.addConstraintsWithFormat("H:|[v0]|", views: explainer)
    scrollView.addConstraintsWithFormat("H:|[v0]|", views: input)

    // Add keyboard notification
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EarningsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EarningsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.contentOffset = scrollView.contentOffset
  }
}

extension EarningsViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
// IB actions
extension EarningsViewController {
  func checkEmail(){
    //Check for valid email address
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

    if (!emailTest.evaluateWithObject(input.paypalEmail.text!)) {
      input.updateButton.enabled = false
    }
    else {
      input.updateButton.enabled = true
    }
  }

  func updateButtonTapped(){
    let util = UIUtility()
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let email = input.paypalEmail.text!
    User().updatePaypal(uid, paypalEmail: email) { result in
      if (result.isEmpty) {
        dispatch_async(dispatch_get_main_queue()) {
          util.displayAlertMessage("Thanks for updating your paypal email", title: "OK", sender: self)
        }
      }
      else {
        dispatch_async(dispatch_get_main_queue()) {
          util.displayAlertMessage("An error occurs when updating your email. Please try later", title: "Alert", sender: self)
        }
      }
    }
  }
}
//Handle keybord functions
extension EarningsViewController {
  func keyboardWillShow(notification: NSNotification)
  {
    //Need to calculate keyboard exact size due to Apple suggestions
    scrollView.scrollEnabled = true
    let info : NSDictionary = notification.userInfo!
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
    // We need to add 20 to count for the height of keyboard hint
    let keyboardHeight = keyboardSize!.height + 20

    var aRect : CGRect = scrollView.frame
    // We need to add 100 to count for the height of submitbutton and tabbar
    aRect.size.height = aRect.size.height + (self.tabBarController?.tabBar.frame.height)! - keyboardHeight
    let activeText = input.paypalEmail
      // pt is the lower left corner of the rectangular textfield or textview
    let pt = CGPointMake(activeText.frame.origin.x, activeText.frame.origin.y + activeText.frame.size.height)
    let ptInScrollView = activeText.convertPoint(pt, toView: scrollView)

    if (!CGRectContainsPoint(aRect, ptInScrollView))
    {
      // Compute the exact offset we need to scroll the view up
      let offset = ptInScrollView.y - (aRect.origin.y + aRect.size.height)
      scrollView.setContentOffset(CGPointMake(0, self.contentOffset.y + offset + 40), animated: true)
    }
  }

  func keyboardWillHide(notification: NSNotification)
  {
    self.view.endEditing(true)
    scrollView.setContentOffset(CGPointMake(0, self.contentOffset.y), animated: true)
  }

}
private class EarningsView: UIView {
  let title: UILabel = {
    let title = UILabel()
    title.text = "Total Earnings"
    title.textAlignment = .Center
    title.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
    title.textColor = UIColor(white: 0, alpha: 0.7)
    return title
  }()

  let amount: UILabel = {
    let amount = UILabel()
    amount.textColor = UIColor(white: 0, alpha: 0.7)
    amount.font = UIFont.boldSystemFontOfSize(20)
    amount.textAlignment = .Center
    return amount
  }()

  let paypalEmail: UITextField = {
    let email = UITextField()
    email.placeholder = "    Paypal Email"
    email.layer.cornerRadius = 4
    email.clipsToBounds = true
    email.layer.borderWidth = 1
    email.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0).CGColor
    email.keyboardType = .EmailAddress
    email.autocapitalizationType = .None
    email.returnKeyType = .Done
    return email
  }()

  lazy var updateButton: CustomButton = {
    let button = CustomButton()
    button.layer.cornerRadius = 4
    button.clipsToBounds = true
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.setTitle("Update", forState: .Normal)
    button.titleLabel?.font = UIFont.systemFontOfSize(14)
    button.enabled = false
    return button
  }()

  let note: UILabel = {
    let note = UILabel()
    note.textColor = UIColor(red: 111/255, green: 111/255, blue: 111/255, alpha: 0.7)
    note.font = UIFont.systemFontOfSize(11)
    note.text = "Your earnings will be transferred to your Paypal account on 1st of each month with a minimum threshold of $10."
    note.numberOfLines = 3
    return note
  }()

  func setAmount(earnings: Double) {
    amount.text = "$\(earnings)"
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.whiteColor()
    addSubview(title)
    addSubview(amount)
    addSubview(paypalEmail)
    addSubview(updateButton)
    addSubview(note)

    addConstraintsWithFormat("V:|-9-[v0(20)]-4-[v1(23)]-9-[v2(30)]-6-[v3(30)]", views: title, amount, paypalEmail, note)
    addConstraintsWithFormat("V:|-9-[v0(20)]-4-[v1(23)]-9-[v2(30)]-6-[v3(30)]", views: title, amount, updateButton, note)
    paypalEmail.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 11).active = true
    updateButton.leadingAnchor.constraintEqualToAnchor(paypalEmail.trailingAnchor, constant: 9).active = true
    updateButton.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -11).active = true
    updateButton.widthAnchor.constraintEqualToAnchor(paypalEmail.widthAnchor, multiplier: 0.4).active = true

//    addConstraintsWithFormat("H:|-11-[v0(\(emailWidth))]-9-[v1(\(buttonWidth))]", views: paypalEmail, updateButton)
    addConstraintsWithFormat("H:|-11-[v0]-11-|", views: note)
    title.widthAnchor.constraintEqualToConstant(200).active = true
    title.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    amount.widthAnchor.constraintEqualToAnchor(title.widthAnchor).active = true
    amount.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
