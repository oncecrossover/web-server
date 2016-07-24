//
//  InteractiveUITextView.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/24/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class InteractiveUITextView: UITextView, UITextViewDelegate {

  override func awakeFromNib() {
    self.delegate = self
  }

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
}
