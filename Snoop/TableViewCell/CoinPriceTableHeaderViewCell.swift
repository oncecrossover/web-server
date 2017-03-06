//
//  CoinPriceTableHeaderViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/5/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class CoinPriceTableHeaderViewCell: UITableViewHeaderFooterView {

  let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Buy More Coins"
    label.textColor = UIColor(red: 78/255, green: 78/255, blue: 78/255, alpha: 0.8)
    return label
  }()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    addSubview(label)
    label.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    label.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    label.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 14).active = true
    label.heightAnchor.constraintEqualToConstant(40).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
