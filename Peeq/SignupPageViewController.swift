//
//  SignupPageViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/18/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class SignupPageViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userConfirmPasswordTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func JoinbuttonTapped(sender: AnyObject) {
        
        let userEmail = userEmailTextField.text!
        let userPassword = userPasswordTextField.text!
        let userConfirmPassword = userConfirmPasswordTextField.text!
        
        //check for empty field
        if (userEmail.isEmpty || userPassword.isEmpty || userConfirmPassword.isEmpty)
        {
           //Display alert message
            displayAlertMessage("all fields are required")
            return
        }
        
        //Check if password matches
        if (userPassword != userConfirmPassword)
        {
            //Display alert
            displayAlertMessage("passwords don't match")
            return
        }
        
        //Store data
        NSUserDefaults.standardUserDefaults().setObject(userEmail, forKey:"userEmail")
        NSUserDefaults.standardUserDefaults().setObject(userPassword, forKey:
        "userPassword")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        //Display success message
        let myAlert = UIAlertController(title: "Alert", message: "Registration is successful!", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    func displayAlertMessage(userMessage:String) {
        
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }

}
