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
    image.layer.cornerRadius = 4
    image.clipsToBounds = true
    return image
  }()

  let mark: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleAspectFill
    image.image = UIImage(named: "deselected")
    return image
  }()

  let name: UILabel = {
    let name = UILabel()
    name.font = UIFont.systemFont(ofSize: 14)
    name.textColor = UIColor.black
    return name
  }()

  // right edge 5
  //bottom  edge 5
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    addSubview(icon)
    addSubview(name)
    addConstraintsWithFormat("H:|[v0]|", views: icon)
    addConstraintsWithFormat("H:|[v0]|", views: name)
    icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
    icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
    name.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 5).isActive = true
    name.heightAnchor.constraint(equalToConstant: 20).isActive = true
    icon.addSubview(mark)
    icon.addConstraintsWithFormat("H:[v0(22)]-5-|", views: mark)
    icon.addConstraintsWithFormat("V:[v0(22)]-5-|", views: mark)
  }

  override var isSelected: Bool {
    didSet {
      if (isSelected) {
        name.textColor = UIColor.defaultColor()
        mark.image = UIImage(named: "selected")
      }
      else {
        name.textColor = UIColor.black
        mark.image = UIImage(named: "deselected")
      }
    }
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
