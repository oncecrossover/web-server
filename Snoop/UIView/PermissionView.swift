//
//  PermissionView.swift
//  Snoop
//
//  Created by Bowen Zhang on 4/1/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class PermissionView: UIView {
  let header: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.textColor = UIColor(white: 0, alpha: 0.8)
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
    return label
  }()

  let note: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.textColor = UIColor.secondaryTextColor()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .center
    label.text = "Access was previously denied, please grant access from iPhone Settings"
    return label
  }()

  let instruction: UILabel = {
    let label = UILabel()
    label.numberOfLines = 4
    label.textColor = UIColor(white: 0, alpha: 0.8)
    label.font = UIFont.systemFont(ofSize: 16)
//    label.textAlignment = .center
    return label
  }()

  lazy var okButton: UIButton = {
    let button = UIButton()
    button.setTitle("Got it", for: UIControlState())
    button.setTitleColor(UIColor.defaultColor(), for: UIControlState())
      button.backgroundColor = UIColor.white
    button.layer.cornerRadius = 4
      button.clipsToBounds = true
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.defaultColor().cgColor
    button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
    return button
  }()

  let whiteView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 4
    view.backgroundColor = UIColor.white
    return view
  }()

  @objc func okButtonTapped() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.alpha = 0
    }, completion: nil)
  }

  func setHeader(_ msg: String) {
    header.text = msg
  }

  func setInstruction(_ msg: String) {
    instruction.text = msg
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.5)

    addSubview(whiteView)
    addConstraintsWithFormat("H:|-10-[v0]-10-|", views: whiteView)
    whiteView.heightAnchor.constraint(equalToConstant: 320).isActive = true
    whiteView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

    whiteView.addSubview(header)
    whiteView.addSubview(note)
    whiteView.addSubview(instruction)
    whiteView.addSubview(okButton)
    whiteView.addConstraintsWithFormat("V:|-30-[v0(50)]-10-[v1(40)]-10-[v2(100)]-20-[v3(40)]", views: header, note, instruction, okButton)
    whiteView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: header)
    whiteView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: note)
    whiteView.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: instruction)
    whiteView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: okButton)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
