//
//  WelcomeViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/19/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

  let titles = ["Obtain\nExpert\nInsights", "Monetize\nYour\nExpertise", "'Snoop'\nInteresting\nAnswers"]
  let summaries = ["Ask your question to a designated expert\nReceive insights via video response\nBoth of you will be rewarded if someone 'snoops' the answer", "Set your price for answering a question\nIf someone requests an answer from you\nYou have 48 hours to repond", "Pay $1.5 to 'snoop' any question\nFor a small amout\nYou get domain expertise"]

  let cellId = "welcomeCell"

  lazy var introduction: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    layout.scrollDirection = .horizontal
    let introduction = UICollectionView(frame: .zero, collectionViewLayout: layout)
    introduction.dataSource = self
    introduction.delegate = self
    introduction.translatesAutoresizingMaskIntoConstraints = false
    introduction.backgroundColor = UIColor.clear
    introduction.register(WelcomeCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    introduction.showsHorizontalScrollIndicator = false
    return introduction
  }()

  lazy var pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.numberOfPages = self.titles.count
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = UIColor.lightGray
    pageControl.currentPageIndicatorTintColor = UIColor.defaultColor()
    pageControl.translatesAutoresizingMaskIntoConstraints = false

    pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
    return pageControl
  }()

  lazy var signupbutton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.backgroundColor = UIColor.defaultColor()
    button.setTitle("Sign Up", for: UIControlState())
    button.setTitleColor(UIColor.white, for: UIControlState())

    button.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var loginButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.defaultColor().cgColor
    button.setTitle("Log In", for: UIControlState())
    button.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    button.backgroundColor = UIColor.white

    button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient")!)
    view.addSubview(introduction)
    view.addSubview(pageControl)
    view.addSubview(signupbutton)
    view.addSubview(loginButton)

    // Setup constraints for introduction view
    introduction.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    introduction.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    introduction.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    introduction.heightAnchor.constraint(equalToConstant: 215).isActive = true

    // Setup PageControl constraints
    pageControl.widthAnchor.constraint(equalToConstant: 120).isActive = true
    pageControl.heightAnchor.constraint(equalToConstant: 10).isActive = true
    pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130).isActive = true

    // Setup button
    signupbutton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
    signupbutton.heightAnchor.constraint(equalToConstant: 47).isActive = true
    signupbutton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -12).isActive = true
    signupbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45).isActive = true
    loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
    loginButton.heightAnchor.constraint(equalTo: signupbutton.heightAnchor).isActive = true
    loginButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 12).isActive = true
    loginButton.bottomAnchor.constraint(equalTo: signupbutton.bottomAnchor).isActive = true

  }
}

// Extension for IB related actions
extension WelcomeViewController {
  func pageControlTapped() {
    let currentPage = self.pageControl.currentPage
    let indexPath = IndexPath(row: currentPage, section: 0)
    self.introduction.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  func signupButtonTapped() {
    let vc = SignupViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  func loginButtonTapped(){
    let vc = LoginViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension WelcomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return titles.count
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 215)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! WelcomeCollectionViewCell
    cell.title.text = titles[indexPath.row]
    cell.summary.text = summaries[indexPath.row]
    return cell
  }
}

extension WelcomeViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = introduction.frame.size.width
    let halfPageSize = pageWidth / 2
    pageControl.currentPage = Int((introduction.contentOffset.x + halfPageSize) / pageWidth)
    // Add scroll to position action
    let indexPath = IndexPath(row: pageControl.currentPage, section: 0)
    self.introduction.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }
}


