//
//  SettingsTableViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/26/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
  let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
    return label
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(label)
    addConstraintsWithFormat("H:|-15-[v0(200)]", views: label)
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    label.heightAnchor.constraint(equalToConstant: 25).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
