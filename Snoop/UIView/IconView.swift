//
//  IconView.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/19/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class IconView: UIView {
  let icon: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.image = UIImage(named: "icon")
    return icon
  }()

  let message: UILabel = {
    let message = UILabel()
    message.translatesAutoresizingMaskIntoConstraints = false
    message.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    message.textAlignment = .Center
    message.font = UIFont.systemFontOfSize(18)
    message.text = "Welcome to Snoop"
    return message
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(icon)
    addSubview(message)

    // Setup constraints
    icon.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    icon.topAnchor.constraintEqualToAnchor(topAnchor).active = true
    icon.widthAnchor.constraintEqualToConstant(68).active = true
    icon.heightAnchor.constraintEqualToAnchor(icon.widthAnchor).active = true
    message.heightAnchor.constraintEqualToConstant(40).active = true
    message.topAnchor.constraintEqualToAnchor(icon.bottomAnchor, constant: 10).active = true
    message.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    message.widthAnchor.constraintEqualToConstant(300).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}