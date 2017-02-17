//
//  LoginViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/18/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  @IBOutlet weak var userEmailTextField: UITextField!
  @IBOutlet weak var userPasswordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!

  @IBOutlet weak var signupButton: UIButton!

  @IBOutlet weak var reminderLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    loginButton.enabled = false
    loginButton.layer.cornerRadius = 4
    loginButton.clipsToBounds = true
    userEmailTextField.addTarget(self, action: #selector(LoginViewController.checkFields(_:)), forControlEvents: .EditingChanged)
    userPasswordTextField.addTarget(self, action: #selector(LoginViewController.checkFields(_:)), forControlEvents: .EditingChanged)
    signupButton.enabled = true
    signupButton.layer.cornerRadius = 4
    signupButton.clipsToBounds = true

    reminderLabel.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)
  }
  var utility = UIUtility()

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  func checkFields(sender: UITextField) {
    guard
      let email = userEmailTextField.text where !email.isEmpty,
      let password = userPasswordTextField.text where !password.isEmpty
    else {
      return
    }

    self.loginButton.enabled = true
  }

  @IBAction func LoginButtonTapped(sender: AnyObject) {
    let userEmail = userEmailTextField.text!
    let userPassword = userPasswordTextField.text!

    dismissKeyboard()
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Signing In...")

    let userModule = User()
    userModule.signinUser(userEmail, password: userPassword) { displayMessage in
      if (displayMessage.isEmpty) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().setObject(userEmail, forKey: "email")
        NSUserDefaults.standardUserDefaults().synchronize()
        if let deviceToken = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken") {
          userModule.updateDeviceToken(userEmail, token: deviceToken) { result in
            dispatch_async(dispatch_get_main_queue()) {
              activityIndicator.hideAnimated(true)
              self.performSegueWithIdentifier("unwindSegueToHome", sender: self)
            }
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()) {
            activityIndicator.hideAnimated(true)
            self.performSegueWithIdentifier("unwindSegueToHome", sender: self)
          }
        }
      }
      else {
        NSOperationQueue.mainQueue().addOperationWithBlock {
          activityIndicator.hideAnimated(true)
          self.utility.displayAlertMessage(displayMessage, title: "Alert", sender: self)
        }
      }
    }
    
  }


  func dismissKeyboard() {
    userEmailTextField.resignFirstResponder()
    userPasswordTextField.resignFirstResponder()
  }
  


}
