//
//  ChargeViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 8/11/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ChargeViewController: UIViewController, UINavigationControllerDelegate {

  @IBOutlet weak var chargeLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!

  @IBOutlet weak var payButton: UIButton!
  var generics = Generics()
  var paymentModule = Payment()
  var utility = UIUtility()
  var chargeInfo: (amount: Double!, type: String!, quandaId: Int!, index: Int!)
  var isPaid = false

  override func viewDidLoad() {
    super.viewDidLoad()

    chargeLabel.text = "$" + String(chargeInfo.amount)
    payButton.enabled = false

    navigationController?.delegate = self

    // Do any additional setup after loading the view.
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadPaymentMethod()
  }

  func loadPaymentMethod() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    paymentModule.getPayments("uid=" + uid!) { jsonArray in
      var usingCard = false
      for paymentInfo in jsonArray {
        if (paymentInfo["default"] as! Bool == true) {
          usingCard = true
          let brand = paymentInfo["brand"] as! String
          let last4 = paymentInfo["last4"] as! String
          dispatch_async(dispatch_get_main_queue()) {
            self.balanceLabel.text = brand + " " + last4
            self.payButton.enabled = true
          }
          return
        }
      }

      if (!usingCard) {
        let myUrl = NSURL(string: "http://localhost:8080/balances/" + uid!)
        self.generics.getObjectById(myUrl!) { dict in
          let balance = dict["balance"] as! Double
          dispatch_async(dispatch_get_main_queue()) {
            self.balanceLabel.text = "Balance(" + String(balance) + ")"
            if (self.chargeInfo.amount > balance) {
              self.payButton.enabled = false
            }
          }
        }
      }
    }
  }

  @IBAction func payButtonTapped(sender: AnyObject) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let jsonData = ["uid": uid!, "type": chargeInfo.type, "quandaId" : chargeInfo.quandaId, "amount" : chargeInfo.amount]
    generics.createObject("http://localhost:8080/qatransactions", jsonData: jsonData as! [String:AnyObject]) { result in
      var message = "Payment submitted successfully!"
      if (!result.isEmpty) {
        message = result
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.utility.displayAlertMessage(message, title: "OK", sender: self)
        self.isPaid = true
      }
    }
  }

  func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? ViewController {
      if (isPaid) {
        controller.paymentInfo = (quandaId: chargeInfo.quandaId, index: chargeInfo.index)
      }
    }
  }
}
