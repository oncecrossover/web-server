//
//  SettingsTableHeaderViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/26/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class SettingsTableHeaderViewCell: UITableViewHeaderFooterView {
  let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "About"
    label.textColor = UIColor.defaultColor()
    return label
  }()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    addSubview(label)
    addConstraintsWithFormat("H:|-15-[v0(100)]", views: label)
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    label.heightAnchor.constraint(equalToConstant: 25).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
