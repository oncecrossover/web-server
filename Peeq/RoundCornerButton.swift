//
//  RoundCornerButton.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/11/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class RoundCornerButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 4
  }


}
