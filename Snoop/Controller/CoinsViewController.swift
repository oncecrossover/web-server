//
//  CoinsViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/5/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit
import StoreKit

class CoinsViewController: UIViewController {

  let summaryCellId = "summaryCell"
  let priceCellId = "priceCell"
  let headerCellId = "headerCell"
  var numOfCoins = 0

  lazy var coinModule = Coin()
  let notificationName = "coinsAdded"

  var homeViewController: ViewController?
  var askViewController: AskViewController?

  lazy var navBar: UINavigationBar = {
    let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0,
      width: self.view.frame.width, height: 64));
    navbar.backgroundColor = UIColor.white
    navbar.titleTextAttributes = [ NSForegroundColorAttributeName:UIColor.black]
    let navItem = UINavigationItem(title: "My Coins")
    let closeImage = UIImageView()
    closeImage.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
    closeImage.image = UIImage(named : "close")?.withRenderingMode(.alwaysTemplate)
    closeImage.contentMode = .scaleAspectFit
    closeImage.tintColor = UIColor.black
    closeImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped)))
    navItem.leftBarButtonItem = UIBarButtonItem(customView: closeImage)
    navbar.items = [navItem]

    return navbar
  }()

  lazy var coinsTable : UITableView = {
    let table = UITableView()
    table.delegate = self
    table.dataSource = self
    table.tableFooterView = UIView()
    table.separatorInset = UIEdgeInsets.zero
    table.register(CoinsTableViewCell.self, forCellReuseIdentifier: self.summaryCellId)
    table.register(CoinPriceTableViewCell.self, forCellReuseIdentifier: self.priceCellId)
    table.register(CoinPriceTableHeaderViewCell.self, forHeaderFooterViewReuseIdentifier: self.headerCellId)
    return table
  }()

  let consumableProducts = ["com.snoop.Snoop.addcoins5", "com.snoop.Snoop.addcoins20", "com.snoop.Snoop.addcoins50", "com.snoop.Snoop.addcoins100"]
  var product = SKProduct()

  deinit {
    NotificationCenter.default.removeObserver(self) // app might crash without removing observer
  }
}

//override extension
extension CoinsViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white

    coinsTable.tableHeaderView = navBar
    self.view.addSubview(coinsTable)
    self.view.addConstraintsWithFormat("H:|[v0]|", views: coinsTable)
    self.view.addConstraintsWithFormat("V:|[v0]|", views: coinsTable)

    NotificationCenter.default.addObserver(self, selector: #selector(self.addCoins(_:)), name: NSNotification.Name(rawValue: self.notificationName), object: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    coinModule.getCoinsCount() { result in
      let coinCount = result["amount"] as! Int
      self.numOfCoins = coinCount
      DispatchQueue.main.async {
        self.coinsTable.reloadData()
      }
    }
  }
}

//IB related actions
extension CoinsViewController {
  func closeButtonTapped() {
    let vc = self.homeViewController
    let avc = self.askViewController
    self.dismiss(animated: true) {
      vc?.loadCoinCount(self.numOfCoins)
      avc?.coinCount = self.numOfCoins
    }
  }
}

// Private methods
extension CoinsViewController {
  func addCoins(_ notification: Notification) {
    if let uid = notification.userInfo?["uid"] as? Int {
      let currentUid = UserDefaults.standard.integer(forKey: "uid")
      // Check if these two are the same user if app relaunches or user signs out.
      if (currentUid == uid) {
        if let amount = notification.userInfo?["amount"] as? Int {
          self.numOfCoins += amount
          self.coinsTable.reloadData()
        }
      }
    }
  }
}

// UITableview delegate
extension CoinsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if (section == 1) {
      let myCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerCellId) as! CoinPriceTableHeaderViewCell
      return myCell
    }
    else {
      return nil
    }
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if (section == 1) {
      return 60
    }
    else {
      return 0
    }
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath.section == 0) {
      return 70
    }
    else {
      return 50
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return 1
    }
    else {
      return consumableProducts.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.section == 1) {
      let myCell = tableView.dequeueReusableCell(withIdentifier: self.priceCellId, for: indexPath) as! CoinPriceTableViewCell
      if (indexPath.row == 1) {
        myCell.popularLabel.text = "MOST POPULAR!"
        myCell.price.text = "$19.99"
        myCell.coinCount.text = "520"
      }
      else {
        myCell.popularLabel.text = ""
      }

      if (indexPath.row == 0) {
        myCell.coinCount.text = "125"
        myCell.price.text = "$4.99"
      }
      else if (indexPath.row == 2) {
        myCell.coinCount.text = "1350"
        myCell.price.text = "$49.99"
      }
      else if (indexPath.row == 3) {
        myCell.coinCount.text = "2800"
        myCell.price.text = "$99.99"
      }

      return myCell
    }
    else {
      let myCell = tableView.dequeueReusableCell(withIdentifier: self.summaryCellId, for: indexPath) as! CoinsTableViewCell
      myCell.coinCount.text = String(numOfCoins)
      return myCell
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath.section == 1) {
      let productId = consumableProducts[indexPath.row]
      print("initiating " + productId)
      for product in IAPManager.sharedInstance.products {
        if (product.productIdentifier == productId) {
          let payment = SKPayment(product: product)
          SKPaymentQueue.default().add(payment)
        }
      }
    }
  }
}
