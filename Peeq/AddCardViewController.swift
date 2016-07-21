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

  @IBOutlet weak var saveButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()

    stripeView = STPPaymentCardTextField(frame: CGRectMake(15, 100, 290, 100))
    stripeView.delegate = self
    view.addSubview(stripeView)
    saveButton.enabled = false


    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
    if (textField.isValid) {
      let card: STPCardParams = STPCardParams();
      card.number = textField.cardNumber;
      card.expMonth = textField.expirationMonth;
      card.expYear = textField.expirationYear;
      card.cvc = textField.cvc;

      let client = STPAPIClient.init(publishableKey: "pk_test_Mn99c0kYcKvT4yDyYNORk4cX")
      client.createTokenWithCard(card) { token, error in
        if (error != nil) {
          print(error)
        } else {
          print("card is valid and the token is: \(token!)")
        }
      }
    }
  }

}
