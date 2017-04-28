//
//  CustomNavigationView.swift
//  Snoop
//
//  Created by Bowen Zhang on 4/28/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class CustomNavigationView: UIView {
  let logo: UIImageView = {
    let logo = UIImageView()
    logo.contentMode = .scaleAspectFill
    logo.image = UIImage(named: "logo")
    logo.translatesAutoresizingMaskIntoConstraints = false
    return logo
  }()

  let coinButtonView: CoinButtonView = {
    let view = CoinButtonView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let underline: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor.lightGray
    return line
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    backgroundColor = UIColor.white
    addSubview(logo)
    addSubview(coinButtonView)
    addSubview(underline)

    logo.widthAnchor.constraint(equalToConstant: 70).isActive = true
    logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    logo.heightAnchor.constraint(equalToConstant: 20).isActive = true
    logo.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10).isActive = true

    coinButtonView.widthAnchor.constraint(equalToConstant: 55).isActive = true
    coinButtonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
    coinButtonView.heightAnchor.constraint(equalToConstant: 18).isActive = true
    coinButtonView.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true

    addConstraintsWithFormat("H:|[v0]|", views: underline)
    underline.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    underline.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
