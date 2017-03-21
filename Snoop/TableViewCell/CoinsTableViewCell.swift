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
    title.font = UIFont.systemFont(ofSize: 16)
    title.textColor = UIColor(white: 0, alpha: 0.8)
    title.text = "Current Coins"
    return title
  }()

  let coinView: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "coin")
    view.contentMode = .scaleAspectFill
    return view
  }()

  let coinCount: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = UIColor(white: 0, alpha: 0.8)
    label.textAlignment = .right
    return label
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubview(title)
    addSubview(coinView)
    addSubview(coinCount)
    selectionStyle = .none

    // Setup constraints
    addConstraintsWithFormat("H:|-14-[v0(120)]", views: title)
    addConstraintsWithFormat("H:[v0(23)]-6-[v1(40)]-14-|", views: coinView, coinCount)
    title.heightAnchor.constraint(equalToConstant: 20).isActive = true
    title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    coinView.heightAnchor.constraint(equalToConstant: 23).isActive = true
    coinView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    coinCount.heightAnchor.constraint(equalToConstant: 20).isActive = true
    coinCount.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
