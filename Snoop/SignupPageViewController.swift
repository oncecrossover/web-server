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
    signupButton.layer.cornerRadius = 4
    signupButton.clipsToBounds = true

    userNameTextField.addTarget(self, action: #selector(SignupPageViewController.checkFields(_:)), forControlEvents: .EditingChanged)
    userEmailTextField.addTarget(self, action: #selector(SignupPageViewController.checkFields(_:)), forControlEvents: .EditingChanged)
    userPasswordTextField.addTarget(self, action: #selector(SignupPageViewController.checkFields(_:)), forControlEvents: .EditingChanged)
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
      utilityModule.displayAlertMessage("all fields are required", title: "Alert", sender: self)
      return
    }

    //Check for valid email address
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

    if (!emailTest.evaluateWithObject(userEmail)) {
      utilityModule.displayAlertMessage("Email address invalid", title: "Alert", sender: self)
      return
    }

    if (userPassword.characters.count < 6) {
      utilityModule.displayAlertMessage("Password must be at least 6 character long", title: "Alert", sender: self)
      return
    }

    //Check if the email already exists
    userModule.getUser(userEmail) { user in
      if let _ = user["uid"] as? String {
        dispatch_async(dispatch_get_main_queue()) {
          self.utilityModule.displayAlertMessage("Email \(userEmail) already exists", title: "Alert", sender: self)
        }
      }
      else {
        var resultMessage = ""
        self.userModule.createUser(userEmail, userPassword: userPassword, fullName: name) { resultString in
          if (resultString.isEmpty) {
            resultMessage = "Registration is successful"
          }
          else {
            resultMessage = resultString
          }

          //Display success message
          let myAlert = UIAlertController(title: "OK", message: resultMessage, preferredStyle: UIAlertControllerStyle.Alert)
          let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ action in
            self.performSegueWithIdentifier("signupToTutorial", sender: self)
          }

          myAlert.addAction(okAction)
          NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(myAlert, animated: true, completion: nil)
          }
        }
      }
    }
  }

  func dismissKeyboard() {
    userEmailTextField.resignFirstResponder()
    userPasswordTextField.resignFirstResponder()
    userNameTextField.resignFirstResponder()
  }

  @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
    NSUserDefaults.standardUserDefaults().setObject(userEmailTextField.text!, forKey: "email")
    NSUserDefaults.standardUserDefaults().synchronize()
    self.performSegueWithIdentifier("unwindSegueToHome", sender: self)
  }
}
