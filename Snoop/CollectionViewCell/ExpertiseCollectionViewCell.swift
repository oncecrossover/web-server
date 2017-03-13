//
//  ExpertiseCollectionViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/26/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class ExpertiseCollectionViewCell: UICollectionViewCell {
  let icon: UILabel = {
    let category = UILabel()
    category.font = UIFont.systemFontOfSize(14)
    category.textColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1.0)
    category.textAlignment = .Center
    category.layer.cornerRadius = 4
    category.layer.borderWidth = 1
    category.layer.borderColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1.0).CGColor
    category.clipsToBounds = true
    return category
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    addSubview(icon)
    addConstraintsWithFormat("H:|[v0]|", views: icon)
    addConstraintsWithFormat("V:|[v0]|", views: icon)
  }

  override var selected: Bool {
    didSet {
      if (selected) {
        icon.textColor = UIColor.defaultColor()
        icon.layer.borderColor = UIColor.defaultColor().CGColor
      }
      else {
        icon.textColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1.0)
        icon.layer.borderColor = UIColor(red: 163/255, green: 163/255, blue: 163/255, alpha: 1.0).CGColor
      }
    }
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
