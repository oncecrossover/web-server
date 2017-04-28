//
//  PayWithCoinsView.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/6/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class PayWithCoinsView: UIView {
  let coinView: UIImageView = {
    // left 87, 30 by 30, top by 40
    let view = UIImageView()
    view.image = UIImage(named: "coin")
    view.contentMode = .scaleAspectFill
    return view
  }()

  let crossLabel: UILabel = {
    // left by 5 , 13 by 13
    let label = UILabel()
    label.text = "X"
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 18)
    label.textColor = UIColor.black
    return label
  }()

  let numberLabel: UILabel = {
    // left by 5 15 by 28
    let label = UILabel()
    label.text = "4"
    label.font = UIFont.boldSystemFont(ofSize: 24)
    label.textColor = UIColor.black
    return label
  }()

  let confirmLabel: UILabel = {
    // top by 15 240 by 18
    let label = UILabel()
    label.text = "Confirm To Snoop?"
    label.textColor = UIColor(red: 42/255, green: 48/255, blue: 52/255, alpha: 1.0)
    label.font = UIFont.boldSystemFont(ofSize: 16)
    label.textAlignment = .center
    return label
  }()

  let underline: UIView = {
    //top by 25
    let view = UIView()
    view.backgroundColor = UIColor(red: 204/255, green: 214/255, blue: 221/255, alpha: 1.0)
    return view
  }()

  let verticalLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 204/255, green: 214/255, blue: 221/255, alpha: 1.0)
    return view
  }()

  lazy var cancelButton: UIButton = {
    let button = UIButton()
    button.setTitleColor(UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.6), for: UIControlState())
    button.setTitle("Cancel", for: UIControlState())
    return button
  }()

  lazy var confirmButton: UIButton = {
    let button = UIButton()
    button.setTitle("Confirm", for: UIControlState())
    button.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    addSubview(coinView)
    addSubview(crossLabel)
    addSubview(numberLabel)
    addSubview(confirmLabel)
    addSubview(underline)
    addSubview(verticalLine)
    addSubview(cancelButton)
    addSubview(confirmButton)

    // Setup constraints
    addConstraintsWithFormat("H:|-87-[v0(30)]-5-[v1(13)]-5-[v2(40)]", views: coinView, crossLabel, numberLabel)
    addConstraintsWithFormat("H:|-3-[v0]-3-|", views: underline)
    addConstraintsWithFormat("V:|-40-[v0(30)]-15-[v1(18)]-25-[v2(1)]-0-[v3]|", views: coinView, confirmLabel, underline, cancelButton)
    addConstraintsWithFormat("V:|-40-[v0(30)]-15-[v1(18)]-25-[v2(1)]-0-[v3]|", views: coinView, confirmLabel, underline, confirmButton)
    addConstraintsWithFormat("V:|-40-[v0(30)]-15-[v1(18)]-25-[v2(1)]-5-[v3]-5-|", views: coinView, confirmLabel, underline, verticalLine)

    // Additional setup for cross Label
    crossLabel.centerYAnchor.constraint(equalTo: coinView.centerYAnchor).isActive = true
    crossLabel.heightAnchor.constraint(equalTo: crossLabel.widthAnchor).isActive = true

    // Additional setup for numberLabel
    numberLabel.centerYAnchor.constraint(equalTo: coinView.centerYAnchor).isActive = true
    numberLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true

    // Additional setup for confirmLabel
    confirmLabel.widthAnchor.constraint(equalToConstant: 240).isActive = true
    confirmLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

    // Additional setup for two buttons and the vertical line
    verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
    cancelButton.widthAnchor.constraint(equalTo: confirmButton.widthAnchor).isActive = true
    cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    cancelButton.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor).isActive = true
    confirmButton.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor).isActive = true
    confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }

  func setCount(_ count: Int) {
    self.numberLabel.text = String(count)
  }

  func setConfirmMessage(_ message: String) {
    self.confirmLabel.text = message
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

