//
//  TextFitLabel.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/12/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class TextFitLabel: UILabel {

  override func awakeFromNib() {
    super.awakeFromNib()
    self.lineBreakMode = NSLineBreakMode.byWordWrapping
    self.numberOfLines = 0
    self.sizeToFit()
  }

}
