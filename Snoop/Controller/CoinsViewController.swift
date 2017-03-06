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

  var products:[SKProduct] = []
  let consumableProducts = ["com.snoop.Snoop.addcoins5", "com.snoop.Snoop.addcoins20", "com.snoop.Snoop.addcoins50", "com.snoop.Snoop.addcoins100"]
  var product = SKProduct()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    coinsTable.tableHeaderView = navBar
    self.view.addSubview(coinsTable)
    self.view.addConstraintsWithFormat("H:|[v0]|", views: coinsTable)
    self.view.addConstraintsWithFormat("V:|[v0]|", views: coinsTable)

    if (SKPaymentQueue.canMakePayments()) {
      print("in-app purchase is enabled")
      var productIds = Set<String>()
      for consumableProduct in consumableProducts {
        productIds.insert(consumableProduct)
      }

      let request = SKProductsRequest(productIdentifiers: productIds)
      request.delegate = self
      request.start()
    }

    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
  }
}

extension CoinsViewController {
  func closeButtonTapped() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension CoinsViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
  func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    let myProducts = response.products
    for product in myProducts {

      print("new product")
      print(product.localizedTitle)
      print(product.productIdentifier)
      print(product.localizedDescription)
      print(product.price)
      products.append(product)
    }
  }

  func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .Purchased:
        let purchasedId = transaction.payment.productIdentifier
        switch (purchasedId) {
          case "com.snoop.Snoop.addcoins5":
            print("com.snoop.Snoop.addcoins5 is purchased")
            addCoinsForUser(125)
          case "com.snoop.Snoop.addcoins20":
            print("com.snoop.Snoop.addcoins20 is purchased")
            addCoinsForUser(520)
          case "com.snoop.Snoop.addcoins50":
            print("com.snoop.Snoop.addcoins50 is purchased")
            addCoinsForUser(1350)
          case "com.snoop.Snoop.addcoins100":
            print("com.snoop.Snoop.addcoins100 is purchased")
            addCoinsForUser(2800)
          default:
            print("unknow product purchased " + purchasedId)
            break
        }
        break
      case .Failed:
        fail(transaction)
        break
      case .Restored:
        restore(transaction)
        break
      case .Deferred:
        break
      case .Purchasing:
        break
      }
    }
  }

  func restore(transaction: SKPaymentTransaction) {
    guard let productIdentifier = transaction.originalTransaction?.payment.productIdentifier else { return }

    print("restore... \(productIdentifier)")
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }

  func fail(transaction: SKPaymentTransaction) {
    print("fail... \(transaction.error)")

    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }

  func addCoinsForUser(numOfCoins: Int) {

  }
}
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
      myCell.coinCount.text = String(numOfCoins)
      return myCell
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let productId = consumableProducts[indexPath.row]
    print("initiating " + productId)
    for product in products {
      if (product.productIdentifier == productId) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
      }
    }
  }
}
