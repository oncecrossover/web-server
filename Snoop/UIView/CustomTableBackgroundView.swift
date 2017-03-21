//
//  CustomTableBackgroundView.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/24/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

protocol CustomTableBackgroundViewDelegate {
  func didTapButton(_ index: Int)
}

class CustomTableBackgroundView: UIView {
  var delegate: CustomTableBackgroundViewDelegate! = nil

  let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = UIColor(red: 140/255, green: 157/255, blue: 170/255, alpha: 1.0)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  lazy var button: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 4
    button.addTarget(self, action: #selector(switchPage), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  func setButtonImage(_ image: UIImage) {
    button.setImage(image, for: UIControlState())
  }

  func setLabelText(_ text: String) {
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
    backgroundColor = UIColor.white
    addSubview(label)
    addSubview(button)
    addConstraintsWithFormat("H:|[v0]|", views: label)
    addConstraintsWithFormat("H:|[v0]|", views: button)
    label.heightAnchor.constraint(equalToConstant: 40).isActive = true
    button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -10).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -25).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
