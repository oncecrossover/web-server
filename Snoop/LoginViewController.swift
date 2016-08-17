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


  override func viewDidLoad() {
    super.viewDidLoad()
    loginButton.setImage(UIImage(named: "disabledLogin"), forState: .Disabled)
    loginButton.setImage(UIImage(named: "enabledLogin"), forState: .Normal)
    loginButton.enabled = false
    userEmailTextField.addTarget(self, action: "checkFields:", forControlEvents: .EditingChanged)
    userPasswordTextField.addTarget(self, action: "checkFields:", forControlEvents: .EditingChanged)
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
    
    let userModule = User()
    userModule.getUser(userEmail, password: userPassword) { displayMessage in
      if (displayMessage.isEmpty) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().setObject(userEmail, forKey: "email")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      else {
        NSOperationQueue.mainQueue().addOperationWithBlock {
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
