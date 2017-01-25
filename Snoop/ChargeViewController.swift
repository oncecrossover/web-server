//
//  ChargeViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 8/11/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ChargeViewController: UIViewController, UINavigationControllerDelegate{

  @IBOutlet weak var chargeLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var addCardButton: UIButton!

  @IBOutlet weak var paymentLabel: UILabel!
  @IBOutlet weak var header: UILabel!
  @IBOutlet weak var payButton: UIButton!
  var generics = Generics()
  var paymentModule = Payment()
  var utility = UIUtility()
  var questionModule = Question()
  var chargeInfo: (amount: Double!, type: String!, quandaId: Int!)
  var submittedQuestion: (amount: Double!, type: String!, question: String!, askerId: String!, responderId: String!)
  var isPaid = false
  var isSnooped = true
  var chargeAmount = 0.0

  override func viewDidLoad() {
    super.viewDidLoad()

    if (chargeInfo.amount != nil) {
      chargeLabel.text = "$1.50"
      chargeAmount = chargeInfo.amount
    }
    else {
      chargeLabel.text = "$" + String(submittedQuestion.amount)
      chargeAmount = submittedQuestion.amount
    }

    payButton.enabled = false
    addCardButton.setTitleColor(UIColor.defaultColor(), forState: .Normal)
    addCardButton.titleLabel!.font = UIFont.systemFontOfSize(13)

    header.textColor = UIColor.secondaryTextColor()
    paymentLabel.textColor = UIColor.secondaryTextColor()

    balanceLabel.font = UIFont.systemFontOfSize(13)

    navigationController?.delegate = self

    // Do any additional setup after loading the view.
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadPaymentMethod()
  }

  func loadPaymentMethod() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let myUrl = NSURL(string: generics.HTTPHOST + "balances/" + uid!)
    self.generics.getObjectById(myUrl!) { dict in
      let balance = dict["balance"] as! Double
      if (balance > self.chargeAmount) {
        dispatch_async(dispatch_get_main_queue()) {
          self.balanceLabel.text = "Balance(" + String(balance) + ")"
          self.addCardButton.enabled = false
          self.payButton.enabled = true
        }
      }
      else {
        self.paymentModule.getPayments("uid=" + uid!) { jsonArray in
          var hasCardOnFile = false
          for paymentInfo in jsonArray {
            if (paymentInfo["default"] as! Bool == true) {
              hasCardOnFile = true
              let brand = paymentInfo["brand"] as! String
              let last4 = paymentInfo["last4"] as! String
              dispatch_async(dispatch_get_main_queue()) {
                self.balanceLabel.text = brand + " " + last4
                self.addCardButton.enabled = false
                self.payButton.enabled = true
              }
              return
            }
          }

          if (!hasCardOnFile) {
            dispatch_async(dispatch_get_main_queue()) {
              self.balanceLabel.text = "Balance(" + String(balance) + ")"
              self.payButton.enabled = false
              self.addCardButton.enabled = true
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

  @IBAction func addCardButtonTapped(sender: AnyObject) {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
    let dvc = AddCardViewController()
    self.navigationController?.pushViewController(dvc, animated: true)
  }
  func submitPaymentForSnoop() {
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Submitting Your Payment...")
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let quandaData: [String:AnyObject] = ["id": chargeInfo.quandaId]
    let jsonData: [String:AnyObject] = ["uid": uid!, "type": "SNOOPED", "quanda": quandaData]
    generics.createObject(generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
      self.isPaid = true
      if (!result.isEmpty) {
        self.isPaid = false
        dispatch_async(dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.displayPaymentResultMessage(result)
        }
      }
      else {
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.performSegueWithIdentifier("paymentToConfirmation", sender: self)
        }
      }
    }
  }

  func submitPaymentForQuestion() {
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Submitting Your Question...")
    let asker = submittedQuestion.askerId
    let responder = submittedQuestion.responderId
    let question = submittedQuestion.question
    let quandaData = ["question" : question, "responder" : responder]
    let jsonData:[String: AnyObject] = ["uid": asker, "type" : "ASKED", "quanda" : quandaData]
    generics.createObject(generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
      self.isPaid = true
      if (!result.isEmpty) {
        self.isPaid = false
        dispatch_async(dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.displayPaymentResultMessage(result)
        }
      }
      else {
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.performSegueWithIdentifier("paymentToConfirmation", sender: self)
        }
      }
    }
  }

  func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? ViewController {
      if (isPaid) {
        controller.paidSnoops.insert(chargeInfo.quandaId)
        controller.feedTable.reloadData()
      }
    }
    else if let controller = viewController as? AskViewController {
      if (isPaid) {
        controller.questionView.text = controller.placeholder
        controller.questionView.textColor = UIColor.lightGrayColor()
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

  @IBAction func unwindPage(segue: UIStoryboardSegue) {
    self.navigationController?.popViewControllerAnimated(true)
  }
}
