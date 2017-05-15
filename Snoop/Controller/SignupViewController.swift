//
//  SignupViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit
import TwitterKit

class SignupViewController: UIViewController {

  var loginViewController: LoginViewController?

  let iconView: IconView = {
    let iconView = IconView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    return iconView
  }()

  let signupView: SignupView = {
    let view = SignupView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 8
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0).cgColor
    view.clipsToBounds = true
    return view
  }()

  lazy var signupButton: UIButton = {
    let button = UIButton()
    button.setTitle("Sign Up", for: UIControlState())
    button.backgroundColor = UIColor.defaultColor()
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var loginLink: UIButton = {
    let link = UIButton()
    link.setTitle("Log In", for: UIControlState())
    link.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    link.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    link.backgroundColor = UIColor.white
    link.translatesAutoresizingMaskIntoConstraints = false
    link.addTarget(self, action: #selector(loginLinkTapped), for: .touchUpInside)
    return link
  }()

  lazy var twitterLoginButton: TWTRLogInButton = {
    let button = TWTRLogInButton { (session, error) in
      if (error != nil) {
        print(error!)
      }
      let client = TWTRAPIClient.withCurrentUser()
      let request = client.urlRequest(withMethod: "GET",
                                      url: "https://api.twitter.com/1.1/account/verify_credentials.json",
                                      parameters: ["include_email": "true", "skip_status": "true"],
                                      error: nil)

      client.sendTwitterRequest(request) {response, data, connectionError in
        do {
          if let dict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
            // retrieve user's email
          }
        } catch let error as NSError {
          print(error.localizedDescription)
        }

      }
    }
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.loginMethods = [.webBased]
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white

    view.addSubview(iconView)
    view.addSubview(signupView)
    view.addSubview(signupButton)
    view.addSubview(loginLink)
    view.addSubview(twitterLoginButton)

    // Setup Icon View
    iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    iconView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    iconView.heightAnchor.constraint(equalToConstant: 120).isActive = true
    iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true

    // Setup email and password fields
    signupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
    signupView.heightAnchor.constraint(equalToConstant: 135).isActive = true
    signupView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20).isActive = true
    signupView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

    // Setup signup Button
    signupButton.topAnchor.constraint(equalTo: signupView.bottomAnchor, constant: 10).isActive = true
    signupButton.leadingAnchor.constraint(equalTo: signupView.leadingAnchor).isActive = true
    signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    signupButton.heightAnchor.constraint(equalToConstant: 45).isActive = true

    // Setup login link
    loginLink.leadingAnchor.constraint(equalTo: signupButton.leadingAnchor).isActive = true
    loginLink.widthAnchor.constraint(equalToConstant: 60).isActive = true
    loginLink.heightAnchor.constraint(equalToConstant: 30).isActive = true
    loginLink.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 8).isActive = true

    // Setup twitter button
    view.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: twitterLoginButton)
    view.addConstraintsWithFormat("V:[v0]-20-[v1(45)]", views: loginLink, twitterLoginButton)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }

  func signupButtonTapped() {
    let utility = UIUtility()
    let userModule = User()
    let userEmail = signupView.email.text!
    let userPassword = signupView.password.text!
    let name = signupView.firstName.text! + " " + signupView.lastName.text!

    //check for empty field
    if (userEmail.isEmpty || userPassword.isEmpty || name.isEmpty)
    {
      //Display alert message
      utility.displayAlertMessage("all fields are required", title: "Alert", sender: self)
      return
    }

    //Check for valid email address
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

    if (!emailTest.evaluate(with: userEmail)) {
      utility.displayAlertMessage("Email address invalid", title: "Alert", sender: self)
      return
    }

    if (userPassword.characters.count < 6) {
      utility.displayAlertMessage("Password must be at least 6 character long", title: "Alert", sender: self)
      return
    }

    // Check if the email already exists
    userModule.getUser(userEmail) { user in
      if (user.count > 0) {
        DispatchQueue.main.async {
          utility.displayAlertMessage("Email \(userEmail) already exists", title: "Alert", sender: self)
        }
      }
      else {
        var resultMessage = ""
        let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Saving your Info...")
        userModule.createUser(userEmail, userPassword: userPassword, fullName: name) { result in
          if let uid = result["uid"] as? Int {
            activityIndicator.hide(animated: true)
            DispatchQueue.main.async {
              UserDefaults.standard.set(true, forKey: "shouldGiftUser")
              UserDefaults.standard.synchronize()
              let vc = InterestPickerViewController()
              vc.uid = uid
              self.navigationController?.pushViewController(vc, animated: true)
            }

          }
          else {
            resultMessage = result["error"] as! String
            activityIndicator.hide(animated: true)
            // Display failure message
            let myAlert = UIAlertController(title: "Error", message: resultMessage, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            myAlert.addAction(okAction)
            OperationQueue.main.addOperation {
              self.present(myAlert, animated: true, completion: nil)
            }
          }
        }
      }
    }
  }

  func loginLinkTapped() {
    if (loginViewController != nil) {
      _ = self.navigationController?.popViewController(animated: true)
    }
    else {
      let vc = LoginViewController()
      vc.signupViewController = self
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}
