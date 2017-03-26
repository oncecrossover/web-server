//
//  EarningsViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/16/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class EarningsViewController: UIViewController {
  var earning:Double!
  var contentOffset: CGPoint = CGPoint.zero
  let scrollView: UIScrollView = {
    let view = UIScrollView()
    view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    return view
  }()

  let slogan: UIImageView = {
    let slogan = UIImageView()
    slogan.contentMode = .scaleAspectFill
    slogan.image = UIImage(named: "slogan")
    return slogan
  }()

  let explainer: UIImageView = {
    let explainer = UIImageView()
    explainer.contentMode = .scaleAspectFill
    explainer.image = UIImage(named: "work")
    return explainer
  }()

  fileprivate lazy var input: EarningsView = {
    let view = EarningsView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setAmount(self.earning)
    view.updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    self.navigationItem.title = "My Earnings"
    view.addSubview(scrollView)
    view.addConstraintsWithFormat("H:|[v0]|", views: scrollView)
    view.addConstraintsWithFormat("V:|[v0]|", views: scrollView)

    scrollView.addSubview(slogan)
    scrollView.addSubview(explainer)
    scrollView.addSubview(input)

    input.paypalEmail.field.delegate = self
    input.paypalEmail.field.addTarget(self, action: #selector(checkEmail), for: .editingChanged)

    scrollView.addConstraintsWithFormat("V:|[v0(100)]-2-[v1(196)]-6-[v2(140)]|", views: slogan, explainer, input)
    let width = Int(view.frame.width)
    scrollView.addConstraintsWithFormat("H:|[v0(\(width))]|", views: slogan)
    scrollView.addConstraintsWithFormat("H:|[v0]|", views: explainer)
    scrollView.addConstraintsWithFormat("H:|[v0]|", views: input)

    // Add keyboard notification
    NotificationCenter.default.addObserver(self, selector: #selector(EarningsViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(EarningsViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    let uid = UserDefaults.standard.string(forKey: "email")!
    User().getPaypal(uid) { dict in
      DispatchQueue.main.async {
        if let email = dict["payTo"] as? String {
          self.input.paypalEmail.field.placeholder = email
        }
        else {
          self.input.paypalEmail.field.placeholder = "Paypal Email"
        }
      }
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.contentOffset = scrollView.contentOffset
  }
}

extension EarningsViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
// IB actions
extension EarningsViewController {
  func checkEmail(){
    //Check for valid email address
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

    if (!emailTest.evaluate(with: input.paypalEmail.field.text!)) {
      input.updateButton.isEnabled = false
    }
    else {
      input.updateButton.isEnabled = true
    }
  }

  func updateButtonTapped(){
    let util = UIUtility()
    let uid = UserDefaults.standard.string(forKey: "email")!
    let email = input.paypalEmail.field.text!
    User().updatePaypal(uid, paypalEmail: email) { result in
      if (result.isEmpty) {
        DispatchQueue.main.async {
          util.displayAlertMessage("Thanks for updating your paypal email", title: "OK", sender: self)
        }
      }
      else {
        DispatchQueue.main.async {
          util.displayAlertMessage("An error occurs when updating your email. Please try later", title: "Alert", sender: self)
        }
      }
    }
  }
}
//Handle keybord functions
extension EarningsViewController {
  func keyboardWillShow(_ notification: Notification)
  {
    //Need to calculate keyboard exact size due to Apple suggestions
    scrollView.isScrollEnabled = true
    let info : NSDictionary = notification.userInfo! as NSDictionary
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    // We need to add 20 to count for the height of keyboard hint
    let keyboardHeight = keyboardSize!.height + 20

    var aRect : CGRect = scrollView.frame
    // Deduct the keyboard height to get visible frame height
    aRect.size.height = aRect.size.height - keyboardHeight
    let activeText = input.paypalEmail
      // pt is the lower left corner of the rectangular textfield or textview
    let pt = CGPoint(x: activeText.frame.origin.x, y: activeText.frame.origin.y + activeText.frame.size.height)
    let ptInScrollView = activeText.convert(pt, to: scrollView)

    if (!aRect.contains(ptInScrollView))
    {
      // Compute the exact offset we need to scroll the view up
      let offset = ptInScrollView.y - (aRect.origin.y + aRect.size.height)
      scrollView.setContentOffset(CGPoint(x: 0, y: self.contentOffset.y + offset + 40), animated: true)
    }
  }

  func keyboardWillHide(_ notification: Notification)
  {
    self.view.endEditing(true)
    scrollView.setContentOffset(CGPoint(x: 0, y: self.contentOffset.y), animated: true)
  }

}
private class PaypalEmail: UIView {
  let field: UITextField = {
    let email  = UITextField()
    email.keyboardType = .emailAddress
    email.autocapitalizationType = .none
    email.autocorrectionType = .no
    email.returnKeyType = .done
    return email
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    addSubview(field)
    addConstraintsWithFormat("V:|-6-[v0]-6-|", views: field)
    addConstraintsWithFormat("H:|-12-[v0]|", views: field)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
private class EarningsView: UIView {
  let title: UILabel = {
    let title = UILabel()
    title.text = "Total Earnings"
    title.textAlignment = .center
    title.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
    title.textColor = UIColor(white: 0, alpha: 0.7)
    return title
  }()

  let amount: UILabel = {
    let amount = UILabel()
    amount.textColor = UIColor(white: 0, alpha: 0.7)
    amount.font = UIFont.boldSystemFont(ofSize: 20)
    amount.textAlignment = .center
    return amount
  }()

  let paypalEmail: PaypalEmail = {
    let email = PaypalEmail()
    email.layer.cornerRadius = 4
    email.clipsToBounds = true
    email.layer.borderWidth = 1
    email.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1.0).cgColor
    return email
  }()

  lazy var updateButton: CustomButton = {
    let button = CustomButton()
    button.layer.cornerRadius = 4
    button.clipsToBounds = true
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.setTitle("Update", for: UIControlState())
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.isEnabled = false
    return button
  }()

  let note: UILabel = {
    let note = UILabel()
    note.textColor = UIColor(red: 111/255, green: 111/255, blue: 111/255, alpha: 0.7)
    note.font = UIFont.systemFont(ofSize: 11)
    note.text = "Your earnings will be transferred to your Paypal account on 1st of each month with a minimum threshold of $10."
    note.numberOfLines = 3
    return note
  }()

  func setAmount(_ earnings: Double) {
    amount.text = "$\(earnings)"
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    addSubview(title)
    addSubview(amount)
    addSubview(paypalEmail)
    addSubview(updateButton)
    addSubview(note)

    addConstraintsWithFormat("V:|-9-[v0(20)]-4-[v1(23)]-9-[v2(30)]-6-[v3(30)]", views: title, amount, paypalEmail, note)
    addConstraintsWithFormat("V:|-9-[v0(20)]-4-[v1(23)]-9-[v2(30)]-6-[v3(30)]", views: title, amount, updateButton, note)
    paypalEmail.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11).isActive = true
    updateButton.leadingAnchor.constraint(equalTo: paypalEmail.trailingAnchor, constant: 9).isActive = true
    updateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11).isActive = true
    updateButton.widthAnchor.constraint(equalTo: paypalEmail.widthAnchor, multiplier: 0.4).isActive = true

    addConstraintsWithFormat("H:|-11-[v0]-11-|", views: note)
    title.widthAnchor.constraint(equalToConstant: 200).isActive = true
    title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    amount.widthAnchor.constraint(equalTo: title.widthAnchor).isActive = true
    amount.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
