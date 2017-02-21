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
    layout.scrollDirection = .Horizontal
    let introduction = UICollectionView(frame: .zero, collectionViewLayout: layout)
    introduction.dataSource = self
    introduction.delegate = self
    introduction.translatesAutoresizingMaskIntoConstraints = false
    introduction.backgroundColor = UIColor.clearColor()
    introduction.registerClass(WelcomeCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    return introduction
  }()

  lazy var pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.numberOfPages = self.titles.count
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
    pageControl.currentPageIndicatorTintColor = UIColor.defaultColor()
    pageControl.translatesAutoresizingMaskIntoConstraints = false

    pageControl.addTarget(self, action: #selector(pageControlTapped), forControlEvents: .ValueChanged)
    return pageControl
  }()

  lazy var signupbutton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.backgroundColor = UIColor.defaultColor()
    button.setTitle("Sign Up", forState: .Normal)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)

    button.addTarget(self, action: #selector(signupButtonTapped), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var loginButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.defaultColor().CGColor
    button.setTitle("Log In", forState: .Normal)
    button.setTitleColor(UIColor.defaultColor(), forState: .Normal)
    button.backgroundColor = UIColor.whiteColor()

    button.addTarget(self, action: #selector(loginButtonTapped), forControlEvents: .TouchUpInside)
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
    introduction.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    introduction.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
    introduction.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
    introduction.heightAnchor.constraintEqualToConstant(215).active = true

    // Setup PageControl constraints
    pageControl.widthAnchor.constraintEqualToConstant(60).active = true
    pageControl.heightAnchor.constraintEqualToConstant(10).active = true
    pageControl.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    pageControl.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -130).active = true

    // Setup button
    signupbutton.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 25).active = true
    signupbutton.heightAnchor.constraintEqualToConstant(47).active = true
    signupbutton.trailingAnchor.constraintEqualToAnchor(view.centerXAnchor, constant: -12).active = true
    signupbutton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -45).active = true
    loginButton.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -25).active = true
    loginButton.heightAnchor.constraintEqualToAnchor(signupbutton.heightAnchor).active = true
    loginButton.leadingAnchor.constraintEqualToAnchor(view.centerXAnchor, constant: 12).active = true
    loginButton.bottomAnchor.constraintEqualToAnchor(signupbutton.bottomAnchor).active = true

  }
}

// Extension for IB related actions
extension WelcomeViewController {
  func pageControlTapped() {
    let currentPage = self.pageControl.currentPage
    let indexPath = NSIndexPath(forRow: currentPage, inSection: 0)
    self.introduction.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
  }

  func signupButtonTapped() {
    let vc = SignupViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  func loginButtonTapped(){
    let vc = NewLoginViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension WelcomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return titles.count
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(view.frame.width, 215)
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellId, forIndexPath: indexPath) as! WelcomeCollectionViewCell
    cell.title.text = titles[indexPath.row]
    cell.summary.text = summaries[indexPath.row]
    return cell
  }
}

extension WelcomeViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    let pageWidth = introduction.frame.size.width
    pageControl.currentPage = Int(introduction.contentOffset.x / pageWidth)
  }
}


