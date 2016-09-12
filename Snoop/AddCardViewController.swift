//
//  AddCardViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/20/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import Stripe

class AddCardViewController: UIViewController, STPPaymentCardTextFieldDelegate {

  var stripeView: STPPaymentCardTextField = STPPaymentCardTextField()
  var card: STPCardParams = STPCardParams()
  var paymentModule = Payment()
  var utility = UIUtility()

  @IBOutlet weak var saveButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()

    stripeView = STPPaymentCardTextField(frame: CGRectMake((self.view.frame.width - 300)/2, 100, 300, 60))
    stripeView.delegate = self
    view.addSubview(stripeView)
    saveButton.enabled = false

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func saveButtonTapped(sender: AnyObject) {
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Adding New Card...")

    let client = STPAPIClient.init(publishableKey: "pk_test_wyZIIuEmr4TQLHVnZHUxlTtm")
    client.createTokenWithCard(card) { token, error in
      if (error != nil) {
        print(error)
        dispatch_async(dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
        }
      }
      else {
        self.paymentModule.createPayment(token?.tokenId) { result in
          if (!result.isEmpty) {
            print("error is \(result)")
            dispatch_async(dispatch_get_main_queue()) {
              activityIndicator.hideAnimated(true)
              self.utility.displayAlertMessage("Please try again later", title: "Failed to Add your card", sender: self)
            }
          }
          else {
            dispatch_async(dispatch_get_main_queue()) {
              self.saveButton.enabled = false
              activityIndicator.hideAnimated(true)
              self.navigationController?.popViewControllerAnimated(true)
            }
          }
        }

      }
    }
  }

  func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
    if (textField.isValid) {
      self.card.number = textField.cardNumber;
      self.card.expMonth = textField.expirationMonth;
      self.card.expYear = textField.expirationYear;
      self.card.cvc = textField.cvc;
      saveButton.enabled = true
      stripeView.resignFirstResponder()
    }
  }

}
