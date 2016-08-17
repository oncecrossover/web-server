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
  var questionModule = Question()
  var chargeInfo: (amount: Double!, type: String!, quandaId: Int!, asker: String!, responder: String!, index: Int!)
  var submittedQuestion: (amount: Double!, type: String!, question: String!, askerId: String!, responderId: String!)
  var isPaid = false
  var isSnooped = true
  var chargeAmount = 0.0

  override func viewDidLoad() {
    super.viewDidLoad()

    if (chargeInfo.amount != nil) {
      chargeLabel.text = "$" + String(chargeInfo.amount)
      chargeAmount = chargeInfo.amount
    }
    else {
      chargeLabel.text = "$" + String(submittedQuestion.amount)
      chargeAmount = submittedQuestion.amount
    }

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
    let myUrl = NSURL(string: "http://localhost:8080/balances/" + uid!)
    self.generics.getObjectById(myUrl!) { dict in
      let balance = dict["balance"] as! Double
      if (balance > self.chargeAmount) {
        dispatch_async(dispatch_get_main_queue()) {
          self.balanceLabel.text = "Balance(" + String(balance) + ")"
          self.payButton.enabled = true
        }
      }
      else {
        self.paymentModule.getPayments("uid=" + uid!) { jsonArray in
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
            dispatch_async(dispatch_get_main_queue()) {
              self.balanceLabel.text = "Balance(" + String(balance) + ")"
              self.payButton.enabled = false
            }
          }
        }
      }

    }
  }

  @IBAction func payButtonTapped(sender: AnyObject) {
    if (isSnooped){
      submitPaymentForSnoop()
    }
    else {
      submitPaymentForQuestion()
    }
  }

  func submitPaymentForSnoop() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let quandaData: [String:AnyObject] = ["id": chargeInfo.quandaId, "asker": chargeInfo.asker,
      "responder": chargeInfo.responder]
    let jsonData: [String:AnyObject] = ["uid": uid!, "type": "SNOOPED", "quanda": quandaData]
    generics.createObject("http://localhost:8080/qatransactions", jsonData: jsonData) { result in
      var message = "Payment submitted successfully!"
      self.isPaid = true
      if (!result.isEmpty) {
        message = result
        self.isPaid = false
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.displayPaymentResultMessage(message)
      }
    }
  }

  func submitPaymentForQuestion() {
    let asker = submittedQuestion.askerId
    let responder = submittedQuestion.responderId
    let question = submittedQuestion.question
    let quandaData = ["question" : question, "responder" : responder, "rate" : submittedQuestion.amount]
    let jsonData:[String: AnyObject] = ["uid": asker, "type" : "ASKED", "quanda" : quandaData]
    generics.createObject("http://127.0.0.1:8080/qatransactions", jsonData: jsonData) { result in
      var message = "Your question is successfully submitted"
      self.isPaid = true
      if (!result.isEmpty) {
        message = result
        self.isPaid = false
      }
      dispatch_async(dispatch_get_main_queue()) {
        self.displayPaymentResultMessage(message)
      }

    }
  }

  func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? ViewController {
      if (isPaid) {
        controller.paymentInfo = (quandaId: chargeInfo.quandaId, index: chargeInfo.index)
      }
    }
    else if let controller = viewController as? AskViewController {
      if (isPaid) {
        controller.askButton.hidden = true
        controller.questionView.editable = false
      }
    }
  }

  func displayPaymentResultMessage(message: String!) {
    if (self.isPaid) {
      self.utility.displayAlertMessage(message, title: "OK", sender: self)
    }
    else {
      self.utility.displayAlertMessage(message, title: "ALERT", sender: self)
    }
  }
}