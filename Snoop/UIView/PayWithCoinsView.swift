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
    view.contentMode = .ScaleAspectFill
    return view
  }()

  let crossLabel: UILabel = {
    // left by 5 , 13 by 13
    let label = UILabel()
    label.text = "X"
    label.textAlignment = .Center
    label.font = UIFont.boldSystemFontOfSize(18)
    label.textColor = UIColor.blackColor()
    return label
  }()

  let numberLabel: UILabel = {
    // left by 5 15 by 28
    let label = UILabel()
    label.text = "8"
    label.font = UIFont.boldSystemFontOfSize(24)
    label.textColor = UIColor.blackColor()
    return label
  }()

  let confirmLabel: UILabel = {
    // top by 15 240 by 18
    let label = UILabel()
    label.text = "Confirm To Snoop?"
    label.textColor = UIColor(red: 42/255, green: 48/255, blue: 52/255, alpha: 1.0)
    label.font = UIFont.boldSystemFontOfSize(16)
    label.textAlignment = .Center
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
    button.setTitleColor(UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.6), forState: .Normal)
    button.setTitle("Cancel", forState: .Normal)
    return button
  }()

  lazy var confirmButton: UIButton = {
    let button = UIButton()
    button.setTitle("Confirm", forState: .Normal)
    button.setTitleColor(UIColor.defaultColor(), forState: .Normal)
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.whiteColor()
    addSubview(coinView)
    addSubview(crossLabel)
    addSubview(numberLabel)
    addSubview(confirmLabel)
    addSubview(underline)
    addSubview(verticalLine)
    addSubview(cancelButton)
    addSubview(confirmButton)

    // Setup constraints
    addConstraintsWithFormat("H:|-87-[v0(30)]-5-[v1(13)]-5-[v2(30)]", views: coinView, crossLabel, numberLabel)
    addConstraintsWithFormat("H:|-3-[v0]-3-|", views: underline)
    addConstraintsWithFormat("V:|-40-[v0(30)]-15-[v1(18)]-25-[v2(1)]-0-[v3]|", views: coinView, confirmLabel, underline, cancelButton)
    addConstraintsWithFormat("V:|-40-[v0(30)]-15-[v1(18)]-25-[v2(1)]-0-[v3]|", views: coinView, confirmLabel, underline, confirmButton)
    addConstraintsWithFormat("V:|-40-[v0(30)]-15-[v1(18)]-25-[v2(1)]-5-[v3]-5-|", views: coinView, confirmLabel, underline, verticalLine)

    // Additional setup for cross Label
    crossLabel.centerYAnchor.constraintEqualToAnchor(coinView.centerYAnchor).active = true
    crossLabel.heightAnchor.constraintEqualToAnchor(crossLabel.widthAnchor).active = true

    // Additional setup for numberLabel
    numberLabel.centerYAnchor.constraintEqualToAnchor(coinView.centerYAnchor).active = true
    numberLabel.heightAnchor.constraintEqualToConstant(18).active = true

    // Additional setup for confirmLabel
    confirmLabel.widthAnchor.constraintEqualToConstant(240).active = true
    confirmLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true

    // Additional setup for two buttons and the vertical line
    verticalLine.widthAnchor.constraintEqualToConstant(1).active = true
    cancelButton.widthAnchor.constraintEqualToAnchor(confirmButton.widthAnchor).active = true
    cancelButton.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
    cancelButton.trailingAnchor.constraintEqualToAnchor(verticalLine.leadingAnchor).active = true
    confirmButton.leadingAnchor.constraintEqualToAnchor(verticalLine.trailingAnchor).active = true
    confirmButton.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
  }

  func setCount(count: Int) {
    self.numberLabel.text = String(count)
  }

  func setConfirmMessage(message: String) {
    self.confirmLabel.text = message
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

