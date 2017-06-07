//
//  AskViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/30/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class AskViewController: UIViewController {

  var profileInfo:DiscoverModel!

  var fullScreenImageView : FullScreenImageView = FullScreenImageView()

  @IBOutlet weak var scrollView: UIScrollView!

  var contentOffset: CGPoint = CGPoint.zero
  var placeholder: String = "You will be refunded if your question is not replied within 48 hours. You will be rewarded if others pay to snoop your question."

  var coinModule = Coin()
  var utility = UIUtility()
  var generics = Generics()
  let placeholderColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 0.85)

  var coinCount = 0
  var notificationName = "coinsAdded"

  lazy var profileView: ProfileView = {
    let frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: 220)
    let view = ProfileView(frame: frame, uid: self.profileInfo.uid)
    return view
  }()

  lazy var askView: UIView = {
    let askView = UIView()
    askView.translatesAutoresizingMaskIntoConstraints = false
    askView.backgroundColor = UIColor.white
    askView.addSubview(self.questionView)
    askView.addSubview(self.askButton)

    askView.addConstraintsWithFormat("H:|-14-[v0]-14-|", views: self.questionView)
    askView.addConstraintsWithFormat("H:|-14-[v0]-14-|", views: self.askButton)
    askView.addConstraintsWithFormat("V:|-13-[v0(140)]-18-[v1(45)]", views: self.questionView, self.askButton)
    return askView
  }()

  lazy var questionView: UITextView = {
    let textView = UITextView()
    textView.delegate = self
    textView.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
    textView.textColor = self.placeholderColor
    textView.text = self.placeholder
    textView.font = UIFont.systemFont(ofSize: 14)
    textView.layer.cornerRadius = 4
    textView.clipsToBounds = true
    return textView
  }()

  lazy var askButton: UIButton = {
    let askButton = CustomButton()
    askButton.setTitleColor(UIColor.white, for: UIControlState())
    askButton.isEnabled = true
    askButton.layer.cornerRadius = 5
    askButton.clipsToBounds = true
    askButton.addTarget(self, action: #selector(askButtonTapped), for: .touchUpInside)
    return askButton
  }()

  lazy var blackView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.5)
    return view
  }()

  lazy var payWithCoinsView: PayWithCoinsView = {
    let view = PayWithCoinsView()
    view.layer.cornerRadius = 6
    view.clipsToBounds = true
    view.cancelButton.addTarget(self, action: #selector(cancelAskButtonTapped), for: .touchUpInside)
    view.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var buyCoinsView: BuyCoinsView = {
    let view = BuyCoinsView()
    view.layer.cornerRadius = 6
    view.clipsToBounds = true
    view.cancelButton.addTarget(self, action: #selector(cancelBuyButtonTapped), for: .touchUpInside)
    view.buyCoinsButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
}

//override
extension AskViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadCoinCount()
    initView()
  }

  func initView() {
    scrollView.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
    scrollView.addSubview(profileView)
    scrollView.addSubview(askView)

    let width = self.scrollView.frame.width

    scrollView.addConstraintsWithFormat("H:|[v0(\(width))]|", views: askView)
    profileView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    askView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 10).isActive = true
    askView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -220).isActive = true
    askView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

    if let avatarUrl = profileInfo.avatarUrl {
      self.profileView.profileImage.sd_setImage(with: URL(string: avatarUrl))
    }
    else {
      self.profileView.profileImage.image = UIImage(named: "default")
    }

    self.profileView.profileImage.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: fullScreenImageView, action: #selector(fullScreenImageView.imageTapped))
    self.profileView.profileImage.addGestureRecognizer(tap)

    self.profileView.title.text = profileInfo.title
    self.profileView.name.text = profileInfo.name
    self.profileView.about.text = profileInfo.about

    if (profileInfo.rate == 0) {
      self.askButton.setTitle("Free to ask", for: UIControlState())
    }
    else {
      self.askButton.setTitle("$ \(profileInfo.rate) to ask", for: UIControlState())
    }
  }

  func loadCoinCount() {
    coinModule.getCoinsCount() { result in
      let coinCount = result["amount"] as! Int
      self.coinCount = coinCount
    }
  }

}

