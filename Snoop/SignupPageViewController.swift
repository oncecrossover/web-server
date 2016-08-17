//
//  SignupPageViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/18/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class SignupPageViewController: UIViewController {
  
  @IBOutlet weak var userEmailTextField: UITextField!

  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var userPasswordTextField: UITextField!
  var userModule = User()
  var utilityModule = UIUtility()
  override func viewDidLoad() {
    super.viewDidLoad()

    signupButton.enabled = false
    signupButton.setImage(UIImage(named: "disabledSignup"), forState: .Disabled)
    signupButton.setImage(UIImage(named: "enabledSignup"), forState: .Normal)

    userNameTextField.addTarget(self, action: "checkFields:", forControlEvents: .EditingChanged)
    userEmailTextField.addTarget(self, action: "checkFields:", forControlEvents: .EditingChanged)
    userPasswordTextField.addTarget(self, action: "checkFields:", forControlEvents: .EditingChanged)
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  func checkFields(sender: UITextField) {
    guard
      let name = userNameTextField.text where !name.isEmpty,
      let email = userEmailTextField.text where !email.isEmpty,
      let password = userPasswordTextField.text where !password.isEmpty
      else {
        return
    }

    self.signupButton.enabled = true
  }
  
  @IBAction func goToLoginTapped(sender: AnyObject) {
    dismissKeyboard()
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func JoinbuttonTapped(sender: AnyObject) {
    
    let userEmail = userEmailTextField.text!
    let userPassword = userPasswordTextField.text!
    let name = userNameTextField.text!

    dismissKeyboard()
    
    //check for empty field
    if (userEmail.isEmpty || userPassword.isEmpty || name.isEmpty)
    {
      //Display alert message
      utilityModule.displayAlertMessage("all fields are required", title: "OK", sender: self)
      return
    }
    
    var resultMessage = ""
    userModule.createUser(userEmail, userPassword: userPassword, fullName: name) { resultString in
      if (resultString.isEmpty) {
        resultMessage = "Registration is successful"
      }
      else {
        resultMessage = resultString
      }
      
      //Display success message
      let myAlert = UIAlertController(title: "Alert", message: resultMessage, preferredStyle: UIAlertControllerStyle.Alert)
      let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ action in
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      
      myAlert.addAction(okAction)
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.presentViewController(myAlert, animated: true, completion: nil)
      }
      
    }
    
  }

  func dismissKeyboard() {
    userEmailTextField.resignFirstResponder()
    userPasswordTextField.resignFirstResponder()
    userNameTextField.resignFirstResponder()
  }
}
