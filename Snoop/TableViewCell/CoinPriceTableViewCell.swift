//
//  CoinPriceTableViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/5/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class CoinPriceTableViewCell: UITableViewCell {
  let coinView: UIImageView = {
    // 13, 23 by 23
    let view = UIImageView()
    view.image = UIImage(named: "coin")
    view.contentMode = .ScaleAspectFill
    return view
  }()

  let coinCount: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(white: 0, alpha: 0.7)
    label.font = UIFont.systemFontOfSize(16)
    // left 9, 60 by 22
    return label
  }()

  let popularLabel: UILabel = {
    // 125 to the left edge, 100 by 15
    let label = UILabel()
    label.textColor = UIColor.defaultColor()
    label.font = UIFont.boldSystemFontOfSize(12)
    return label
  }()

  let price : UILabel = {
    // right edge 14, 70 by 27
    let label = UILabel()
    label.layer.borderWidth = 1
    label.layer.borderColor = UIColor.defaultColor().CGColor
    label.layer.cornerRadius = 8
    label.textColor = UIColor.defaultColor()
    label.font = UIFont.systemFontOfSize(14)
    label.textAlignment = .Center
    label.clipsToBounds = true
    return label
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .None
    addSubview(coinView)
    addSubview(coinCount)
    addSubview(popularLabel)
    addSubview(price)

    // Constraints
    addConstraintsWithFormat("H:|-14-[v0(23)]-8-[v1(50)]-30-[v2(110)]", views: coinView, coinCount, popularLabel)
    addConstraintsWithFormat("H:[v0(70)]-14-|", views: price)
    coinView.heightAnchor.constraintEqualToConstant(23).active = true
    coinView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    coinCount.heightAnchor.constraintEqualToConstant(22).active = true
    coinCount.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    popularLabel.heightAnchor.constraintEqualToConstant(15).active = true
    popularLabel.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    price.heightAnchor.constraintEqualToConstant(25).active = true
    price.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
