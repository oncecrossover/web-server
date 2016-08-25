//
//  SendEmailViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/24/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController{

  @IBOutlet weak var email: UITextField!
  @IBOutlet weak var tmpPassword: UITextField!
  @IBOutlet weak var newPassword: UITextField!

  @IBOutlet weak var sendButton: RoundCornerButton!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var underline1: UIView!
  @IBOutlet weak var underline2: UIView!

  var utility = UIUtility()
  var generics = Generics()
  var userModule = User()

  override func viewDidLoad() {
    super.viewDidLoad()
    togglePasswordView(true)
    sendButton.setImage(UIImage(named: "sendEmailDisabled"), forState: .Disabled)
    sendButton.setImage(UIImage(named: "sendEmailEnabled"), forState: .Normal)
    sendButton.enabled = false
    email.addTarget(self, action: "checkEmail:", forControlEvents: .EditingChanged)

    // Do any additional setup after loading the view.
  }

  func togglePasswordView(hidden: Bool) {
    tmpPassword.hidden = hidden
    newPassword.hidden = hidden
    saveButton.hidden = hidden
    saveButton.awakeFromNib()
    underline1.hidden = hidden
    underline2.hidden = hidden
  }

  func checkEmail(sender: UITextField) {
    let emailText = email.text!
    if (emailText.isEmpty) {
      return
    }

    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    if (!emailTest.evaluateWithObject(emailText)) {
      return
    }

    sendButton.enabled = true
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
  @IBAction func saveButtonTapped(sender: AnyObject) {
    let tmpPwd = tmpPassword.text!
    let newPwd = newPassword.text!
    if (newPwd.characters.count < 6) {
      utility.displayAlertMessage("Password must be at least 6 characters long", title: "Alert", sender: self)
      return
    }

    let activityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: false)
    activityIndicator.label.text = "Updating Password..."
    activityIndicator.backgroundColor = UIColor.whiteColor()
    activityIndicator.layer.borderWidth = 1
    activityIndicator.layer.borderColor = UIColor.lightGrayColor().CGColor
    activityIndicator.userInteractionEnabled = false

    let myUrl = NSURL(string: "http://localhost:8080/resetpwd/" + email.text!)
    let jsonData = ["tempPwd" : tmpPwd, "newPwd" : newPwd]
    generics.updateObject(myUrl!, jsonData: jsonData) {result in
      if (result.isEmpty) {
        dispatch_sync(dispatch_get_main_queue()){
          activityIndicator.hideAnimated(true)
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      }
      else {
        dispatch_async(dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.utility.displayAlertMessage("Failed to update password. Please try again later", title: "Alert", sender: self)
        }
      }
    }
  }

  @IBAction func sendEmailButtonTapped(sender: AnyObject) {
    let activityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: false)
    activityIndicator.label.text = "Sending..."
    activityIndicator.label.textColor = UIColor.blackColor()
    activityIndicator.userInteractionEnabled = false

    //Check if the email address exists in our system
    userModule.getUser(email.text!) { user in
      if let _ = user["uid"] as? String {
        let URI = "http://localhost:8080/temppwds"
        let jsonData = ["uid" : self.email.text!]
        self.generics.createObject(URI, jsonData: jsonData) { result in
          if (result.isEmpty) {
            dispatch_async(dispatch_get_main_queue()) {
              activityIndicator.hideAnimated(true)
              self.togglePasswordView(false)
              self.utility.displayAlertMessage("Please check your email and follow instructions to reset password", title: "Recovery Email Sent", sender: self)
            }
          }
          else {
            dispatch_async(dispatch_get_main_queue()) {
              activityIndicator.hideAnimated(true)
              self.utility.displayAlertMessage("Email sending failed. Please try again later", title: "Alert", sender: self)
            }
          }
        }
      }
      else {
        dispatch_async(dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.utility.displayAlertMessage("Email \(self.email.text!) doesn't exist in our system", title: "Alert", sender: self)
        }
      }
    }
  }
}
