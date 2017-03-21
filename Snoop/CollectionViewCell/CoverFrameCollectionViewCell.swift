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

  override var isSelected: Bool {
    didSet {
      if (isSelected) {
        layer.borderColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0).cgColor
        layer.borderWidth = 2
      }
      else {
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(coverImage)

    coverImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    coverImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    coverImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
    coverImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
