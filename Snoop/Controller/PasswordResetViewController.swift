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
  var uid:Int?

//  lazy var backButton: UIButton = {
//    let button = UIButton()
//    button.setTitle("<", for: UIControlState())
//    button.setTitleColor(UIColor.black, for: UIControlState())
//    button.backgroundColor = UIColor.white
//    button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//    return button
//  }()
//
//  let heading: UILabel = {
//    let title = UILabel()
//    title.text = "Forgot Password"
//    title.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.8)
//    title.textAlignment = .center
//    title.font = UIFont.systemFont(ofSize: 18)
//    return title
//  }()

  let note: UILabel = {
    let note = UILabel()
    note.numberOfLines = 3
    note.text = "A temporary password will be sent to your email. Please log in with temporary password and update password."
    note.font = UIFont.systemFont(ofSize: 14)
    note.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.6)
    return note
  }()

  lazy var email: UITextField = {
    let email = InteractiveUITextField()
    email.awakeFromNib()
    email.borderStyle = .roundedRect
    email.clipsToBounds = true
    email.placeholder = "Your Email"
    email.autocapitalizationType = .none
    email.keyboardType = .emailAddress
    email.addTarget(self, action: #selector(PasswordResetViewController.checkEmail), for: .editingChanged)
    return email
  }()

  lazy var sendButton: UIButton = {
    let button = CustomButton()
    button.setTitle("Send", for: UIControlState())
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(sendEmailButtonTapped), for: .touchUpInside)
    return button
  }()

  let sentHeading: UILabel = {
    let label = UILabel()
    label.text = "Email Sent!"
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.8)
    return label
  }()

  let sentNote: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.6)
    label.font = UIFont.systemFont(ofSize: 14)
    label.text = "Please use temporary password to log in"
    return label
  }()

  lazy var passwordView: PasswordResetView = {
    let password = PasswordResetView()
    password.layer.borderWidth = 1
    password.layer.cornerRadius = 8
    password.clipsToBounds = true
    password.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0).cgColor
    password.tmpPassword.addTarget(self, action: #selector(PasswordResetViewController.checkPassword), for: .editingChanged)
    password.password.addTarget(self, action: #selector(PasswordResetViewController.checkPassword), for: .editingChanged)
    return password
  }()

  lazy var saveButton: UIButton = {
    let button = CustomButton()
    button.setTitle("Save", for: UIControlState())
    button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    self.navigationItem.title = "Forgot Password"
//    view.addSubview(backButton)
//    view.addSubview(heading)
    view.addSubview(note)
    view.addSubview(email)
    view.addSubview(sendButton)

    // Setup constraints
    view.addConstraintsWithFormat("V:|-104-[v0(51)]-52-[v1(45)]-19-[v2(45)]", views: note, email, sendButton)
//    view.addConstraintsWithFormat("H:|-17-[v0(18)]", views: backButton)

//    heading.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//    heading.widthAnchor.constraint(equalToConstant: 226).isActive = true
//    backButton.centerYAnchor.constraint(equalTo: heading.centerYAnchor).isActive = true
//    backButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
    note.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    note.widthAnchor.constraint(equalToConstant: 270).isActive = true
    email.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    email.widthAnchor.constraint(equalToConstant: 270).isActive = true
    sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 270).isActive = true
    sendButton.isEnabled = false
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }

  func showPasswordResetView() {
//    heading.isHidden = true
    note.isHidden = true
    email.isHidden = true
    sendButton.isHidden = true

    view.addSubview(sentHeading)
    view.addSubview(sentNote)
    view.addSubview(passwordView)
    view.addSubview(saveButton)

    // setup constraints
    view.addConstraintsWithFormat("V:|-71-[v0(39)]-2-[v1(17)]-54-[v2(90)]-20-[v3(45)]", views: sentHeading, sentNote, passwordView, saveButton)
    sentHeading.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    sentHeading.widthAnchor.constraint(equalToConstant: 270).isActive = true
    sentNote.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    sentNote.widthAnchor.constraint(equalToConstant: 270).isActive = true
    passwordView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    passwordView.widthAnchor.constraint(equalToConstant: 270).isActive = true
    saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    saveButton.widthAnchor.constraint(equalToConstant: 270).isActive = true
    saveButton.isEnabled = false
  }

  func checkEmail() {
    let emailText = email.text!
    if (emailText.isEmpty) {
      return
    }

    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    if (!emailTest.evaluate(with: emailText)) {
      return
    }

    sendButton.isEnabled = true
  }

  func checkPassword() {
    guard
      let tmpPassword = passwordView.tmpPassword.text, !tmpPassword.isEmpty,
      let newPassword = passwordView.password.text, !newPassword.isEmpty
      else {
        return
    }

    saveButton.isEnabled = true
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }

  func backButtonTapped() {
    _ = self.navigationController?.popViewController(animated: true)
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

    let urlString = generics.HTTPHOST + "resetpwd/\(self.uid!)"
    let jsonData = ["tempPwd" : tmpPwd, "newPwd" : newPwd]
    generics.createObject(urlString, jsonData: jsonData as [String : AnyObject]) { result in
      let message = result
      if (result.isEmpty) {
        DispatchQueue.main.async{
          activityIndicator.hide(animated: true)
          self.dismiss(animated: true, completion: nil)
        }
      }
      else {
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
          self.utility.displayAlertMessage(message, title: "Alert", sender: self)
        }
      }
    }
  }

  func sendEmailButtonTapped() {
    dismissKeyboard()
    let activityIndicator = MBProgressHUD.showAdded(to: self.view, animated: false)
    activityIndicator.label.text = "Sending..."
    activityIndicator.label.textColor = UIColor.black
    activityIndicator.isUserInteractionEnabled = false

    //Check if the email address exists in our system
    userModule.getUser(email.text!) { users in
      if (users.count > 0) {
        let user = users[0] as! [String: AnyObject]
        let URI = self.generics.HTTPHOST + "temppwds"
        self.uid = user["uid"] as? Int
        let jsonData = ["uname" : self.email.text!]
        self.generics.createObject(URI, jsonData: jsonData as [String : AnyObject]) { result in
          if (result.isEmpty) {
            DispatchQueue.main.async {
              activityIndicator.hide(animated: true)
              self.showPasswordResetView()
            }
          }
          else {
            DispatchQueue.main.async {
              activityIndicator.hide(animated: true)
              self.utility.displayAlertMessage("Email sending failed. Please try again later", title: "Alert", sender: self)
            }
          }
        }
      }
      else {
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
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
