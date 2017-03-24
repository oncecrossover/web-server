//
//  ProgressView.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/22/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class ProgressView: UIView {
  let progressBar: UIProgressView = {
    let view = UIProgressView()
    view.progressTintColor = UIColor.defaultColor()
    view.trackTintColor = UIColor.disabledColor()
    return view
  }()

  let label: UILabel = {
    let label = UILabel()
    label.text = "Uploading..."
    label.font = UIFont.boldSystemFont(ofSize: 20)
    label.textAlignment = .center
    label.textColor = UIColor.defaultColor()
    return label
  }()

  func showSuccess() {
    progressBar.isHidden = true
    label.text = "Upload Success!"
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    //backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 252/255, alpha: 1.0)
    backgroundColor = UIColor.clear
    addSubview(progressBar)
    addSubview(label)

    addConstraintsWithFormat("H:|-20-[v0]-20-|", views: progressBar)
    addConstraintsWithFormat("H:|-20-[v0]-20-|", views: label)
    addConstraintsWithFormat("V:|-20-[v0(4)]-20-[v1(30)]", views: progressBar, label)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
