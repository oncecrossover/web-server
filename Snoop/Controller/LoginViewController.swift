//
//  NewLoginViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/19/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  var signupViewController: SignupViewController?

  let iconView: IconView = {
    let iconView = IconView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    return iconView
  }()

  let loginView: LoginView = {
    let loginView = LoginView()
    loginView.translatesAutoresizingMaskIntoConstraints = false
    loginView.layer.borderWidth = 1
    loginView.layer.cornerRadius = 8
    loginView.clipsToBounds = true
    loginView.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0).CGColor
    return loginView
  }()

  lazy var loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("Log In", forState: .Normal)
    button.backgroundColor = UIColor.defaultColor()
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(loginButtonTapped), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var signupLink: UIButton = {
    let link = UIButton()
    link.setTitle("Sign Up", forState: .Normal)
    link.setTitleColor(UIColor.defaultColor(), forState: .Normal)
    link.titleLabel?.font = UIFont.systemFontOfSize(12)
    link.backgroundColor = UIColor.whiteColor()
    link.translatesAutoresizingMaskIntoConstraints = false
    link.addTarget(self, action: #selector(signupLinkTapped), forControlEvents: .TouchUpInside)
    return link
  }()

  lazy var forgetPasswordLink: UIButton = {
    let link = UIButton()
    link.setTitleColor(UIColor.redColor(), forState: .Normal)
    link.setTitle("Forget Password?", forState: .Normal)
    link.backgroundColor = UIColor.whiteColor()
    link.translatesAutoresizingMaskIntoConstraints = false
    link.titleLabel?.font = UIFont.systemFontOfSize(12)
    link.addTarget(self, action: #selector(forgetPasswordLinkTapped), forControlEvents: .TouchUpInside)
    return link
  }()

  //160
  let orLabel: UILabel = {
    let label = UILabel()
    label.text = "Or Log in using Twitter"
    label.textAlignment = .Center
    label.font = UIFont.systemFontOfSize(16)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = UIColor.whiteColor()

    view.addSubview(iconView)
    view.addSubview(loginView)
    view.addSubview(loginButton)
    view.addSubview(signupLink)
    view.addSubview(forgetPasswordLink)
//    view.addSubview(orLabel)

    // Setup Icon View
    iconView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    iconView.widthAnchor.constraintEqualToConstant(300).active = true
    iconView.heightAnchor.constraintEqualToConstant(120).active = true
    iconView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 50).active = true

    // Setup email and password fields
    loginView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 30).active = true
    loginView.heightAnchor.constraintEqualToConstant(90).active = true
    loginView.topAnchor.constraintEqualToAnchor(iconView.bottomAnchor, constant: 20).active = true
    loginView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true

    // Setup login button
    loginButton.topAnchor.constraintEqualToAnchor(loginView.bottomAnchor, constant: 10).active = true
    loginButton.leadingAnchor.constraintEqualToAnchor(loginView.leadingAnchor).active = true
    loginButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    loginButton.heightAnchor.constraintEqualToConstant(45).active = true

    // Setup signup link
    signupLink.leadingAnchor.constraintEqualToAnchor(loginButton.leadingAnchor).active = true
    signupLink.widthAnchor.constraintEqualToConstant(60).active = true
    signupLink.heightAnchor.constraintEqualToConstant(30).active = true
    signupLink.topAnchor.constraintEqualToAnchor(loginButton.bottomAnchor, constant: 8).active = true

    // Setup forget password link
    forgetPasswordLink.topAnchor.constraintEqualToAnchor(signupLink.topAnchor).active = true
    forgetPasswordLink.trailingAnchor.constraintEqualToAnchor(loginButton.trailingAnchor).active = true
    forgetPasswordLink.heightAnchor.constraintEqualToAnchor(signupLink.heightAnchor).active = true
    forgetPasswordLink.widthAnchor.constraintEqualToConstant(120).active = true

    // Setup or Label
//    orLabel.topAnchor.constraintEqualToAnchor(loginButton.bottomAnchor, constant: 160).active = true
//    orLabel.heightAnchor.constraintEqualToConstant(20).active = true
//    orLabel.leadingAnchor.constraintEqualToAnchor(loginButton.leadingAnchor).active = true
//    orLabel.centerXAnchor.constraintEqualToAnchor(loginButton.centerXAnchor).active = true
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  func loginButtonTapped() {
    let userEmail = loginView.email.text!
    let userPassword = loginView.password.text!

    let utility = UIUtility()
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Signing In...")

    let userModule = User()
    userModule.signinUser(userEmail, password: userPassword) { displayMessage in
      if (displayMessage.isEmpty) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().setObject(userEmail, forKey: "email")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey:"isUserSignedUp")
        NSUserDefaults.standardUserDefaults().synchronize()
        if let deviceToken = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken") {
          userModule.updateDeviceToken(userEmail, token: deviceToken) { result in
            dispatch_async(dispatch_get_main_queue()) {
              activityIndicator.hideAnimated(true)
              self.dismissViewControllerAnimated(true, completion: nil)
            }
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()) {
            activityIndicator.hideAnimated(true)
            let application = UIApplication.sharedApplication()
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            self.dismissViewControllerAnimated(true) {
              appDelegate.registerForPushNotifications(application)
            }
          }
        }
      }
      else {
        NSOperationQueue.mainQueue().addOperationWithBlock {
          activityIndicator.hideAnimated(true)
          utility.displayAlertMessage(displayMessage, title: "Alert", sender: self)
        }
      }
    }
  }

  func signupLinkTapped() {
    if (signupViewController != nil) {
      self.navigationController?.popViewControllerAnimated(true)
    }
    else {
      let vc = SignupViewController()
      vc.loginViewController = self
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  func forgetPasswordLinkTapped() {
    self.navigationController?.pushViewController(PasswordResetViewController(), animated: true)
  }
}
