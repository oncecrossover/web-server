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

extension UIView {
  public func addConstraintsWithFormat(_ format: String, views: UIView...) {
    var viewDictionary = [String: UIView]()
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      view.translatesAutoresizingMaskIntoConstraints = false
      viewDictionary[key] = view
    }

    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewDictionary))
  }
}

extension UIViewController {
  public func displayConfirmation(_ msg: String) {
    let confirmView = ConfirmView()
    confirmView.translatesAutoresizingMaskIntoConstraints = false
    confirmView.setMessage(msg)
    view.addSubview(confirmView)
    confirmView.widthAnchor.constraint(equalToConstant: 160).isActive = true
    confirmView.heightAnchor.constraint(equalToConstant: 90).isActive = true
    confirmView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    confirmView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    confirmView.alpha = 0
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      confirmView.alpha = 1
    }, completion: nil)
    let time = DispatchTime.now() + Double(2 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        confirmView.alpha = 0
      }) { (result) in
        confirmView.removeFromSuperview()
      }
    }
  }
}
