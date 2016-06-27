//
//  LoginViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/18/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  @IBOutlet weak var userEmailTextField: UITextField!
  @IBOutlet weak var userPasswordTextField: UITextField!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func LoginButtonTapped(sender: AnyObject) {
    let userEmail = userEmailTextField.text!
    let userPassword = userPasswordTextField.text!
    
    let userModule = User()
    userModule.getUser(userEmail, password: userPassword) { displayMessage in
      if (displayMessage.isEmpty) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().setObject(userEmail, forKey: "email")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      else {
        NSOperationQueue.mainQueue().addOperationWithBlock {
          self.displayAlertMessage(displayMessage)
        }
      }
    }
    
  }
  
  func displayAlertMessage(userMessage:String) {
    
    let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
    
    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
    
    myAlert.addAction(okAction)
    
    self.presentViewController(myAlert, animated: true, completion: nil)
    
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

}
