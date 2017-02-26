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
    view.backgroundColor = UIColor.whiteColor()
    setupNavbar()

    pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    pageViewController.dataSource = self
    let startVC = pageViewControllerAtIndex(0)
    let viewControllers:[UIViewController] = [startVC]
    pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)

    pageViewController.view.frame = CGRectMake(25, 100, self.view.frame.width - 50, self.view.frame.height - 100)

    self.addChildViewController(pageViewController)
    self.view.addSubview(pageViewController.view)
    pageViewController.didMoveToParentViewController(self)
  }

  func setupNavbar() {
    // Creating right bar button
    let navbar = UINavigationBar(frame: CGRectMake(0, 0,
      UIScreen.mainScreen().bounds.size.width, 60));
    navbar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navbar.backgroundColor = UIColor.whiteColor()
    navbar.titleTextAttributes = [ NSForegroundColorAttributeName:UIColor.blackColor()]
    self.view.addSubview(navbar)

    let navItem = UINavigationItem(title: "Tutorial")
    let skipButton = UIButton(type: .Custom)
    skipButton.setTitle("Skip", forState: .Normal)
    skipButton.setTitleColor(UIColor.defaultColor(), forState: .Normal)
    skipButton.addTarget(self, action: #selector(skipButtonTapped), forControlEvents: .TouchUpInside)
    skipButton.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
    let rightBarItem = UIBarButtonItem(customView: skipButton)
    navItem.rightBarButtonItem = rightBarItem

    navbar.items = [navItem]
  }

  func skipButtonTapped() {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
    NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
    NSUserDefaults.standardUserDefaults().synchronize()
    if let deviceToken = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken") {
      let userModule = User()
      userModule.updateDeviceToken(email, token: deviceToken) { result in
        self.dismissViewControllerAnimated(true, completion: nil)
      }
    }
    else {
      self.dismissViewControllerAnimated(true, completion: nil)
    }

  }

  func pageViewControllerAtIndex(index: Int!) -> ContentViewController {
    if (pageImages.count == 0 || index >= pageImages.count) {
      return ContentViewController()
    }
    let vc = ContentViewController()
    vc.imageName = pageImages[index]
    vc.pageIndex = index
    return vc
  }

  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    let vc = viewController as! ContentViewController
    var index = vc.pageIndex as Int

    if (index == 0 || index == NSNotFound) {
      return nil
    }

    index-=1

    return self.pageViewControllerAtIndex(index)
  }

  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
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

  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return pageImages.count
  }

  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
  }

}
