//
//  ProfilePairLabelView.swift
//  Snoop
//
//  Created by Bingo Zhou on 11/14/17.
//  Copyright © 2017 Vinsider, Inc. All rights reserved.
//

import Foundation

class PairLabelView: UIView {
  let amount: UILabel = {
    let amount = UILabel()
    amount.textAlignment = .center
    amount.textColor = UIColor(white: 0, alpha: 0.7)
    amount.font = UIFont.systemFont(ofSize: 16)
    return amount
  }()

  let label: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = UIColor.disabledColor()
    label.textAlignment = .center
    return label
  }()

  func setAmount(fromDouble: Double) {
    amount.text = String(format: "%.2f", fromDouble)
  }

  func setAmount(fromInt: Int) {
    amount.text = fromInt.formatPoints()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    addSubview(amount)
    addSubview(label)

    addConstraintsWithFormat("H:|[v0]|", views: amount)
    addConstraintsWithFormat("H:|[v0]|", views: label)
    addConstraintsWithFormat("V:|[v0(18)]-0-[v1(15)]|", views: amount, label)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
