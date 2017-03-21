//
//  PaymentViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/11/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
  let cellId = "paymentCell"

  var paymentModule = Payment()

  var last4 = "No cards"
  var balance = 0.0

  lazy var paymentTableView: UITableView = {
    let table = UITableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.delegate = self
    table.dataSource = self
    table.rowHeight = 40
    table.register(paymentTableViewCell.self, forCellReuseIdentifier: self.cellId)
    return table
  }()

  let activityIndicator : UIActivityIndicatorView = {
    let view = UIActivityIndicatorView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.color = UIColor.defaultColor()
    view.hidesWhenStopped = true
    return view
  }()
}

//override method
extension PaymentViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.clear
    self.navigationItem.title = "Payment"
    setupTableView()
    setupActivityIndicator()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadAccountInfo()
  }

  func setupTableView() {
    paymentTableView.tableFooterView = UIView()
    paymentTableView.tableHeaderView = UIView()
    paymentTableView.separatorInset = UIEdgeInsets.zero

    self.view.addSubview(paymentTableView)

    //Set up constraints
    paymentTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    paymentTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    paymentTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    paymentTableView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true

  }

  func setupActivityIndicator() {
    self.view.addSubview(activityIndicator)
    activityIndicator.centerXAnchor.constraint(equalTo: paymentTableView.centerXAnchor).isActive = true
    activityIndicator.topAnchor.constraint(equalTo: paymentTableView.topAnchor, constant: 100).isActive = true
  }
}

//Private methods to load data
extension PaymentViewController {
  fileprivate func loadAccountInfo() {
    self.paymentTableView.isUserInteractionEnabled = false
    last4 = " No Cards"
    let uid = UserDefaults.standard.string(forKey: "email")
    self.activityIndicator.startAnimating()
    paymentModule.getPayments("uid=" + uid!) { jsonArray in
      for paymentInfo in jsonArray as! [[String:AnyObject]] {
        let isDefault = paymentInfo["default"] as! Bool
        if (isDefault == true) {
          self.last4 = paymentInfo["last4"] as! String
          break
        }
      }

      let uid = UserDefaults.standard.string(forKey: "email")
      self.paymentModule.getBalance(uid) { convertedDict in
        if let _ = convertedDict["balance"] as? Double {
          self.balance = convertedDict["balance"] as! Double
        }
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          self.paymentTableView.reloadData()
          self.paymentTableView.isUserInteractionEnabled = true
        }
      }
    }
  }
}

// datasource and delegate for tableView
extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! paymentTableViewCell
    cell.iconImage.contentMode = .scaleAspectFit
    if (indexPath.row == 0) {
      cell.iconImage.image = UIImage(named: "paymentIcon")
      cell.title.text = "Manage Cards"
      cell.value.text = "xxxx \(last4)"
    }
    else {
      cell.iconImage.image = UIImage(named: "balance")
      cell.title.text = "Balance"
      cell.value.text = String(balance)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let backButton = UIBarButtonItem()
    backButton.title = "Back"
    navigationItem.backBarButtonItem = backButton
    if (indexPath.row == 0) {
      let dvc = CardsViewController()
      self.navigationController?.pushViewController(dvc, animated: true)
    }
    else {
      let dvc = BalanceViewController()
      dvc.balance = balance
      dvc.canCashout = balance > 5.0
      self.navigationController?.pushViewController(dvc, animated: true)
    }
  }
}

class paymentTableViewCell: UITableViewCell {

  let iconImage: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let title: UILabel = {
    let view = UILabel()
    view.font = UIFont.systemFont(ofSize: 14)
    view.textAlignment = .left
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let value: UILabel = {
    let view = UILabel()
    view.font = UIFont.systemFont(ofSize: 13)
    view.textAlignment = .right
    view.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.addSubview(iconImage)
    self.addSubview(title)
    self.addSubview(value)

    iconImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    iconImage.widthAnchor.constraint(equalToConstant: 18).isActive = true
    iconImage.heightAnchor.constraint(equalToConstant: 14).isActive = true
    iconImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true

    title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    title.leadingAnchor.constraint(equalTo: iconImage.leadingAnchor, constant: 38).isActive = true
    title.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
    title.trailingAnchor.constraint(equalTo: value.leadingAnchor, constant: 48).isActive = true


    value.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    value.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    value.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
