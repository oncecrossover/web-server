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
    label.font = UIFont.systemFont(ofSize: 18)
    label.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    label.textAlignment = .center
    label.text = "Available Balance"
    return label
  }()

  let balanceValue: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 20)
    label.textColor = UIColor.black
    label.textAlignment = .center
    return label
  }()

  let note: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 11)
    label.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    label.textAlignment = .center
    label.text = "A minimum balance of $5 is required to cash out"
    return label
  }()

  let cashoutButton : CustomButton = {
    let button = CustomButton()
    button.setTitle("Cash Out", for: UIControlState())
    button.setTitle("Cash Out", for: .disabled)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    initView()
  }

  override func viewDidAppear(_ animated: Bool) {
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
    cashoutButton.isEnabled = canCashout

    // setup constraints
    balanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    balanceLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
    balanceLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    balanceLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true

    balanceValue.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    balanceValue.heightAnchor.constraint(equalToConstant: 25).isActive = true
    balanceValue.widthAnchor.constraint(equalToConstant: 90).isActive = true
    balanceValue.topAnchor.constraint(equalTo: view.topAnchor, constant: 160).isActive = true

    note.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    note.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    note.heightAnchor.constraint(equalToConstant: 15).isActive = true
    note.bottomAnchor.constraint(equalTo: cashoutButton.topAnchor, constant: -20).isActive = true

    let height = self.tabBarController?.tabBar.frame.height
    cashoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    cashoutButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    cashoutButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    cashoutButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -height!).isActive = true
  }

}
