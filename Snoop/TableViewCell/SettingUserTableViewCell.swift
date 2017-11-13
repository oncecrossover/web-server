//
//  SettingUserTableViewCell.swift
//  Snoop
//
//  Created by Bingo Zhou on 9/14/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation

class SettingUserTableViewCell: UITableViewCell {
  let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
    return label
  }()

  let uiSwitch: UISwitch = {
    let button = UISwitch()
    button.setOn(false, animated: true)
    button.onTintColor = UIColor.defaultColor()
    return button;
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(label)
    addSubview(uiSwitch)
    addConstraintsWithFormat("H:|-15-[v0(200)]-(>=50)-[v1]-15-|", views: label, uiSwitch)
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    label.heightAnchor.constraint(equalToConstant: 25).isActive = true

    self.uiSwitch.centerYAnchor.constraint(equalTo: self.label.centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
