//
//  CoverFrameCollectionViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 12/15/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class CoverFrameCollectionViewCell: UICollectionViewCell {

  let coverImage : UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    return image
  }()

  override var selected: Bool {
    didSet {
      if (selected) {
        layer.borderColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0).CGColor
        layer.borderWidth = 2
      }
      else {
        layer.borderColor = UIColor.clearColor().CGColor
        layer.borderWidth = 0
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(coverImage)

    coverImage.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
    coverImage.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
    coverImage.topAnchor.constraintEqualToAnchor(topAnchor).active = true
    coverImage.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
