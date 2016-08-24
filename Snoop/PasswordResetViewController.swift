//
//  SendEmailViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/24/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController{

  @IBOutlet weak var email: UITextField!
  @IBOutlet weak var tmpPassword: UITextField!
  @IBOutlet weak var newPassword: UITextField!

  var utility = UIUtility()
  var userModule = User()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }
  @IBAction func saveButtonTapped(sender: AnyObject) {
  }

  @IBAction func sendEmailButtonTapped(sender: AnyObject) {
    let userEmail = email.text!
    if (userEmail.isEmpty) {
      utility.displayAlertMessage("Email field cannot be empty", title: "Alert", sender: self)
      return
    }

    //Check for valid email address
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

    if (!emailTest.evaluateWithObject(userEmail)) {
      utility.displayAlertMessage("Email address invalid", title: "Alert", sender: self)
      return
    }

  }
}
