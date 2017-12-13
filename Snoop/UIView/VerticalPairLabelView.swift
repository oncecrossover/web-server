//
//  ProfilePairLabelView.swift
//  Snoop
//
//  Created by Bingo Zhou on 11/14/17.
//  Copyright © 2017 Vinsider, Inc. All rights reserved.
//

import Foundation

class VerticalPairLabelView: PairLabelView {

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
