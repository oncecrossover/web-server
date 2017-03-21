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

  lazy var saveButton: CustomButton = {
    let button = CustomButton()
    button.isEnabled = false
    button.setTitle("Save", for: UIControlState())
    button.setTitle("Save", for: .disabled)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(AddCardViewController.saveButtonTapped(_:)), for: .touchUpInside)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white

    stripeView = STPPaymentCardTextField(frame: CGRect(x: (self.view.frame.width - 300)/2, y: 100, width: 300, height: 60))
    stripeView.delegate = self
    view.addSubview(stripeView)
    view.addSubview(saveButton)

    // button constraints
    let height = self.tabBarController?.tabBar.frame.height
    saveButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -height!).isActive = true

    self.navigationItem.rightBarButtonItem = nil

  }

  func saveButtonTapped(_ sender: AnyObject) {
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Adding New Card...")

    let client = STPAPIClient.init(publishableKey: "pk_test_wyZIIuEmr4TQLHVnZHUxlTtm")
    client.createToken(withCard: card) { token, error in
      if (error != nil) {
        print(error!)
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
        }
      }
      else {
        self.paymentModule.createPayment(token?.tokenId) { result in
          if (!result.isEmpty) {
            print("error is \(result)")
            DispatchQueue.main.async {
              activityIndicator.hide(animated: true)
              self.utility.displayAlertMessage("Please try again later", title: "Failed to Add your card", sender: self)
            }
          }
          else {
            DispatchQueue.main.async {
              self.saveButton.isEnabled = false
              activityIndicator.hide(animated: true)
              _ = self.navigationController?.popViewController(animated: true)
            }
          }
        }

      }
    }
  }

  func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
    if (textField.isValid) {
      self.card.number = textField.cardNumber;
      self.card.expMonth = textField.expirationMonth;
      self.card.expYear = textField.expirationYear;
      self.card.cvc = textField.cvc;
      saveButton.isEnabled = true
      stripeView.resignFirstResponder()
    }
  }

}
