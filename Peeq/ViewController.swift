//
//  ViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/10/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
    if (!isUserLoggedIn){
      self.performSegueWithIdentifier("loginView", sender: self)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let nav = self.navigationController?.navigationBar
    nav?.barTintColor = UIColor(red: 255/255, green: 153.0/255.0, blue: 51.0/255.0, alpha: 1.0)
    nav?.tintColor = UIColor.whiteColor()
    
  }
  
  
  @IBAction func logoutButtonTapped(sender: AnyObject) {
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
    NSUserDefaults.standardUserDefaults().removeObjectForKey("email")
    NSUserDefaults.standardUserDefaults().synchronize()
    self.performSegueWithIdentifier("loginView", sender: self)
  }
}

