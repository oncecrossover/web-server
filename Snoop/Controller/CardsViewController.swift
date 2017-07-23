//
//  PaymentViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/17/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import Stripe

class CardsViewController: UIViewController {

  var cards:[(id: String?, lastFour: String?, brand: String?, isDefault: Bool?)] = []
  var paymentModule = Payment()

  let cellId = "cardCell"
  let regularCell = "regularCell"

  lazy var cardsTableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 40
    tableView.register(cardsTableViewCell.self, forCellReuseIdentifier: self.cellId)
    tableView.register(addCardTableViewCell.self, forCellReuseIdentifier: self.regularCell)
    return tableView
  }()

  let activityIndicator : UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.color = UIColor.defaultColor()
    indicator.hidesWhenStopped = true
    return indicator
  }()
}

// override method
extension CardsViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    self.navigationItem.title = "Manage Cards"
    setupTableView()
    setupActivityIndicator()
  }


  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadData()
  }
}

// private methods
extension CardsViewController {

  func loadData(){
    activityIndicator.startAnimating()
    cardsTableView.isUserInteractionEnabled = false
    cards = []
    let uid = UserDefaults.standard.string(forKey: "email")
    paymentModule.getPayments("uid=" + uid!) { jsonArray in
      for paymentInfo in jsonArray as! [[String:AnyObject]] {
        let lastFour = paymentInfo["last4"] as! String
        let id = paymentInfo["id"] as! String
        let brand = paymentInfo["brand"]! as! String
        let isDefault = paymentInfo["default"] as! Bool
        self.cards.append((id: id, lastFour: lastFour, brand: brand, isDefault: isDefault))
      }

      DispatchQueue.main.async {
        self.activityIndicator.stopAnimating()
        self.cardsTableView.reloadData()
        self.cardsTableView.isUserInteractionEnabled = true
      }
    }
  }

  func setupTableView() {
    cardsTableView.tableFooterView = UIView()
    cardsTableView.tableHeaderView = UIView()
    cardsTableView.separatorInset = UIEdgeInsets.zero

    self.view.addSubview(cardsTableView)

    //Set up constraints
    cardsTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    cardsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    cardsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    cardsTableView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true

  }

  func setupActivityIndicator() {
    self.view.addSubview(activityIndicator)
    activityIndicator.centerXAnchor.constraint(equalTo: cardsTableView.centerXAnchor).isActive = true
    activityIndicator.topAnchor.constraint(equalTo: cardsTableView.topAnchor, constant: 100).isActive = true
  }
}

// delegate and data source
extension CardsViewController : UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if (indexPath.section == 0) {
      return true
    }

    return false
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == .delete) {
      let id = cards[indexPath.row].id
      cards.remove(at: indexPath.row)
      paymentModule.deletePayment(id!) {result in
        if (result.isEmpty) {
          DispatchQueue.main.async {
            self.cardsTableView.reloadData()
          }
        }
      }
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return cards.count
    }
    else {
      return 1
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.section == 0) {
      let myCell = tableView.dequeueReusableCell(withIdentifier: cellId) as! cardsTableViewCell
      let cardInfo = cards[indexPath.row]
      myCell.icon.image = UIImage(named: "cards")
      myCell.brand.text = cardInfo.brand
      myCell.value.text = "xxxx " + cardInfo.lastFour!
      if (cardInfo.isDefault == true) {
        myCell.accessoryType = .checkmark
      }
      else {
        myCell.accessoryType = .none
      }
      return myCell
    }
    else {
      let myCell = tableView.dequeueReusableCell(withIdentifier: regularCell) as! addCardTableViewCell
      myCell.icon.image = UIImage(named: "addCard")
      return myCell
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath.section == 1) {
      let backItem = UIBarButtonItem()
      backItem.title = "Back"
      navigationItem.backBarButtonItem = backItem
      let dvc = AddCardViewController()
      self.navigationController?.pushViewController(dvc, animated: true)
    }
  }
}

class addCardTableViewCell: UITableViewCell {
  let icon: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.addSubview(icon)
    icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    icon.widthAnchor.constraint(equalToConstant: 100).isActive = true
    icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
class cardsTableViewCell: UITableViewCell {
  let icon: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let brand: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .left
    return label
  }()

  let value: UILabel = {
    let value = UILabel()
    value.translatesAutoresizingMaskIntoConstraints = false
    value.font = UIFont.systemFont(ofSize: 13)
    value.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    value.textAlignment = .center
    return value
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.addSubview(icon)
    self.addSubview(brand)
    self.addSubview(value)

    // constraints for icon
    icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    icon.widthAnchor.constraint(equalToConstant: 18).isActive = true
    icon.heightAnchor.constraint(equalToConstant: 14).isActive = true
    icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true

    // constraints for brand
    brand.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    brand.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 16).isActive = true
    brand.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
    brand.widthAnchor.constraint(equalToConstant: 120).isActive = true

    // constraint for value
    value.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    value.leadingAnchor.constraint(equalTo: brand.trailingAnchor, constant: 8).isActive = true
    value.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
    value.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
