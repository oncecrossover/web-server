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
    view.contentMode = .scaleAspectFill
    return view
  }()

  let coinCount: UILabel = {
    let count = UILabel()
    count.numberOfLines = 1
    count.adjustsFontSizeToFitWidth = true
    count.minimumScaleFactor = 10 / count.font.pointSize
    count.textColor = UIColor(white: 0, alpha: 0.8)
    count.textAlignment = .right
    return count
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    addSubview(coinView)
    addSubview(coinCount)

    addConstraintsWithFormat("H:|[v0(35)]-2-[v1(23)]|", views: coinCount, coinView)
    addConstraintsWithFormat("V:|-1-[v0(23)]-1-|", views: coinView)
    addConstraintsWithFormat("V:|-1-[v0]-1-|", views: coinCount)
  }

  func setCount(_ count: Int) {
    coinCount.text = "\(count)"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
