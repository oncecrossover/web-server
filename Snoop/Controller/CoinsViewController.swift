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
  lazy var navBar: UINavigationBar = {
    let navbar = UINavigationBar(frame: CGRectMake(0, 0,
      self.view.frame.width, 64));
    navbar.backgroundColor = UIColor.whiteColor()
    navbar.titleTextAttributes = [ NSForegroundColorAttributeName:UIColor.blackColor()]
    let navItem = UINavigationItem(title: "My Coins")
    let closeImage = UIImageView()
    closeImage.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
    closeImage.image = UIImage(named : "close")?.imageWithRenderingMode(.AlwaysTemplate)
    closeImage.contentMode = .ScaleAspectFit
    closeImage.tintColor = UIColor.blackColor()
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
    table.separatorInset = UIEdgeInsetsZero
    table.registerClass(CoinsTableViewCell.self, forCellReuseIdentifier: self.summaryCellId)
    table.registerClass(CoinPriceTableViewCell.self, forCellReuseIdentifier: self.priceCellId)
    table.registerClass(CoinPriceTableHeaderViewCell.self, forHeaderFooterViewReuseIdentifier: self.headerCellId)
    return table
  }()

  let consumableProducts = ["com.snoop.Snoop.addcoins5", "com.snoop.Snoop.addcoins20", "com.snoop.Snoop.addcoins50", "com.snoop.Snoop.addcoins100"]
  var product = SKProduct()

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self) // app might crash without removing observer
  }
}

//override extension
extension CoinsViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    coinsTable.tableHeaderView = navBar
    self.view.addSubview(coinsTable)
    self.view.addConstraintsWithFormat("H:|[v0]|", views: coinsTable)
    self.view.addConstraintsWithFormat("V:|[v0]|", views: coinsTable)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.addCoins(_:)), name: self.notificationName, object: nil)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.coinsTable.reloadData()
  }
}

//IB related actions
extension CoinsViewController {
  func closeButtonTapped() {
    let vc = self.homeViewController
    self.dismissViewControllerAnimated(true) {
      vc?.loadCoinCount(self.numOfCoins)
    }
  }
}

// Private methods
extension CoinsViewController {
  func addCoins(notification: NSNotification) {
    if let uid = notification.userInfo?["uid"] as? String {
      let currentUid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
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
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if (section == 1) {
      let myCell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(self.headerCellId) as! CoinPriceTableHeaderViewCell
      return myCell
    }
    else {
      return nil
    }
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if (section == 1) {
      return 60
    }
    else {
      return 0
    }
  }
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if (indexPath.section == 0) {
      return 70
    }
    else {
      return 50
    }
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return 1
    }
    else {
      return consumableProducts.count
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if (indexPath.section == 1) {
      let myCell = tableView.dequeueReusableCellWithIdentifier(self.priceCellId, forIndexPath: indexPath) as! CoinPriceTableViewCell
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
      let myCell = tableView.dequeueReusableCellWithIdentifier(self.summaryCellId, forIndexPath: indexPath) as! CoinsTableViewCell
      print("number of coins is \(numOfCoins)")
      myCell.coinCount.text = String(numOfCoins)
      return myCell
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (indexPath.section == 1) {
      let productId = consumableProducts[indexPath.row]
      print("initiating " + productId)
      for product in IAPManager.sharedInstance.products {
        if (product.productIdentifier == productId) {
          let payment = SKPayment(product: product)
          SKPaymentQueue.defaultQueue().addPayment(payment)
        }
      }
    }
  }
}
