//
//  ProgressView.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/22/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class ProgressView: UIView {
  let label: UILabel = {
    let label = UILabel()
    label.text = "Uploading..."
    label.font = UIFont.systemFont(ofSize: 12)
    label.textAlignment = .center
    label.textColor = UIColor.white
    return label
  }()

  func showSuccess() {
    label.text = "Upload Success!"
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.defaultColor()
    addSubview(label)

    addConstraintsWithFormat("H:|-20-[v0]-20-|", views: label)
    label.heightAnchor.constraint(equalToConstant: 15).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
