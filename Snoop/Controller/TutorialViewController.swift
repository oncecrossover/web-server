//
//  TutorialViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/8/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource {

  var email:String!
  var pageViewController: UIPageViewController!
  var pageImages = ["page1", "page2", "page3", "page4", "page5", "page6"]
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    setupNavbar()

    pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    pageViewController.dataSource = self
    let startVC = pageViewControllerAtIndex(0)
    let viewControllers:[UIViewController] = [startVC]
    pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)

    pageViewController.view.frame = CGRect(x: 25, y: 100, width: self.view.frame.width - 50, height: self.view.frame.height - 100)

    self.addChildViewController(pageViewController)
    self.view.addSubview(pageViewController.view)
    pageViewController.didMove(toParentViewController: self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let application = UIApplication.shared
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.registerForPushNotifications(application)
  }

  func setupNavbar() {
    // Creating right bar button
    let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0,
      width: UIScreen.main.bounds.size.width, height: 60));
    navbar.setBackgroundImage(UIImage(), for: .default)
    navbar.backgroundColor = UIColor.white
    navbar.titleTextAttributes = [ NSForegroundColorAttributeName:UIColor.black]
    self.view.addSubview(navbar)

    let navItem = UINavigationItem(title: "Tutorial")
    let skipButton = UIButton(type: .custom)
    skipButton.setTitle("Skip", for: UIControlState())
    skipButton.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
    skipButton.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
    let rightBarItem = UIBarButtonItem(customView: skipButton)
    navItem.rightBarButtonItem = rightBarItem

    navbar.items = [navItem]
  }

  func skipButtonTapped() {
    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
    UserDefaults.standard.set(email, forKey: "email")
    UserDefaults.standard.synchronize()
    if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") {
      let userModule = User()
      userModule.updateDeviceToken(email, token: deviceToken) { result in
        self.dismiss(animated: true, completion: nil)
      }
    }
    else {
      self.dismiss(animated: true, completion: nil)
    }

  }

  func pageViewControllerAtIndex(_ index: Int!) -> ContentViewController {
    if (pageImages.count == 0 || index >= pageImages.count) {
      return ContentViewController()
    }
    let vc = ContentViewController()
    vc.imageName = pageImages[index]
    vc.pageIndex = index
    return vc
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let vc = viewController as! ContentViewController
    var index = vc.pageIndex as Int

    if (index == 0 || index == NSNotFound) {
      return nil
    }

    index-=1

    return self.pageViewControllerAtIndex(index)
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let vc = viewController as! ContentViewController
    var index = vc.pageIndex as Int

    if (index == NSNotFound) {
      return nil
    }

    index+=1

    if (index == pageImages.count) {
      return nil
    }

    return self.pageViewControllerAtIndex(index)
  }

  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pageImages.count
  }

  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return 0
  }

}
