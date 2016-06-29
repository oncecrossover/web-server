//
//  EditProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {


  @IBOutlet weak var profilePhoto: UIImageView!

  @IBOutlet weak var titleField: UITextField!
  @IBOutlet weak var aboutField: UITextView!
  @IBOutlet weak var nameField: UITextField!

  var profileValues: (name: String!, title: String!, about: String!)

  var userModule = User()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    //Since our design shows a circular profile photo, we will make it circular
    profilePhoto.layer.cornerRadius = (profilePhoto.frame.size.width) / 2
    profilePhoto.clipsToBounds = true
    profilePhoto.layer.borderColor = UIColor.blackColor().CGColor
    profilePhoto.layer.borderWidth = 2

    // fill in values for all the editable fields
    titleField.text = profileValues.title
    nameField.text = profileValues.name
    aboutField.text = profileValues.about
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func saveButtonTapped(sender: AnyObject) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    userModule.updateProfile(uid!, name: nameField.text!, title: titleField.text!, about: aboutField.text){ resultString in
      if (resultString.isEmpty) {
        NSOperationQueue.mainQueue().addOperationWithBlock{
          self.performSegueWithIdentifier("segueToUpdatedProfile", sender: self)
        }
      }
      else {
        self.displayAlertMessage(resultString)
      }
    }
  }

  func displayAlertMessage(userMessage:String) {

    let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)

    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)

    myAlert.addAction(okAction)

    self.presentViewController(myAlert, animated: true, completion: nil)

  }
}
