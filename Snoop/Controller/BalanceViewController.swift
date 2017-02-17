//
//  BalanceViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/12/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class BalanceViewController: UIViewController {

  var balance = 0.0
  var canCashout = false

  let balanceLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFontOfSize(18)
    label.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    label.textAlignment = .Center
    label.text = "Available Balance"
    return label
  }()

  let balanceValue: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFontOfSize(20)
    label.textColor = UIColor.blackColor()
    label.textAlignment = .Center
    return label
  }()

  let note: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFontOfSize(11)
    label.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    label.textAlignment = .Center
    label.text = "A minimum balance of $5 is required to cash out"
    return label
  }()

  let cashoutButton : CustomButton = {
    let button = CustomButton()
    button.setTitle("Cash Out", forState: .Normal)
    button.setTitle("Cash Out", forState: .Disabled)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()
    initView()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    initView()
  }

  func initView() {
    view.addSubview(balanceLabel)
    view.addSubview(balanceValue)
    view.addSubview(note)
    view.addSubview(cashoutButton)

    // setup value
    balanceValue.text = "$ \(balance)"
    cashoutButton.enabled = canCashout

    // setup constraints
    balanceLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    balanceLabel.widthAnchor.constraintEqualToConstant(150).active = true
    balanceLabel.heightAnchor.constraintEqualToConstant(20).active = true
    balanceLabel.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 120).active = true

    balanceValue.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    balanceValue.heightAnchor.constraintEqualToConstant(25).active = true
    balanceValue.widthAnchor.constraintEqualToConstant(90).active = true
    balanceValue.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 160).active = true

    note.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    note.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
    note.heightAnchor.constraintEqualToConstant(15).active = true
    note.bottomAnchor.constraintEqualToAnchor(cashoutButton.topAnchor, constant: -20).active = true

    let height = self.tabBarController?.tabBar.frame.height
    cashoutButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    cashoutButton.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
    cashoutButton.heightAnchor.constraintEqualToConstant(40).active = true
    cashoutButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -height!).active = true
  }

}
