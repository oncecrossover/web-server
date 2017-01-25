//
//  CustomTableBackgroundView.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/24/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

protocol CustomTableBackgroundViewDelegate {
  func didTapButton(index: Int)
}

class CustomTableBackgroundView: UIView {
  var delegate: CustomTableBackgroundViewDelegate! = nil

  let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .Center
    label.lineBreakMode = .ByWordWrapping
    label.numberOfLines = 0
    label.font = UIFont.systemFontOfSize(14)
    label.textColor = UIColor(red: 140/255, green: 157/255, blue: 170/255, alpha: 1.0)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  lazy var button: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 4
    button.addTarget(self, action: #selector(switchPage), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  func setButtonImage(image: UIImage) {
    button.setImage(image, forState: .Normal)
  }

  func setLabelText(text: String) {
    label.text = text
  }

  func switchPage() {
    let buttonImage = button.imageView!.image!
    switch buttonImage {
    case UIImage(named: "discoverButton")!:
      delegate.didTapButton(1)
    case UIImage(named: "trending")!:
      delegate.didTapButton(0)
    case UIImage(named: "profile")!:
      delegate.didTapButton(3)
    default:
      break
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.whiteColor()
    addSubview(label)
    addSubview(button)
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: [], metrics: nil, views: ["v0" : label]))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: [], metrics: nil, views: ["v0" : button]))
    label.heightAnchor.constraintEqualToConstant(40).active = true
    button.heightAnchor.constraintEqualToConstant(40).active = true
    label.bottomAnchor.constraintEqualToAnchor(button.topAnchor, constant: -10).active = true
    label.centerYAnchor.constraintEqualToAnchor(centerYAnchor, constant: -25).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
