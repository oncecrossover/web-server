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
  var chargeInfo: (amount: Int?, type: String?, quandaId: Int?)
  var submittedQuestion: (amount: Int?, type: String?, question: String?, askerId: String?, responderId: String?)
  var isPaid = false
  var isSnooped = true
  var chargeAmount = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    if (chargeInfo.amount != nil) {
      chargeLabel.text = "$" + String(describing: chargeInfo.amount)
      chargeAmount = chargeInfo.amount!
    }
    else {
      chargeLabel.text = "$" + String(describing: submittedQuestion.amount)
      chargeAmount = submittedQuestion.amount!
    }

    payButton.isEnabled = false
    addCardButton.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    addCardButton.setTitleColor(UIColor.disabledColor(), for: .disabled)
    addCardButton.titleLabel!.font = UIFont.systemFont(ofSize: 13)

    header.textColor = UIColor.secondaryTextColor()
    paymentLabel.textColor = UIColor.secondaryTextColor()

    balanceLabel.font = UIFont.systemFont(ofSize: 13)

    navigationController?.delegate = self

    // Do any additional setup after loading the view.
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadPaymentMethod()
  }

  func loadPaymentMethod() {
    let uid = UserDefaults.standard.string(forKey: "email")
    let myUrl = URL(string: generics.HTTPHOST + "balances/" + uid!)
    self.generics.getObjectById(myUrl!) { dict in
      let balance = dict["balance"] as! Double
      if (balance >= Double(self.chargeAmount)) {
        DispatchQueue.main.async {
          self.balanceLabel.text = "Balance(" + String(balance) + ")"
          self.addCardButton.isEnabled = false
          self.payButton.isEnabled = true
          if (self.chargeAmount == 0) {
            self.payButton.setTitle("Get It For Free", for: UIControlState())
          }
          else {
            self.payButton.setTitle("Pay Now", for: UIControlState())
          }
        }
      }
      else {
        self.paymentModule.getPayments("uid=" + uid!) { jsonArray in
          var hasCardOnFile = false
          for paymentInfo in jsonArray as! [[String: AnyObject]] {
            if (paymentInfo["default"] as! Bool == true) {
              hasCardOnFile = true
              let brand = paymentInfo["brand"] as! String
              let last4 = paymentInfo["last4"] as! String
              DispatchQueue.main.async {
                self.balanceLabel.text = brand + " " + last4
                self.addCardButton.isEnabled = false
                self.payButton.isEnabled = true
              }
              return
            }
          }

          if (!hasCardOnFile) {
            DispatchQueue.main.async {
              self.balanceLabel.text = "Balance(" + String(balance) + ")"
              self.payButton.isEnabled = false
              self.addCardButton.isEnabled = true
            }
          }
        }
      }

    }
  }

  @IBAction func payButtonTapped(_ sender: AnyObject) {
    if (isSnooped){
      submitPaymentForSnoop()
    }
    else {
      submitPaymentForQuestion()
    }
  }

  @IBAction func addCardButtonTapped(_ sender: AnyObject) {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
    let dvc = AddCardViewController()
    self.navigationController?.pushViewController(dvc, animated: true)
  }
  func submitPaymentForSnoop() {
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Submitting Your Payment...")
    let uid = UserDefaults.standard.string(forKey: "email")
    let quandaData: [String:AnyObject] = ["id": chargeInfo.quandaId as AnyObject]
    let jsonData: [String:AnyObject] = ["uid": uid! as AnyObject, "type": "SNOOPED" as AnyObject, "quanda": quandaData as AnyObject]
    generics.createObject(generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
      self.isPaid = true
      if (!result.isEmpty) {
        self.isPaid = false
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
          self.displayPaymentResultMessage(result)
        }
      }
      else {
        let time = DispatchTime.now() + Double(1 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
          activityIndicator.hide(animated: true)
          self.performSegue(withIdentifier: "paymentToConfirmation", sender: self)
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
    let jsonData:[String: AnyObject] = ["uid": asker as AnyObject, "type" : "ASKED" as AnyObject, "quanda" : quandaData as AnyObject]
    generics.createObject(generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
      self.isPaid = true
      if (!result.isEmpty) {
        self.isPaid = false
      }
      else {
        let time = DispatchTime.now() + Double(1 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
          activityIndicator.hide(animated: true)
        }
      }
    }
  }

  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? ViewController {
      if (isPaid) {
        controller.paidSnoops.insert(chargeInfo.quandaId!)
        controller.feedTable.reloadData()
      }
    }
    else if let controller = viewController as? AskViewController {
      if (isPaid) {
        controller.questionView.text = controller.placeholder
        controller.questionView.textColor = UIColor.secondaryTextColor()
      }
    }
  }

  func displayPaymentResultMessage(_ message: String!) {
    if (self.isPaid) {
      self.utility.displayAlertMessage(message, title: "OK", sender: self)
    }
    else {
      self.utility.displayAlertMessage(message, title: "ALERT", sender: self)
    }
  }

  @IBAction func unwindPage(_ segue: UIStoryboardSegue) {
    _ = self.navigationController?.popViewController(animated: true)
  }
}
