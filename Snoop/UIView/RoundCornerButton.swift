//
//  RoundCornerButton.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/11/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class RoundCornerButton: UIButton {

  override func awakeFromNib() {
    super.awakeFromNib()
    self.layoutIfNeeded()
    self.layer.cornerRadius = 4
  }


}
