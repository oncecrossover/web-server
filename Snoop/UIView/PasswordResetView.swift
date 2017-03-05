//
//  PasswordResetView.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/3/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class PasswordResetView: UIView {
  lazy var tmpPassword: UITextField = {
    let password = InteractiveUITextField()
    password.awakeFromNib()
    password.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    password.textAlignment = .Left
    password.placeholder = "Temporary Password"
    password.font = UIFont.systemFontOfSize(16)
    password.borderStyle = .None
    password.clearButtonMode = .WhileEditing
    password.secureTextEntry = true
    password.autocapitalizationType = .None
    return password
  }()

  let underline: UIView = {
    let underline = UIView()
    underline.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0)
    return underline
  }()

  lazy var password: UITextField = {
    let password = InteractiveUITextField()
    password.awakeFromNib()
    password.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    password.textAlignment = .Left
    password.font = UIFont.systemFontOfSize(16)
    password.placeholder = "New Password"
    password.secureTextEntry = true
    password.borderStyle = .None
    password.clearButtonMode = .WhileEditing
    password.autocapitalizationType = .None
    return password
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(tmpPassword)
    addSubview(underline)
    addSubview(password)

    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: tmpPassword)
    addConstraintsWithFormat("H:|[v0]|", views: underline)
    addConstraintsWithFormat("H:|-14-[v0]-14-|", views: password)

    addConstraintsWithFormat("V:|[v0(45)]-0-[v1(1)]-0-[v2(45)]|", views: tmpPassword, underline, password)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
