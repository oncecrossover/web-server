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

  @IBOutlet weak var scrollView: UIScrollView!

  var contentOffset: CGPoint = CGPointZero
  var placeholder: String = "You will be refunded if your question is not replied within 48 hours. You will be rewarded if others pay to snoop your question."

  var questionModule = Question()
  var utility = UIUtility()
  var generics = Generics()
  let placeholderColor = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 0.85)

  lazy var profileView: ProfileView = {
    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 220)
    let view = ProfileView(frame: frame, uid: self.profileInfo.uid)
    return view
  }()

  lazy var askView: UIView = {
    let askView = UIView()
    askView.translatesAutoresizingMaskIntoConstraints = false
    askView.backgroundColor = UIColor.whiteColor()
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
    textView.font = UIFont.systemFontOfSize(14)
    textView.layer.cornerRadius = 4
    textView.clipsToBounds = true
    return textView
  }()

  lazy var askButton: UIButton = {
    let askButton = CustomButton()
    askButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    askButton.enabled = true
    askButton.layer.cornerRadius = 5
    askButton.clipsToBounds = true
    askButton.addTarget(self, action: #selector(askButtonTapped), forControlEvents: .TouchUpInside)
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
    view.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), forControlEvents: .TouchUpInside)
    view.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), forControlEvents: .TouchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
}

//override
extension AskViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    initView()
  }

  func initView() {
    scrollView.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 0.2)
    scrollView.addSubview(profileView)
    scrollView.addSubview(askView)

    let width = self.view.frame.width
    scrollView.addConstraintsWithFormat("H:|[v0(\(width))]|", views: askView)
    profileView.topAnchor.constraintEqualToAnchor(scrollView.topAnchor).active = true
    askView.topAnchor.constraintEqualToAnchor(profileView.bottomAnchor, constant: 10).active = true
    askView.heightAnchor.constraintEqualToAnchor(view.heightAnchor, constant: -220).active = true
    askView.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor).active = true

    if let avatarUrl = profileInfo.avatarUrl {
      self.profileView.profileImage.sd_setImageWithURL(NSURL(string: avatarUrl))
    }
    else {
      self.profileView.profileImage.image = UIImage(named: "default")
    }

    self.profileView.title.text = profileInfo.title
    self.profileView.name.text = profileInfo.name
    self.profileView.about.text = profileInfo.about

    if (profileInfo.rate == 0) {
      self.askButton.setTitle("Free to ask", forState: .Normal)
    }
    else {
      self.askButton.setTitle("$ \(profileInfo.rate) to ask", forState: .Normal)
    }
  }
}

// UITextViewDelegate
extension AskViewController: UITextViewDelegate {

  func textViewDidBeginEditing(textView: UITextView) {
    if (textView.textColor == placeholderColor) {
      textView.text = ""
      textView.textColor = UIColor.blackColor()
    }

    self.scrollView.scrollEnabled = true
    self.contentOffset = self.scrollView.contentOffset
    self.scrollView.setContentOffset(CGPointMake(0, self.contentOffset.y + 120), animated: true)
  }

  func textViewDidEndEditing(textView: UITextView) {
    if (textView.text.isEmpty) {
      textView.text = placeholder
      textView.textColor = placeholderColor
    }
    
    self.scrollView.setContentOffset(self.contentOffset, animated: true)
  }

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
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

    if let window = UIApplication.sharedApplication().keyWindow {
      window.addSubview(blackView)
      blackView.frame = window.frame
      window.addSubview(payWithCoinsView)
      payWithCoinsView.setCount(25 * profileInfo.rate)
      payWithCoinsView.setConfirmMessage("Confirm to Ask?")
      payWithCoinsView.centerXAnchor.constraintEqualToAnchor(window.centerXAnchor).active = true
      payWithCoinsView.centerYAnchor.constraintEqualToAnchor(window.centerYAnchor).active = true
      payWithCoinsView.widthAnchor.constraintEqualToConstant(260).active = true
      payWithCoinsView.heightAnchor.constraintEqualToConstant(176).active = true
      blackView.alpha = 0
      payWithCoinsView.alpha = 0
      UIView.animateWithDuration(0.5) {
        self.blackView.alpha = 1
        self.payWithCoinsView.alpha = 1
      }
    }
  }

  func confirmButtonTapped() {
    UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
    }) { (result) in
      let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
      let quandaData = ["question" : self.questionView.text!, "responder" : self.profileInfo.uid]
      let jsonData:[String: AnyObject] = ["uid": uid, "type" : "ASKED", "quanda" : quandaData]
      self.generics.createObject(self.generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
        if (!result.isEmpty) {
          dispatch_async(dispatch_get_main_queue()) {
            self.utility.displayAlertMessage("there is an error processing your payment. Please try later", title: "Error", sender: self)
          }
        }
      }
    }
  }

  func cancelButtonTapped() {
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
      }, completion: nil)
  }
}
