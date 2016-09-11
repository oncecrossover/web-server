//
//  TutorialViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/8/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource {

  var pageViewController: UIPageViewController!
  var pageImages = ["page1", "page2", "page3", "page4", "page5", "page6"]
  override func viewDidLoad() {
    super.viewDidLoad()

    pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
    pageViewController.dataSource = self
    let startVC = pageViewControllerAtIndex(0)
    let viewControllers:[UIViewController] = [startVC]
    pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)

    pageViewController.view.frame = CGRectMake(0, 70, self.view.frame.width, self.view.frame.height - 100)

    self.addChildViewController(pageViewController)
    self.view.addSubview(pageViewController.view)
    pageViewController.didMoveToParentViewController(self)
  }

  @IBAction func skipButtonTapped(sender: AnyObject) {
    self.performSegueWithIdentifier("unwindToLogin", sender: self)
  }

  func pageViewControllerAtIndex(index: Int!) -> ContentViewController {
    if (pageImages.count == 0 || index >= pageImages.count) {
      return ContentViewController()
    }
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
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
