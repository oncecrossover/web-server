//
//  BuyCoinsView.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/14/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class BuyCoinsView: UIView {
  let title: UILabel = {
    // left by 11, top 16, height 18
    let title = UILabel()
    title.textColor = UIColor(red: 42/255, green: 48/255, blue: 52/255, alpha: 1.0)
    title.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
    title.textAlignment = .center
    title.text = "Insuffient Coins"
    return title
  }()

  let topLine: UIView = {
    // left by 2, top 15
    let line = UIView()
    line.backgroundColor = UIColor(red: 204/255, green: 214/255, blue: 221/255, alpha: 1.0)
    return line
  }()

  let note: UILabel = {
    // height 18, top 15
    let note = UILabel()
    note.textColor = UIColor(red: 42/255, green: 48/255, blue: 52/255, alpha: 1.0)
    note.font = UIFont.systemFont(ofSize: 15)
    note.textAlignment = .center
    return note
  }()

  let underline: UIView = {
    //top by 38
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

  lazy var buyCoinsButton: UIButton = {
    let button = UIButton()
    button.setTitle("Buy Coins", for: UIControlState())
    button.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    return button
  }()

  func setNote(_ message: String) {
    note.text = message
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    addSubview(title)
    addSubview(topLine)
    addSubview(note)
    addSubview(underline)
    addSubview(verticalLine)
    addSubview(cancelButton)
    addSubview(buyCoinsButton)

    // Set up constraints
    addConstraintsWithFormat("H:|-11-[v0]-11-|", views: title)
    addConstraintsWithFormat("H:|-2-[v0]-2-|", views: topLine)
    addConstraintsWithFormat("H:|-11-[v0]-11-|", views: note)
    addConstraintsWithFormat("H:|-2-[v0]-2-|", views: underline)
    addConstraintsWithFormat("V:|-16-[v0(18)]-15-[v1(1)]-26-[v2(18)]-38-[v3(1)]-3-[v4]-3-|", views: title, topLine, note, underline, verticalLine)
    addConstraintsWithFormat("V:|-16-[v0(18)]-15-[v1(1)]-26-[v2(18)]-38-[v3(1)]-3-[v4]-3-|", views: title, topLine, note, underline, cancelButton)
    addConstraintsWithFormat("V:|-16-[v0(18)]-15-[v1(1)]-26-[v2(18)]-38-[v3(1)]-3-[v4]-3-|", views: title, topLine, note, underline, buyCoinsButton)

    verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
    buyCoinsButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor).isActive = true

    cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    cancelButton.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor).isActive = true
    buyCoinsButton.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor).isActive = true
    buyCoinsButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
