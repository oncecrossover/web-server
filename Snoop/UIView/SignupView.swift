//
//  SignupView.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class SignupView: UIView {

  let firstName: UITextField = {
    let view = InteractiveUITextField()
    view.awakeFromNib()
    view.placeholder = "First Name"
    view.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    view.font = UIFont.systemFontOfSize(16)
    view.borderStyle = .None
    view.clearButtonMode = .WhileEditing
    return view
  }()

  let lastName: UITextField = {
    let view = InteractiveUITextField()
    view.awakeFromNib()
    view.placeholder = "Last Name"
    view.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    view.borderStyle = .None
    view.clearButtonMode = .WhileEditing
    view.font = UIFont.systemFontOfSize(16)
    return view
  }()

  let middleLine: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0)
    return line
  }()

  let firstUnderline: UIView = {
    let underline = UIView()
    underline.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0)
    underline.translatesAutoresizingMaskIntoConstraints = false
    return underline
  }()

  let secondUnderline: UIView = {
    let underline = UIView()
    underline.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0)
    underline.translatesAutoresizingMaskIntoConstraints = false
    return underline
  }()

  lazy var email: UITextField = {
    let email = InteractiveUITextField()
    email.awakeFromNib()
    email.translatesAutoresizingMaskIntoConstraints = false
    email.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    email.textAlignment = .Left
    email.placeholder = "Your Email"
    email.font = UIFont.systemFontOfSize(16)
    email.borderStyle = .None
    email.clearButtonMode = .WhileEditing
    email.keyboardType = .EmailAddress
    email.autocapitalizationType = .None
    return email
  }()

  lazy var password: UITextField = {
    let password = InteractiveUITextField()
    password.awakeFromNib()
    password.translatesAutoresizingMaskIntoConstraints = false
    password.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    password.textAlignment = .Left
    password.font = UIFont.systemFontOfSize(16)
    password.placeholder = "Password"
    password.secureTextEntry = true
    password.borderStyle = .None
    password.clearButtonMode = .WhileEditing
    password.autocapitalizationType = .None
    return password
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(firstName)
    addSubview(middleLine)
    addSubview(lastName)
    addSubview(firstUnderline)
    addSubview(email)
    addSubview(secondUnderline)
    addSubview(password)

    // Setup Constraints
    addConstraintsWithFormat("H:|-14-[v0]-0-[v1(1)]-14-[v2]|", views: firstName, middleLine, lastName)
    addConstraintsWithFormat("H:|[v0]|", views: firstUnderline)
    addConstraintsWithFormat("H:|[v0]|", views: secondUnderline)
    addConstraintsWithFormat("V:|[v0]-0-[v1(1)]-0-[v2]-0-[v3(1)]-0-[v4]|", views: firstName, firstUnderline, email, secondUnderline, password)
    addConstraintsWithFormat("V:|[v0]", views: middleLine)
    addConstraintsWithFormat("V:|[v0]", views: lastName)
    middleLine.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    firstName.heightAnchor.constraintEqualToAnchor(email.heightAnchor).active = true
    email.heightAnchor.constraintEqualToAnchor(password.heightAnchor).active = true
    firstName.heightAnchor.constraintEqualToAnchor(middleLine.heightAnchor).active = true
    lastName.heightAnchor.constraintEqualToAnchor(middleLine.heightAnchor).active = true
    addConstraintsWithFormat("H:|-14-[v0]|", views: email)
    addConstraintsWithFormat("H:|-14-[v0]|", views: password)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
