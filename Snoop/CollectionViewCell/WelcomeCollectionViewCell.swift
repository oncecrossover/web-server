//
//  WelcomeCollectionViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/19/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class WelcomeCollectionViewCell: UICollectionViewCell {
  let emptySpace: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    return view
  }()

  let title: UILabel = {
    let title = UILabel()
    title.font = UIFont.boldSystemFont(ofSize: 30)
    title.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 1.0)
    title.textAlignment = .left
    title.numberOfLines = 3
    return title
  }()

  let summary: UILabel = {
    let summary = UILabel()
    summary.font = UIFont.systemFont(ofSize: 15)
    summary.textAlignment = .left
    summary.textColor = UIColor.black
    summary.numberOfLines = 4
    return summary
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(emptySpace)
    addSubview(title)
    addSubview(summary)

    // setup constraints
    addConstraintsWithFormat("H:|[v0]|", views: emptySpace)
    addConstraintsWithFormat("H:|-20-[v0]|", views: title)
    addConstraintsWithFormat("H:|-20-[v0]|", views: summary)
    addConstraintsWithFormat("V:|[v0]-0-[v1(120)]-20-[v2(90)]|", views: emptySpace, title, summary)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
