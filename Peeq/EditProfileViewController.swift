//
//  EditProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {


  @IBOutlet weak var profilePhoto: UIImageView!

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var titleField: UITextField!
  @IBOutlet weak var aboutField: UITextView!
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var uploadButton: UIButton!

  var profileValues: (name: String!, title: String!, about: String!, avatarImage:  UIImage!)

  var userModule = User()
  var utility = UIUtility()

  var contentOffset: CGPoint = CGPointZero
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // fill in values for all the editable fields
    titleField.text = profileValues.title
    nameField.text = profileValues.name
    aboutField.text = profileValues.about

    if (profileValues.avatarImage != nil) {
      profilePhoto.image = profileValues.avatarImage
    }

    self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: "dismissKeyboard:"))
  }

  func textViewDidBeginEditing(textView: UITextView) {
    self.scrollView.scrollEnabled = true
    self.contentOffset = self.scrollView.contentOffset
    self.scrollView.setContentOffset(CGPointMake(0, self.contentOffset.y + 200), animated: true)
  }

  func textViewDidEndEditing(textView: UITextView) {
    self.scrollView.setContentOffset(self.contentOffset, animated: true)
  }

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    self.view.endEditing(true)
    self.view.endEditing(true)
  }

  @IBAction func saveButtonTapped(sender: AnyObject) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    dismissKeyboard()
    userModule.updateProfile(uid!, name: nameField.text!, title: titleField.text!, about: aboutField.text){ resultString in
      var message = "Your profile is successfully updated!"
      if (!resultString.isEmpty) {
        message = resultString
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.utility.displayAlertMessage(message, title: "OK", sender: self)
      }
    }
  }

  @IBAction func uploadButtonTapped(sender: AnyObject) {
    let myPickerController = UIImagePickerController()
    myPickerController.delegate = self
    myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    self.presentViewController(myPickerController, animated:  true, completion: nil)
  }

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    profilePhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    profilePhoto.backgroundColor = UIColor.clearColor()
    self.dismissViewControllerAnimated(true, completion: nil)
    uploadImage()
  }

  func uploadImage() {
    let photoData = UIImageJPEGRepresentation(profilePhoto.image!, 1)
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    userModule.updateProfilePhoto(uid, imageData: photoData){ resultString in
      var message = ""
      var title = "Alert"
      if (resultString.isEmpty) {
        message = "Profile photo updated Successfully!"
        title = "Success!"
      }
      else {
        message = resultString
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.utility.displayAlertMessage(message, title: title, sender: self)
      }
    }
  }

  func dismissKeyboard(sender:UIGestureRecognizer) {
    dismissKeyboard()
  }

  func dismissKeyboard() {
    nameField.resignFirstResponder()
    titleField.resignFirstResponder()
    aboutField.resignFirstResponder()
  }

}
