//
//  LoginView.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class LoginView: UIView {
  lazy var email: UITextField = {
    let email = InteractiveUITextField()
    email.awakeFromNib()
    email.translatesAutoresizingMaskIntoConstraints = false
    email.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    email.textAlignment = .left
    email.placeholder = "Your Email"
    email.font = UIFont.systemFont(ofSize: 16)
    email.borderStyle = .none
    email.clearButtonMode = .whileEditing
    email.keyboardType = .emailAddress
    email.autocapitalizationType = .none
    email.autocorrectionType = .no
    return email
  }()

  let underline: UIView = {
    let underline = UIView()
    underline.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0)
    underline.translatesAutoresizingMaskIntoConstraints = false
    return underline
  }()

  lazy var password: UITextField = {
    let password = InteractiveUITextField()
    password.awakeFromNib()
    password.translatesAutoresizingMaskIntoConstraints = false
    password.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    password.textAlignment = .left
    password.font = UIFont.systemFont(ofSize: 16)
    password.placeholder = "Password"
    password.isSecureTextEntry = true
    password.borderStyle = .none
    password.clearButtonMode = .whileEditing
    password.autocapitalizationType = .none
    return password
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(email)
    addSubview(underline)
    addSubview(password)

    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: email)
    addConstraintsWithFormat("H:|[v0]|", views: underline)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: password)

    addConstraintsWithFormat("V:|[v0(45)]-0-[v1(1)]-0-[v2(45)]|", views: email, underline, password)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
