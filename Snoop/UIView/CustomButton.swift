//
//  customButton.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/11/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
  override var isEnabled : Bool {
    didSet {
      backgroundColor = isEnabled ? UIColor.defaultColor() : UIColor.disabledColor()
    }
  }

}
