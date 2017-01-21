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

  var cards:[(id: Int!, lastFour: String!, brand: String!, isDefault: Bool!)] = []
  var paymentModule = Payment()

  let cellId = "cardCell"
  let regularCell = "regularCell"

  lazy var cardsTableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 40
    tableView.registerClass(cardsTableViewCell.self, forCellReuseIdentifier: self.cellId)
    tableView.registerClass(addCardTableViewCell.self, forCellReuseIdentifier: self.regularCell)
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
    view.backgroundColor = UIColor.whiteColor()
    self.navigationItem.title = "Manage Cards"
    setupTableView()
    setupActivityIndicator()
  }


  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadData()
  }
}

// private methods
extension CardsViewController {

  func loadData(){
    activityIndicator.startAnimating()
    cardsTableView.userInteractionEnabled = false
    cards = []
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    paymentModule.getPayments("uid=" + uid!) { jsonArray in
      for paymentInfo in jsonArray as! [[String:AnyObject]] {
        let lastFour = paymentInfo["last4"] as! String
        let id = paymentInfo["id"] as! Int
        let brand = paymentInfo["brand"]! as! String
        let isDefault = paymentInfo["default"] as! Bool
        self.cards.append((id: id, lastFour: lastFour, brand: brand, isDefault: isDefault))
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.activityIndicator.stopAnimating()
        self.cardsTableView.reloadData()
        self.cardsTableView.userInteractionEnabled = true
      }
    }
  }

  func setupTableView() {
    cardsTableView.tableFooterView = UIView()
    cardsTableView.tableHeaderView = UIView()
    cardsTableView.separatorInset = UIEdgeInsetsZero

    self.view.addSubview(cardsTableView)

    //Set up constraints
    cardsTableView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    cardsTableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
    cardsTableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
    cardsTableView.heightAnchor.constraintEqualToConstant(view.frame.height).active = true

  }

  func setupActivityIndicator() {
    self.view.addSubview(activityIndicator)
    activityIndicator.centerXAnchor.constraintEqualToAnchor(cardsTableView.centerXAnchor).active = true
    activityIndicator.topAnchor.constraintEqualToAnchor(cardsTableView.topAnchor, constant: 100).active = true
  }
}

// delegate and data source
extension CardsViewController : UITableViewDataSource, UITableViewDelegate {

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if (indexPath.section == 0) {
      return true
    }

    return false
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == .Delete) {
      let id = cards[indexPath.row].id
      cards.removeAtIndex(indexPath.row)
      paymentModule.deletePayment(id) {result in
        if (result.isEmpty) {
          dispatch_async(dispatch_get_main_queue()) {
            self.cardsTableView.reloadData()
          }
        }
      }
    }
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return cards.count
    }
    else {
      return 1
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if (indexPath.section == 0) {
      let myCell = tableView.dequeueReusableCellWithIdentifier(cellId) as! cardsTableViewCell
      let cardInfo = cards[indexPath.row]
      myCell.icon.image = UIImage(named: "cards")
      myCell.brand.text = cardInfo.brand
      myCell.value.text = "xxxx " + cardInfo.lastFour
      if (cardInfo.isDefault == true) {
        myCell.accessoryType = .Checkmark
      }
      else {
        myCell.accessoryType = .None
      }
      return myCell
    }
    else {
      let myCell = tableView.dequeueReusableCellWithIdentifier(regularCell) as! addCardTableViewCell
      myCell.icon.image = UIImage(named: "addCard")
      return myCell
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    icon.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    icon.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    icon.widthAnchor.constraintEqualToConstant(100).active = true
    icon.heightAnchor.constraintEqualToConstant(30).active = true
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
    label.font = UIFont.systemFontOfSize(14)
    label.textAlignment = .Left
    return label
  }()

  let value: UILabel = {
    let value = UILabel()
    value.translatesAutoresizingMaskIntoConstraints = false
    value.font = UIFont.systemFontOfSize(13)
    value.textColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
    value.textAlignment = .Center
    return value
  }()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.addSubview(icon)
    self.addSubview(brand)
    self.addSubview(value)

    // constraints for icon
    icon.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    icon.widthAnchor.constraintEqualToConstant(18).active = true
    icon.heightAnchor.constraintEqualToConstant(14).active = true
    icon.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 8).active = true

    // constraints for brand
    brand.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    brand.leadingAnchor.constraintEqualToAnchor(icon.trailingAnchor, constant: 16).active = true
    brand.topAnchor.constraintEqualToAnchor(topAnchor, constant: 12).active = true
    brand.widthAnchor.constraintEqualToConstant(120).active = true

    // constraint for value
    value.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    value.leadingAnchor.constraintEqualToAnchor(brand.trailingAnchor, constant: 8).active = true
    value.topAnchor.constraintEqualToAnchor(topAnchor, constant: 12).active = true
    value.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -60).active = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
