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
    loginView.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0).cgColor
    return loginView
  }()

  lazy var loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("Log In", for: UIControlState())
    button.backgroundColor = UIColor.defaultColor()
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var signupLink: UIButton = {
    let link = UIButton()
    link.setTitle("Sign Up", for: UIControlState())
    link.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    link.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    link.backgroundColor = UIColor.white
    link.translatesAutoresizingMaskIntoConstraints = false
    link.addTarget(self, action: #selector(signupLinkTapped), for: .touchUpInside)
    return link
  }()

  lazy var forgetPasswordLink: UIButton = {
    let link = UIButton()
    link.setTitleColor(UIColor.red, for: UIControlState())
    link.setTitle("Forget Password?", for: UIControlState())
    link.backgroundColor = UIColor.white
    link.translatesAutoresizingMaskIntoConstraints = false
    link.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    link.addTarget(self, action: #selector(forgetPasswordLinkTapped), for: .touchUpInside)
    return link
  }()

  //160
  let orLabel: UILabel = {
    let label = UILabel()
    label.text = "Or Log in using Twitter"
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 16)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = UIColor.white

    view.addSubview(iconView)
    view.addSubview(loginView)
    view.addSubview(loginButton)
    view.addSubview(signupLink)
    view.addSubview(forgetPasswordLink)
//    view.addSubview(orLabel)

    // Setup Icon View
    iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    iconView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    iconView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true

    // Setup email and password fields
    loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
    loginView.heightAnchor.constraint(equalToConstant: 90).isActive = true
    loginView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20).isActive = true
    loginView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

    // Setup login button
    loginButton.topAnchor.constraint(equalTo: loginView.bottomAnchor, constant: 10).isActive = true
    loginButton.leadingAnchor.constraint(equalTo: loginView.leadingAnchor).isActive = true
    loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginButton.heightAnchor.constraint(equalToConstant: 45).isActive = true

    // Setup signup link
    signupLink.leadingAnchor.constraint(equalTo: loginButton.leadingAnchor).isActive = true
    signupLink.widthAnchor.constraint(equalToConstant: 60).isActive = true
    signupLink.heightAnchor.constraint(equalToConstant: 30).isActive = true
    signupLink.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8).isActive = true

    // Setup forget password link
    forgetPasswordLink.topAnchor.constraint(equalTo: signupLink.topAnchor).isActive = true
    forgetPasswordLink.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor).isActive = true
    forgetPasswordLink.heightAnchor.constraint(equalTo: signupLink.heightAnchor).isActive = true
    forgetPasswordLink.widthAnchor.constraint(equalToConstant: 120).isActive = true

    // Setup or Label
//    orLabel.topAnchor.constraintEqualToAnchor(loginButton.bottomAnchor, constant: 160).active = true
//    orLabel.heightAnchor.constraintEqualToConstant(20).active = true
//    orLabel.leadingAnchor.constraintEqualToAnchor(loginButton.leadingAnchor).active = true
//    orLabel.centerXAnchor.constraintEqualToAnchor(loginButton.centerXAnchor).active = true
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        UserDefaults.standard.set(userEmail, forKey: "email")
        UserDefaults.standard.set(true, forKey:"isUserSignedUp")
        UserDefaults.standard.synchronize()
        if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") {
          userModule.updateDeviceToken(userEmail, token: deviceToken) { result in
            DispatchQueue.main.async {
              activityIndicator.hide(animated: true)
              self.dismiss(animated: true, completion: nil)
            }
          }
        }
        else {
          DispatchQueue.main.async {
            activityIndicator.hide(animated: true)
            let application = UIApplication.shared
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            self.dismiss(animated: true) {
              appDelegate.registerForPushNotifications(application)
            }
          }
        }
      }
      else {
        OperationQueue.main.addOperation {
          activityIndicator.hide(animated: true)
          utility.displayAlertMessage(displayMessage, title: "Alert", sender: self)
        }
      }
    }
  }

  func signupLinkTapped() {
    if (signupViewController != nil) {
      _ = self.navigationController?.popViewController(animated: true)
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
