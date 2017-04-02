//
//  AnswerTableFooterViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 4/1/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class AnswerTableFooterViewCell: UITableViewHeaderFooterView {
  let instruction: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.secondaryTextColor()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .center
    label.numberOfLines = 2
    label.text = "Touch Button to start recording answer up to 60 seconds"
    return label
  }()

  let cameraView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFill
    view.image = UIImage(named: "camera")
    return view
  }()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    backgroundColor = UIColor.white
    addSubview(instruction)
    addSubview(cameraView)

    addConstraintsWithFormat("V:|-10-[v0(40)]", views: instruction)
    addConstraintsWithFormat("H:|-20-[v0]-20-|", views: instruction)

    cameraView.heightAnchor.constraint(equalToConstant: 71).isActive = true
    cameraView.widthAnchor.constraint(equalToConstant: 71).isActive = true
    cameraView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    cameraView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
