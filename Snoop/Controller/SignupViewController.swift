//
//  SignupViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

  var loginViewController: NewLoginViewController?

  let iconView: IconView = {
    let iconView = IconView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    return iconView
  }()

  let signupView: SignupView = {
    let view = SignupView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 8
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0).CGColor
    view.clipsToBounds = true
    return view
  }()

  lazy var signupButton: UIButton = {
    let button = UIButton()
    button.setTitle("Sign Up", forState: .Normal)
    button.backgroundColor = UIColor.defaultColor()
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(signupButtonTapped), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var loginLink: UIButton = {
    let link = UIButton()
    link.setTitle("Log In", forState: .Normal)
    link.setTitleColor(UIColor.defaultColor(), forState: .Normal)
    link.titleLabel?.font = UIFont.systemFontOfSize(12)
    link.backgroundColor = UIColor.whiteColor()
    link.translatesAutoresizingMaskIntoConstraints = false
    link.addTarget(self, action: #selector(loginLinkTapped), forControlEvents: .TouchUpInside)
    return link
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.whiteColor()

    view.addSubview(iconView)
    view.addSubview(signupView)
    view.addSubview(signupButton)
    view.addSubview(loginLink)

    // Setup Icon View
    iconView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    iconView.widthAnchor.constraintEqualToConstant(300).active = true
    iconView.heightAnchor.constraintEqualToConstant(120).active = true
    iconView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 50).active = true

    // Setup email and password fields
    signupView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 30).active = true
    signupView.heightAnchor.constraintEqualToConstant(135).active = true
    signupView.topAnchor.constraintEqualToAnchor(iconView.bottomAnchor, constant: 20).active = true
    signupView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true

    // Setup signup Button
    signupButton.topAnchor.constraintEqualToAnchor(signupView.bottomAnchor, constant: 10).active = true
    signupButton.leadingAnchor.constraintEqualToAnchor(signupView.leadingAnchor).active = true
    signupButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    signupButton.heightAnchor.constraintEqualToConstant(45).active = true

    // Setup login link
    loginLink.leadingAnchor.constraintEqualToAnchor(signupButton.leadingAnchor).active = true
    loginLink.widthAnchor.constraintEqualToConstant(60).active = true
    loginLink.heightAnchor.constraintEqualToConstant(30).active = true
    loginLink.topAnchor.constraintEqualToAnchor(signupButton.bottomAnchor, constant: 8).active = true
  }

  func signupButtonTapped() {
    let utility = UIUtility()
    let userModule = User()
    let userEmail = signupView.email.text!
    let userPassword = signupView.password.text!
    let name = signupView.firstName.text! + " " + signupView.lastName.text!

    //check for empty field
    if (userEmail.isEmpty || userPassword.isEmpty || name.isEmpty)
    {
      //Display alert message
      utility.displayAlertMessage("all fields are required", title: "Alert", sender: self)
      return
    }

    //Check for valid email address
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

    if (!emailTest.evaluateWithObject(userEmail)) {
      utility.displayAlertMessage("Email address invalid", title: "Alert", sender: self)
      return
    }

    if (userPassword.characters.count < 6) {
      utility.displayAlertMessage("Password must be at least 6 character long", title: "Alert", sender: self)
      return
    }

    // Check if the email already exists
    userModule.getUser(userEmail) { user in
      if let _ = user["uid"] as? String {
        dispatch_async(dispatch_get_main_queue()) {
          utility.displayAlertMessage("Email \(userEmail) already exists", title: "Alert", sender: self)
        }
      }
      else {
        var resultMessage = ""
        let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Saving your Info...")
        userModule.createUser(userEmail, userPassword: userPassword, fullName: name) { resultString in
          if (resultString.isEmpty) {
            activityIndicator.hideAnimated(true)
            dispatch_async(dispatch_get_main_queue()) {
              let vc = InterestPickerViewController()
              vc.email = userEmail
              self.navigationController?.pushViewController(vc, animated: true)
            }

          }
          else {
            resultMessage = resultString
            activityIndicator.hideAnimated(true)
            // Display failure message
            let myAlert = UIAlertController(title: "Error", message: resultMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            myAlert.addAction(okAction)
            NSOperationQueue.mainQueue().addOperationWithBlock {
              self.presentViewController(myAlert, animated: true, completion: nil)
            }
          }
        }
      }
    }
  }

  func loginLinkTapped() {
    if (loginViewController != nil) {
      self.navigationController?.popViewControllerAnimated(true)
    }
    else {
      let vc = NewLoginViewController()
      vc.signupViewController = self
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}