// UITextViewDelegate
extension AskViewController: UITextViewDelegate {

  func textViewDidBeginEditing(_ textView: UITextView) {
    if (textView.textColor == placeholderColor) {
      textView.text = ""
      textView.textColor = UIColor.black
    }

    self.scrollView.isScrollEnabled = true
    self.contentOffset = self.scrollView.contentOffset
    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.contentOffset.y + 120), animated: true)
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if (textView.text.isEmpty) {
      textView.text = placeholder
      textView.textColor = placeholderColor
    }
    
    self.scrollView.setContentOffset(self.contentOffset, animated: true)
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
}

// Ib related actions
extension AskViewController {

  func askButtonTapped() {
    if (questionView.text! == placeholder) {
      utility.displayAlertMessage("questions cannot be empty", title: "Alert", sender: self)
      return
    }

    self.questionView.resignFirstResponder()

    if (profileInfo.rate == 0) {
      processTransaction()
    }
    else {
      if let window = UIApplication.shared.keyWindow {
        window.addSubview(blackView)
        blackView.frame = window.frame
        var frameToAdd: UIView!
        if (self.coinCount < profileInfo.rate * 25) {
          buyCoinsView.setNote("$\(profileInfo.rate) (\(profileInfo.rate * 25)) coins to ask a question")
          frameToAdd = buyCoinsView
        }
        else {
          payWithCoinsView.setConfirmMessage("Confirm to Ask?")
          payWithCoinsView.setCount(25 * profileInfo.rate)
          frameToAdd = payWithCoinsView
        }
        window.addSubview(frameToAdd)
        frameToAdd.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        frameToAdd.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        frameToAdd.widthAnchor.constraint(equalToConstant: 260).isActive = true
        frameToAdd.heightAnchor.constraint(equalToConstant: 176).isActive = true
        blackView.alpha = 0
        frameToAdd.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
          self.blackView.alpha = 1
          frameToAdd.alpha = 1
        })
      }
    }

  }

  func processTransaction() {
    let uid = UserDefaults.standard.integer(forKey: "uid")
    let quandaData = ["question" : self.questionView.text!, "responder" : self.profileInfo.uid] as [String : Any]
    let jsonData:[String: AnyObject] = ["uid": uid as AnyObject, "type" : "ASKED" as AnyObject, "quanda" : quandaData as AnyObject]
    self.scrollView.isUserInteractionEnabled = false
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Sending your question...")
    self.generics.createObject(self.generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
      if (!result.isEmpty) {
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
          self.utility.displayAlertMessage("there is an error processing your payment. Please try later", title: "Error", sender: self)
        }
      }
      else {
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
          self.questionView.textColor = self.placeholderColor
          self.questionView.text = self.placeholder
          self.displayConfirmation("Question Sent!")
          UserDefaults.standard.set(true, forKey: "shouldLoadQuestions")
          UserDefaults.standard.synchronize()
          let amount = self.profileInfo.rate * 25
          NotificationCenter.default.post(name: Notification.Name(rawValue: self.notificationName), object: nil, userInfo: ["uid": uid, "amount" : -amount])
        }
      }
      self.scrollView.isUserInteractionEnabled = true
    }
  }

  func confirmButtonTapped() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
    }) { (result) in
      self.processTransaction()
    }
  }

  func buyButtonTapped() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.buyCoinsView.alpha = 0
    }) { (result) in
      DispatchQueue.main.async {
        let vc = CoinsViewController()
        vc.numOfCoins = self.coinCount
        self.present(vc, animated: true, completion: nil)
      }
    }
  }

  func cancelAskButtonTapped() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
      }, completion: nil)
  }

  func cancelBuyButtonTapped() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.buyCoinsView.alpha = 0
      }, completion: nil)
  }
}
