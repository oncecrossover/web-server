//
//  customButton.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/11/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
  override var enabled : Bool {
    didSet {
      backgroundColor = enabled ? UIColor.defaultColor() : UIColor.disabledColor()
    }
  }

}
