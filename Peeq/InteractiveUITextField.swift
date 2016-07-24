//
//  InteractiveUITextField.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/24/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class InteractiveUITextField: UITextField, UITextFieldDelegate {

  override func awakeFromNib() {
    self.delegate = self
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.resignFirstResponder()
    return true
  }


}
