//
//  WelcomeCollectionViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/19/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class WelcomeCollectionViewCell: UICollectionViewCell {
  let title: UILabel = {
    let title = UILabel()
    title.font = UIFont.boldSystemFontOfSize(30)
    title.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    title.textAlignment = .Left
    title.numberOfLines = 3
    return title
  }()

  let summary: UILabel = {
    let summary = UILabel()
    summary.font = UIFont.systemFontOfSize(15)
    summary.textAlignment = .Left
    summary.textColor = UIColor.blackColor()
    summary.numberOfLines = 4
    return summary
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    self.addSubview(title)
    self.addSubview(summary)

    // setup constraints
    self.addConstraintsWithFormat("H:|-20-[v0]|", views: title)
    self.addConstraintsWithFormat("H:|-20-[v0]|", views: summary)
    self.addConstraintsWithFormat("V:|[v0(120)]", views: title)
    self.addConstraintsWithFormat("V:[v0(90)]|", views: summary)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
