//
//  CoinsTableViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/5/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class CoinsTableViewCell: UITableViewCell {
  let title: UILabel = {
    let title = UILabel()
    title.font = UIFont.systemFontOfSize(16)
    title.textColor = UIColor(white: 0, alpha: 0.8)
    title.text = "Current Coins"
    return title
  }()

  let coinView: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "coin")
    view.contentMode = .ScaleAspectFill
    return view
  }()

  let coinCount: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFontOfSize(18)
    label.textColor = UIColor(white: 0, alpha: 0.8)
    return label
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(title)
    addSubview(coinView)
    addSubview(coinCount)

    // Setup constraints
    addConstraintsWithFormat("H:|-14-[v0(120)]", views: title)
    addConstraintsWithFormat("H:[v0(23)]-6-[v1(40)]-14-|", views: coinView, coinCount)
    title.heightAnchor.constraintEqualToConstant(20).active = true
    title.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    coinView.heightAnchor.constraintEqualToConstant(23).active = true
    coinView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    coinCount.heightAnchor.constraintEqualToConstant(20).active = true
    coinCount.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
