//
//  CircleImageView.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/11/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = (self.frame.size.width) / 2
    self.clipsToBounds = true
  }

}
