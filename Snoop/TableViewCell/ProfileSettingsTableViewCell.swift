//
//  SettingsTableViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/8/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class ProfileSettingsTableViewCell: UITableViewCell {

  let icon: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFill
    return view
  }()

  let category: UILabel = {
    let category = UILabel()
    category.textColor = UIColor(white: 0, alpha: 0.7)
    category.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
    return category
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(icon)
    addSubview(category)
    addConstraintsWithFormat("H:|-20-[v0(18)]-14-[v1(100)]", views: icon, category)
    icon.heightAnchor.constraint(equalToConstant: 18).isActive = true
    icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    category.heightAnchor.constraint(equalToConstant: 20).isActive = true
    category.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
