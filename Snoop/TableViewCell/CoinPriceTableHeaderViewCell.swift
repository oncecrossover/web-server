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
    label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
    label.heightAnchor.constraint(equalToConstant: 40).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
