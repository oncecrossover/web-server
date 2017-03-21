//
//  InterestCollectionViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class InterestCollectionViewCell: UICollectionViewCell {

  let icon: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleAspectFill
    image.layer.cornerRadius = 15
    image.clipsToBounds = true
    return image
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    addSubview(icon)
    addConstraintsWithFormat("H:|[v0]|", views: icon)
    addConstraintsWithFormat("V:|[v0]|", views: icon)
  }

  override var isSelected: Bool {
    didSet {
      if (isSelected) {
        icon.tintColor = UIColor.defaultColor()
      }
      else {
        icon.tintColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
      }
    }
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
