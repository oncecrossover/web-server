//
//  QuestionView.swift
//  Snoop
//
//  Created by Bowen Zhang on 4/10/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class QuestionView: UILabel {
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets.init(top: 4, left: 5, bottom: 20, right: 0)
    super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    self.lineBreakMode = NSLineBreakMode.byWordWrapping
    self.numberOfLines = 0
    self.sizeToFit()
    self.layer.cornerRadius = 4
    self.clipsToBounds = true
    self.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 252/255, alpha: 1.0)
  }
}
