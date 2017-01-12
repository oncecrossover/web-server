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
    table.registerClass(paymentTableViewCell.self, forCellReuseIdentifier: self.cellId)
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
    view.backgroundColor = UIColor.clearColor()
    self.navigationItem.title = "Payment"
    setupTableView()
    setupActivityIndicator()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadAccountInfo()
  }

  func setupTableView() {
    paymentTableView.tableFooterView = UIView()
    paymentTableView.tableHeaderView = UIView()
    paymentTableView.separatorInset = UIEdgeInsetsZero

    self.view.addSubview(paymentTableView)

    //Set up constraints
    paymentTableView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    paymentTableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
    paymentTableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
    paymentTableView.heightAnchor.constraintEqualToConstant(view.frame.height).active = true

  }

  func setupActivityIndicator() {
    self.view.addSubview(activityIndicator)
    activityIndicator.centerXAnchor.constraintEqualToAnchor(paymentTableView.centerXAnchor).active = true
    activityIndicator.topAnchor.constraintEqualToAnchor(paymentTableView.topAnchor, constant: 100).active = true
  }
}

//Private methods to load data
extension PaymentViewController {
  private func loadAccountInfo() {
    self.paymentTableView.userInteractionEnabled = false
    last4 = " No Cards"
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    self.activityIndicator.startAnimating()
    paymentModule.getPayments("uid=" + uid!) { jsonArray in
      for paymentInfo in jsonArray as! [[String:AnyObject]] {
        let isDefault = paymentInfo["default"] as! Bool
        if (isDefault == true) {
          self.last4 = paymentInfo["last4"] as! String
          break
        }
      }

      let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
      self.paymentModule.getBalance(uid) { convertedDict in
        if let _ = convertedDict["balance"] as? Double {
          self.balance = convertedDict["balance"] as! Double
        }
        dispatch_async(dispatch_get_main_queue()) {
          self.activityIndicator.stopAnimating()
          self.paymentTableView.reloadData()
          self.paymentTableView.userInteractionEnabled = true
        }
      }
    }
  }
}

// datasource and delegate for tableView
extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! paymentTableViewCell
    if (indexPath.row == 0) {
      cell.iconImage.image = UIImage(named: "cards")
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

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    view.font = UIFont.systemFontOfSize(14)
    view.textAlignment = .Left
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let value: UILabel = {
    let view = UILabel()
    view.font = UIFont.systemFontOfSize(13)
    view.textAlignment = .Right
    view.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.addSubview(iconImage)
    self.addSubview(title)
    self.addSubview(value)

    iconImage.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    iconImage.widthAnchor.constraintEqualToConstant(18).active = true
    iconImage.heightAnchor.constraintEqualToConstant(14).active = true
    iconImage.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 8).active = true

    title.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    title.leadingAnchor.constraintEqualToAnchor(iconImage.leadingAnchor, constant: 48).active = true
    title.topAnchor.constraintEqualToAnchor(topAnchor, constant: 12).active = true
    title.trailingAnchor.constraintEqualToAnchor(value.leadingAnchor, constant: 48).active = true


    value.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    value.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -16).active = true
    value.topAnchor.constraintEqualToAnchor(topAnchor, constant: 12).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
