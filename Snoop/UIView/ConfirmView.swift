//
//  ConfirmView.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/30/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class ConfirmView: UIView {
  let check: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "confirm")
    view.contentMode = .scaleAspectFill
    return view
  }()

  let message: UILabel = {
    let message = UILabel()
    message.font = UIFont.systemFont(ofSize: 14)
    message.textColor = UIColor.white
    message.textAlignment = .center
    return message
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor(white: 0, alpha: 0.7)
    layer.cornerRadius = 8
    clipsToBounds = true
    addSubview(check)
    addSubview(message)
    addConstraintsWithFormat("V:|-15-[v0(28)]-6-[v1(17)]", views: check, message)
    addConstraintsWithFormat("H:|-2-[v0]-2-|", views: message)
    check.widthAnchor.constraint(equalToConstant: 28).isActive = true
    check.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
  }

  func setMessage(_ msg: String) {
    message.text = msg
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
