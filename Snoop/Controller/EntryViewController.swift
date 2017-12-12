//
//  EntryViewController.swift
//  Snoop
//
//  Created by Bingo Zhou on 12/12/17.
//  Copyright © 2017 Vinsider Inc. All rights reserved.
//

import Foundation

class EntryViewController: UIViewController {
  func createTapButton() -> UIButton {
    let button = UIButton()
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }

  func createLinkButton() -> UIButton {
    let link = UIButton()
    link.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    link.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    link.backgroundColor = UIColor.white
    link.translatesAutoresizingMaskIntoConstraints = false
    return link
  }
}
