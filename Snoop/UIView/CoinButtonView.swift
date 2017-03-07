//
//  CoinButtonView.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/5/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class CoinButtonView: UIView {
  let coinView: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "coin")
    view.contentMode = .ScaleAspectFill
    return view
  }()

  let coinCount: UILabel = {
    let count = UILabel()
    count.numberOfLines = 1
    count.adjustsFontSizeToFitWidth = true
    count.minimumScaleFactor = 10 / count.font.pointSize
    count.textColor = UIColor(white: 0, alpha: 0.8)
    return count
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    addSubview(coinView)
    addSubview(coinCount)

    addConstraintsWithFormat("H:|[v0(18)]-2-[v1(35)]|", views: coinView, coinCount)
    addConstraintsWithFormat("V:|-1-[v0]-1-|", views: coinView)
    addConstraintsWithFormat("V:|-1-[v0]-1-|", views: coinCount)
  }

  func setCount(count: Int) {
    coinCount.text = String(count)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
