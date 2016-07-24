//
//  UiUtility.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/23/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
import UIKit
class UIUtility {
  func displayAlertMessage(userMessage:String, title: String, sender: UIViewController) {

    let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)

    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

    myAlert.addAction(okAction)

    sender.presentViewController(myAlert, animated: true, completion: nil)

  }
}
