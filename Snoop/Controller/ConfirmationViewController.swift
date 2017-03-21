//
//  ConfirmationViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/28/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

  @IBOutlet weak var message: UILabel!
  @IBOutlet weak var confirmationButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    confirmationButton.isEnabled = true
    message.textColor = UIColor.secondaryTextColor()
  }
}
