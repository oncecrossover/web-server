//
//  SendEmailViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/24/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController{
  var utility = UIUtility()
  var generics = Generics()
  var userModule = User()

  lazy var backButton: UIButton = {
    let button = UIButton()
    button.setTitle("<", forState: .Normal)
    button.setTitleColor(UIColor.blackColor(), forState: .Normal)
    button.backgroundColor = UIColor.whiteColor()
    button.addTarget(self, action: #selector(backButtonTapped), forControlEvents: .TouchUpInside)
    return button
  }()

  let heading: UILabel = {
    let title = UILabel()
    title.text = "Forgot Password"
    title.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.8)
    title.textAlignment = .Center
    title.font = UIFont.systemFontOfSize(18)
    return title
  }()

  let note: UILabel = {
    let note = UILabel()
    note.numberOfLines = 3
    note.text = "A temporary password will be sent to your email. Please log in with temporary password and update password."
    note.font = UIFont.systemFontOfSize(14)
    note.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.6)
    return note
  }()

  lazy var email: UITextField = {
    let email = InteractiveUITextField()
    email.awakeFromNib()
    email.borderStyle = .RoundedRect
    email.clipsToBounds = true
    email.placeholder = "Your Email"
    email.autocapitalizationType = .None
    email.keyboardType = .EmailAddress
    email.addTarget(self, action: #selector(PasswordResetViewController.checkEmail), forControlEvents: .EditingChanged)
    return email
  }()

  lazy var sendButton: UIButton = {
    let button = CustomButton()
    button.setTitle("Send", forState: .Normal)
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(sendEmailButtonTapped), forControlEvents: .TouchUpInside)
    return button
  }()

  let sentHeading: UILabel = {
    let label = UILabel()
    label.text = "Email Sent!"
    label.font = UIFont.systemFontOfSize(18)
    label.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.8)
    return label
  }()

  let sentNote: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.6)
    label.font = UIFont.systemFontOfSize(14)
    label.text = "Please use temporary password to log in"
    return label
  }()

  lazy var passwordView: PasswordResetView = {
    let password = PasswordResetView()
    password.layer.borderWidth = 1
    password.layer.cornerRadius = 8
    password.clipsToBounds = true
    password.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0).CGColor
    password.tmpPassword.addTarget(self, action: #selector(PasswordResetViewController.checkPassword), forControlEvents: .EditingChanged)
    password.password.addTarget(self, action: #selector(PasswordResetViewController.checkPassword), forControlEvents: .EditingChanged)
    return password
  }()

  lazy var saveButton: UIButton = {
    let button = CustomButton()
    button.setTitle("Save", forState: .Normal)
    button.addTarget(self, action: #selector(saveButtonTapped), forControlEvents: .TouchUpInside)
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()
    view.addSubview(backButton)
    view.addSubview(heading)
    view.addSubview(note)
    view.addSubview(email)
    view.addSubview(sendButton)

    // Setup constraints
    view.addConstraintsWithFormat("V:|-27-[v0(39)]-38-[v1(51)]-52-[v2(45)]-19-[v3(45)]", views: heading, note, email, sendButton)
    view.addConstraintsWithFormat("H:|-17-[v0(18)]", views: backButton)

    heading.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    heading.widthAnchor.constraintEqualToConstant(226).active = true
    backButton.centerYAnchor.constraintEqualToAnchor(heading.centerYAnchor).active = true
    backButton.widthAnchor.constraintEqualToConstant(18).active = true
    note.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    note.widthAnchor.constraintEqualToConstant(270).active = true
    email.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    email.widthAnchor.constraintEqualToConstant(270).active = true
    sendButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    sendButton.widthAnchor.constraintEqualToConstant(270).active = true
    sendButton.enabled = false
  }

  func showPasswordResetView() {
    heading.hidden = true
    note.hidden = true
    email.hidden = true
    sendButton.hidden = true

    view.addSubview(sentHeading)
    view.addSubview(sentNote)
    view.addSubview(passwordView)
    view.addSubview(saveButton)

    // setup constraints
    view.addConstraintsWithFormat("V:|-71-[v0(39)]-2-[v1(17)]-54-[v2(90)]-20-[v3(45)]", views: sentHeading, sentNote, passwordView, saveButton)
    sentHeading.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    sentHeading.widthAnchor.constraintEqualToConstant(270).active = true
    sentNote.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    sentNote.widthAnchor.constraintEqualToConstant(270).active = true
    passwordView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    passwordView.widthAnchor.constraintEqualToConstant(270).active = true
    saveButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    saveButton.widthAnchor.constraintEqualToConstant(270).active = true
    saveButton.enabled = false
  }

  func checkEmail() {
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

  func checkPassword() {
    guard
      let tmpPassword = passwordView.tmpPassword.text where !tmpPassword.isEmpty,
      let newPassword = passwordView.password.text where !newPassword.isEmpty
      else {
        return
    }

    saveButton.enabled = true
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  func backButtonTapped() {
    self.navigationController?.popViewControllerAnimated(true)
  }

  func saveButtonTapped() {
    dismissKeyboard()
    let tmpPwd = passwordView.tmpPassword.text!
    let newPwd = passwordView.password.text!
    if (newPwd.characters.count < 6) {
      utility.displayAlertMessage("Password must be at least 6 characters long", title: "Alert", sender: self)
      return
    }

    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Updating Password...")

    let urlString = generics.HTTPHOST + "resetpwd/" + email.text!
    let jsonData = ["tempPwd" : tmpPwd, "newPwd" : newPwd]
    generics.createObject(urlString, jsonData: jsonData) { result in
      let message = result
      if (result.isEmpty) {
        dispatch_async(dispatch_get_main_queue()){
          activityIndicator.hideAnimated(true)
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      }
      else {
        dispatch_async(dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.utility.displayAlertMessage(message, title: "Alert", sender: self)
        }
      }
    }
  }

  func sendEmailButtonTapped() {
    dismissKeyboard()
    let activityIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: false)
    activityIndicator.label.text = "Sending..."
    activityIndicator.label.textColor = UIColor.blackColor()
    activityIndicator.userInteractionEnabled = false

    //Check if the email address exists in our system
    userModule.getUser(email.text!) { user in
      if let _ = user["uid"] as? String {
        let URI = self.generics.HTTPHOST + "temppwds"
        let jsonData = ["uid" : self.email.text!]
        self.generics.createObject(URI, jsonData: jsonData) { result in
          if (result.isEmpty) {
            dispatch_async(dispatch_get_main_queue()) {
              activityIndicator.hideAnimated(true)
              self.showPasswordResetView()
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

  func dismissKeyboard() {
    email.resignFirstResponder()
    passwordView.tmpPassword.resignFirstResponder()
    passwordView.password.resignFirstResponder()
  }
}
