//
//  HorizontalPairLabelView.swift
//  Snoop
//
//  Created by Bingo Zhou on 12/14/17.
//  Copyright © 2017 Vinsider Inc. All rights reserved.
//

import Foundation

class HorizontalPairLabelView:  PairLabelView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    addSubview(amount)
    addSubview(label)

    addConstraintsWithFormat("V:|[v0]|", views: amount)
    addConstraintsWithFormat("V:|[v0]|", views: label)
    addConstraintsWithFormat("H:|[v0(52)]-0-[v1(15)]|", views: label, amount)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
