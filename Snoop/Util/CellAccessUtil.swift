//
//  CellAccessUtil.swift
//  Snoop
//
//  Created by Bingo Zhou on 8/26/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation


class CellAccessUtil {
  /* popup hints to allow access to Photos */
  func popupAllowPhotosAccess(_ permissionView: PermissionView) {
    if let window = UIApplication.shared.keyWindow {
      window.addSubview(permissionView)
      window.addConstraintsWithFormat("H:|[v0]|", views: permissionView)
      window.addConstraintsWithFormat("V:|[v0]|", views: permissionView)
      permissionView.alpha = 0
      UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        permissionView.alpha = 1
      }, completion: nil)
    }
  }
}
