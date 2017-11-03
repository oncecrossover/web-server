//
//  FreeCoinsView.swift
//  Snoop
//
//  Created by Bowen Zhang on 4/27/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class FreeCoinsView: UIView {
  let title: UILabel = {
    let title = UILabel()
    title.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
    title.textAlignment = .center
    title.text = "Welcome to vInsider!"
    return title
  }()

  let message: UILabel = {
    let message = UILabel()
    message.text = "We have some free coins for you"
    message.textAlignment = .center
    message.font = UIFont.systemFont(ofSize: 15)
    return message
  }()

  let coinView: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "coin")
    view.contentMode = .scaleAspectFill
    return view
  }()

  let crossLabel: UILabel = {
    let label = UILabel()
    label.text = "X"
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 18)
    label.textColor = UIColor.black
    return label
  }()

  let numberLabel: UILabel = {
    let label = UILabel()
    label.text = "100"
    label.font = UIFont.boldSystemFont(ofSize: 24)
    label.textColor = UIColor.black
    return label
  }()

  let underline: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 204/255, green: 214/255, blue: 221/255, alpha: 1.0)
    return view
  }()

  lazy var claimButton: UIButton = {
    let button = UIButton()
    button.setTitle("Claim", for: UIControlState())
    button.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    addSubview(title)
    addSubview(message)
    addSubview(coinView)
    addSubview(crossLabel)
    addSubview(numberLabel)
    addSubview(underline)
    addSubview(claimButton)

    addConstraintsWithFormat("H:|-10-[v0]-10-|", views: title)
    addConstraintsWithFormat("H:|-10-[v0]-10-|", views: message)
    addConstraintsWithFormat("H:[v0(30)]-5-[v1(13)]-5-[v2(45)]", views: coinView, crossLabel, numberLabel)
    crossLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: 4).isActive = true
    addConstraintsWithFormat("H:|-1-[v0]-1-|", views: underline)
    addConstraintsWithFormat("H:|-1-[v0]-1-|", views: claimButton)

    addConstraintsWithFormat("V:|-17-[v0(18)]-8-[v1]-9-[v2(30)]-10-[v3(1)][v4(48)]|", views: title, message, coinView, underline, claimButton)

    // Additional setup for cross abel
    crossLabel.heightAnchor.constraint(equalTo: coinView.heightAnchor).isActive = true
    crossLabel.centerYAnchor.constraint(equalTo: coinView.centerYAnchor).isActive = true

    // Additional setup for number label
    numberLabel.heightAnchor.constraint(equalTo: coinView.heightAnchor).isActive = true
    numberLabel.centerYAnchor.constraint(equalTo: coinView.centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
