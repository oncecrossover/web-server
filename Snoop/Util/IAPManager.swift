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

  func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    let myProducts = response.products
    for product in myProducts {
      products.append(product)
    }
  }

  func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .Purchased:
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

  func complete(transaction: SKPaymentTransaction) {
    // TODO: we may want to send notification to users in the future
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }

  func fail(transaction: SKPaymentTransaction) {
    print("fail... \(transaction.error)")

    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }

  func addCoinsForUser(count: Int) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    coinModule.addCoins(uid, count: count) { result in
      if (result.isEmpty) {
        dispatch_async(dispatch_get_main_queue()) {

          NSNotificationCenter.defaultCenter().postNotificationName(self.notificationName, object: nil, userInfo: ["uid": uid, "amount" : count])
        }
      }
    }
  }
}
