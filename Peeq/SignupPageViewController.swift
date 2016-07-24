//
//  SignupPageViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/18/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class SignupPageViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var userEmailTextField: UITextField!
  @IBOutlet weak var userConfirmPasswordTextField: UITextField!
  @IBOutlet weak var userPasswordTextField: UITextField!
  var userModule = User()
  var utilityModule = UIUtility()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  @IBAction func goToLoginTapped(sender: AnyObject) {
    dismissKeyboard()
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func JoinbuttonTapped(sender: AnyObject) {
    
    let userEmail = userEmailTextField.text!
    let userPassword = userPasswordTextField.text!
    let userConfirmPassword = userConfirmPasswordTextField.text!

    dismissKeyboard()
    
    //check for empty field
    if (userEmail.isEmpty || userPassword.isEmpty || userConfirmPassword.isEmpty)
    {
      //Display alert message
      utilityModule.displayAlertMessage("all fields are required", title: "OK", sender: self)
      return
    }
    
    //Check if password matches
    if (userPassword != userConfirmPassword)
    {
      //Display alert
      utilityModule.displayAlertMessage("passwords don't match", title: "OK", sender: self)
      return
    }
    
    
    var resultMessage = ""
    userModule.createUser(userEmail, userPassword: userPassword) { resultString in
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

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    dismissKeyboard()
    return true
  }

  func dismissKeyboard() {
    userEmailTextField.resignFirstResponder()
    userPasswordTextField.resignFirstResponder()
    userConfirmPasswordTextField.resignFirstResponder()
  }
}
