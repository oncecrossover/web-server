//
//  ConfirmationViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/28/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate
{
  func modalViewControllerDismissed()
}

class ConfirmationViewController: UIViewController {

  var delegate: ModalViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func okButtonTapped(sender: AnyObject) {
    self.delegate?.modalViewControllerDismissed()
  }
}
