//
//  EulaViewController.swift
//  Snoop
//
//  Created by Bingo Zhou on 9/20/17.
//  Copyright © 2017 Snoop Technologies Inc. All rights reserved.
//

import Foundation
class EulaViewController: UIViewController {
  var signupViewController: SignupViewController?
  var fileName : String? = "eula"
  var navigationTitle : String?

  let placeHolderLabel = UILabel()
  let webView: UIWebView = {
    let view = UIWebView()
    return view
  }()

  lazy var agreeButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.backgroundColor = UIColor.defaultColor()
    button.setTitle("Agree", for: UIControlState())
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)

    button.addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var disagreeButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.defaultColor().cgColor
    button.setTitle("Disagree", for: UIControlState())
    button.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    button.backgroundColor = UIColor.white
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)

    button.addTarget(self, action: #selector(disagreeButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white
    self.navigationController?.navigationItem.title = "License Agreement"

    view.addSubview(placeHolderLabel)
    view.addSubview(webView)
    view.addSubview(agreeButton)
    view.addSubview(disagreeButton)

    view.addConstraintsWithFormat("H:|[v0]|", views: webView)
    view.addConstraintsWithFormat("V:|[v0(25)]-[v1]-25-[v2]-25-|", views: placeHolderLabel, webView, agreeButton)
    webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: "html")!)))

    // Setup label
    placeHolderLabel.topAnchor.constraint(equalTo: view.topAnchor)
    placeHolderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    placeHolderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    placeHolderLabel.bottomAnchor.constraint(equalTo: webView.topAnchor)
    placeHolderLabel.heightAnchor.constraint(equalToConstant: 25)

    // Setup buttons
    agreeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
    agreeButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -12).isActive = true
    agreeButton.heightAnchor.constraint(equalToConstant: 47).isActive = true
    disagreeButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 12).isActive = true
    disagreeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
    disagreeButton.heightAnchor.constraint(equalTo: agreeButton.heightAnchor).isActive = true
    disagreeButton.bottomAnchor.constraint(equalTo: agreeButton.bottomAnchor).isActive = true
  }

  func disagreeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  func agreeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
    signupViewController?.doSignUp()
  }
}
