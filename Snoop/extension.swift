//
//  extension.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/11/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  public class func defaultColor() -> UIColor {
    return UIColor(red: 51/255, green: 181/255, blue: 159/255, alpha: 1.0)
  }

  public class func disabledColor() -> UIColor {
    return UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
  }

  public class func secondaryTextColor() -> UIColor {
    return UIColor(red: 140/255, green: 157/255, blue: 170/255, alpha: 1.0)
  }
}
