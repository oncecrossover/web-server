//
//  IAPManager.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/6/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//
import StoreKit
class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
  static let sharedInstance = IAPManager()

  var products:[SKProduct] = []
  let consumableProducts = ["com.snoop.Snoop.addcoins5", "com.snoop.Snoop.addcoins20", "com.snoop.Snoop.addcoins50", "com.snoop.Snoop.addcoins100"]

  lazy var coinModule = Coin()

  let notificationName = "coinsAdded"
  override init() {
    super.init()
    if (SKPaymentQueue.canMakePayments()) {
      var productIds = Set<String>()
      for consumableProduct in consumableProducts {
        productIds.insert(consumableProduct)
      }

      let request = SKProductsRequest(productIdentifiers: productIds)
      request.delegate = self
      request.start()
    }
  }

  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let myProducts = response.products
    for product in myProducts {
      products.append(product)
    }
  }

  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction)
        let purchasedId = transaction.payment.productIdentifier
        switch (purchasedId) {
        case "com.snoop.Snoop.addcoins5":
          addCoinsForUser(125)
        case "com.snoop.Snoop.addcoins20":
          addCoinsForUser(520)
        case "com.snoop.Snoop.addcoins50":
          addCoinsForUser(1350)
        case "com.snoop.Snoop.addcoins100":
          addCoinsForUser(2800)
        default:
          print("unknow product purchased " + purchasedId)
          break
        }
        break
      case .failed:
        fail(transaction)
        break
      case .restored:
        restore(transaction)
        break
      case .deferred:
        break
      case .purchasing:
        break
      }
    }
  }

  func restore(_ transaction: SKPaymentTransaction) {
    guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }

    print("restore... \(productIdentifier)")
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  func complete(_ transaction: SKPaymentTransaction) {
    // TODO: we may want to send notification to users in the future
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  func fail(_ transaction: SKPaymentTransaction) {
    print("fail... \(String(describing: transaction.error))")

    SKPaymentQueue.default().finishTransaction(transaction)
  }

  func addCoinsForUser(_ count: Int) {
    let uid = UserDefaults.standard.integer(forKey: "uid")
    coinModule.addCoins(uid, count: count) { result in
      if (result.isEmpty) {
        DispatchQueue.main.async {

          NotificationCenter.default.post(name: Notification.Name(rawValue: self.notificationName), object: nil, userInfo: ["uid": uid, "amount" : count])
        }
      }
    }
  }
}
