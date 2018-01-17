//
//  InterestPickerPlaceholderViewController.swift
//  Snoop
//
//  Created by Bingo Zhou on 1/17/18.
//  Copyright © 2018 Vinsider, Inc. All rights reserved.
//

import UIKit

/*
  This is a placeholder class of InterestPickerViewController in order to
 remove interests and expertise and maintain code structure meanwhile.
 */
class InterestPickerPlaceholderViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white

    self.tabBarController?.tabBar.isHidden = true

    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
    UserDefaults.standard.synchronize()
    self.dismiss(animated: true, completion: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let application = UIApplication.shared
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.registerForPushNotifications(application)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.tabBarController?.tabBar.isHidden = false
  }
}

