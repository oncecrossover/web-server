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
    message.textAlignment = .center
    message.font = UIFont.systemFont(ofSize: 18)
    message.text = "Welcome to Snoop"
    return message
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(icon)
    addSubview(message)

    // Setup constraints
    icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
    icon.widthAnchor.constraint(equalToConstant: 68).isActive = true
    icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
    message.heightAnchor.constraint(equalToConstant: 40).isActive = true
    message.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10).isActive = true
    message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    message.widthAnchor.constraint(equalToConstant: 300).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
