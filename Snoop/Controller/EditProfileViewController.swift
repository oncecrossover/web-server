//
//  EditProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

  var profileView: EditProfileView!

  lazy var submitButton: UIButton = {
    let button = CustomButton()
    button.enabled = true
    if (self.isEditingProfile) {
      button.setTitle("Save", forState: .Normal)
    }
    else {
      button.setTitle("Apply", forState: .Normal)
    }

    button.addTarget(self, action: #selector(submitButtonTapped), forControlEvents: .TouchUpInside)
    return button
  }()

  var labelColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)

  var profileValues: (name: String!, title: String!, about: String!, avatarImage:  UIImage!, rate: Double!)

  lazy var userModule = User()
  lazy var utility = UIUtility()
  lazy var category = Category()

  var contentOffset: CGPoint = CGPointZero

  var activeText: UIView?

  var isProfileUpdated = false
  var isEditingProfile = false
  var isSnooper = false

  let placeHolder = "Add a short description of your expertise and your interests"

  var nameExceeded = false
  var titleExceeded = false
  var aboutExceeded = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    initView()

    let name = profileValues.name.characters.split{$0 == " "}.map(String.init)
    profileView.fillValues(profileValues.avatarImage, firstName: name[0], lastName: name[1], title: profileValues.title, about: profileValues.about)
    profileView.fillRate(profileValues.rate)

    setupInputLimits()

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

    navigationController?.delegate = self
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.contentOffset = profileView.contentOffset
  }
}

// Helper in init view
extension EditProfileViewController {
  func initView() {
    let frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 100)
    if (self.isEditingProfile && !isSnooper) {
      profileView = EditProfileView(frame: frame, includeExpertise: false)
    }
    else {
      profileView = EditProfileView(frame: frame, includeExpertise: true)
    }

    self.view.addSubview(profileView)
    self.view.addSubview(submitButton)

    // Setup constraints
    self.view.addConstraintsWithFormat("H:|[v0]|", views: submitButton)
    submitButton.topAnchor.constraintEqualToAnchor(profileView.bottomAnchor).active = true
    if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
      submitButton.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor, constant: -tabBarHeight).active = true
    }
    else {
      submitButton.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor, constant: -49).active = true
    }

    profileView.about.value.delegate = self

    profileView.changeButton.addTarget(self, action: #selector(uploadButtonTapped), forControlEvents: .TouchUpInside)
  }

  func setupInputLimits() {
    profileView.firstName.value.addTarget(self, action: #selector(handleFirstNameLimit(_:)), forControlEvents: .EditingChanged)
    profileView.lastName.value.addTarget(self, action: #selector(handleLastNameLimit(_:)), forControlEvents: .EditingChanged)
    profileView.title.value.addTarget(self, action: #selector(handleTitleLimit(_:)), forControlEvents: .EditingChanged)
  }
}

// Helper functions
extension EditProfileViewController {
  func handleFirstNameLimit(sender: UITextField) {
    profileView.firstName.limit.hidden = false
    let remainder = 20 - sender.text!.characters.count
    profileView.firstName.limit.text = remainder < 0 ? "-" : "\(remainder)"
    profileView.firstName.limit.textColor = remainder < 0 ? UIColor.redColor() : UIColor.defaultColor()
    nameExceeded = remainder < 0
    submitButton.enabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  func handleLastNameLimit(sender: UITextField) {
    profileView.lastName.limit.hidden = false
    let remainder = 20 - sender.text!.characters.count
    profileView.lastName.limit.text = remainder < 0 ? "-" : "\(remainder)"
    profileView.lastName.limit.textColor = remainder < 0 ? UIColor.redColor() : UIColor.defaultColor()
    nameExceeded = remainder < 0
    submitButton.enabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  func handleTitleLimit(sender: UITextField) {
    profileView.title.limit.hidden = false
    let remainder = 30 - sender.text!.characters.count
    profileView.title.limit.text = remainder < 0 ? "-" : "\(remainder)"
    profileView.title.limit.textColor = remainder < 0 ? UIColor.redColor() : UIColor.defaultColor()
    titleExceeded = remainder < 0
    submitButton.enabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  func keyboardWillShow(notification: NSNotification)
  {
    //Need to calculate keyboard exact size due to Apple suggestions
    profileView.scrollEnabled = true
    let info : NSDictionary = notification.userInfo!
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
    // We need to add 20 to count for the height of keyboard hint
    let keyboardHeight = keyboardSize!.height + 20

    var aRect : CGRect = profileView.frame
    // We need to add 100 to count for the height of submitbutton and tabbar
    aRect.size.height = aRect.size.height + 100 - keyboardHeight
    if let _ = activeText
    {
      // pt is the lower left corner of the rectangular textfield or textview
      let pt = CGPointMake(activeText!.frame.origin.x, activeText!.frame.origin.y + activeText!.frame.size.height)
      let ptInProfileView = activeText?.convertPoint(pt, toView: profileView)

      if (!CGRectContainsPoint(aRect, ptInProfileView!))
      {
        // Compute the exact offset we need to scroll the view up
        let offset = ptInProfileView!.y - (aRect.origin.y + aRect.size.height)
        profileView.setContentOffset(CGPointMake(0, self.contentOffset.y + offset + 40), animated: true)
      }
    }
  }

  func keyboardWillHide(notification: NSNotification)
  {
    profileView.firstName.limit.hidden = true
    profileView.lastName.limit.hidden = true
    profileView.title.limit.hidden = true
    self.view.endEditing(true)
    profileView.setContentOffset(CGPointMake(0, self.contentOffset.y), animated: true)
  }

  func dismissKeyboard() {
    profileView.firstName.value.resignFirstResponder()
    profileView.lastName.value.resignFirstResponder()
    profileView.title.value.resignFirstResponder()
    profileView.about.value.resignFirstResponder()
    profileView.rate.value.resignFirstResponder()
  }
}

extension EditProfileViewController: UITextViewDelegate {
  func textViewDidChange(textView: UITextView) {
    profileView.about.limit.hidden = false
    let remainder = 80 - textView.text!.characters.count
    profileView.about.limit.text = remainder < 0 ? "-" : "\(remainder)"
    profileView.about.limit.textColor = remainder < 0 ? UIColor.redColor() : UIColor.defaultColor()
    aboutExceeded = remainder < 0
    submitButton.enabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  func textViewDidBeginEditing(textView: UITextView) {
    if (profileView.about.value.textColor == labelColor) {
      profileView.about.value.text = ""
      profileView.about.value.textColor = UIColor.blackColor()
    }
  }

  func textViewDidEndEditing(textView: UITextView) {
    if (profileView.about.value.text.isEmpty) {
      profileView.about.value.text = placeHolder
      profileView.about.value.textColor = labelColor
    }

    activeText = nil
    profileView.about.limit.hidden = true
  }

  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    activeText = profileView.about.value
    return true
  }

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
}

// IB related actions
extension EditProfileViewController {

  func submitButtonTapped() {
    dismissKeyboard()
    //First start the activity indicator
    var text = "Updating Profile..."
    if (isEditingProfile == false) {
      text = "Thank you for your appplication..."
      if (profileView.title.value.text!.isEmpty || profileView.about.value.text!.isEmpty || profileView.about.value.text! == placeHolder) {
        utility.displayAlertMessage("please include your title and a short description of yourself", title: "Missing Info", sender: self)
        return
      }

      if (profileView.expertise.selectedCategories.count == 0) {
        utility.displayAlertMessage("Please include at least one of your expertise", title: "Missing I nfo", sender: self)
        return
      }
    }

    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: text)
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    var newRate = 0.0
    if (!profileView.rate.value.text!.isEmpty) {
      newRate = Double(profileView.rate.value.text!)!
    }

    if (newRate < 0.0) {
      // In real app, this should never happen since we don't provide keyboard that can input negative
      self.utility.displayAlertMessage("Your rate cannot be negative", title: "Alert", sender: self)
      return
    }

    let fullName = profileView.firstName.value.text! + " " + profileView.lastName.value.text!
    userModule.updateProfile(uid, name: fullName, title: profileView.title.value.text!, about: profileView.about.value.text!,
      rate: newRate){ resultString in
      var message = "Your profile is successfully updated!"
      if (!resultString.isEmpty) {
        message = resultString
        dispatch_async(dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.utility.displayAlertMessage(message, title: "Alert", sender: self)
        }
      }
      else {
        if (self.isEditingProfile == false || self.isSnooper) {
          // Update a user's expertise areas
          self.category.updateInterests(uid, interests: self.profileView.expertise.populateCategoriesToUpdate()) { result in
            if (!result.isEmpty) {
              dispatch_async(dispatch_get_main_queue()) {
                activityIndicator.hideAnimated(true)
                self.utility.displayAlertMessage("An error occurs. Please apply later", title: "Alert", sender: self)
              }
            }
            else {
              if (self.isEditingProfile == false) {
                // The users are applying to be a snooper
                self.userModule.applyToTakeQuestion(uid) { result in
                  if (!result.isEmpty) {
                    dispatch_async(dispatch_get_main_queue()) {
                      activityIndicator.hideAnimated(true)
                      self.utility.displayAlertMessage("An error occurs. Please apply later", title: "Alert", sender: self)
                    }
                  }
                  else {
                    // application successfully submitted
                    dispatch_async(dispatch_get_main_queue()) {
                      self.isProfileUpdated = true
                      activityIndicator.hideAnimated(true)
                      self.navigationController?.popViewControllerAnimated(true)
                    }
                  }
                }
              }
              else {
                dispatch_async(dispatch_get_main_queue()) {
                  self.isProfileUpdated = true
                  activityIndicator.hideAnimated(true)
                  self.navigationController?.popViewControllerAnimated(true)
                }
              }

            }
          }
        }
        else {
          // We use the delay so users can always see the activity indicator showing profile is being updated
          let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
          dispatch_after(time, dispatch_get_main_queue()) {
            self.isProfileUpdated = true
            activityIndicator.hideAnimated(true)
            self.navigationController?.popViewControllerAnimated(true)
          }
        }
      }
    }
  }

  func uploadButtonTapped() {
    let myPickerController = UIImagePickerController()
    myPickerController.delegate = self
    myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    self.presentViewController(myPickerController, animated:  true, completion: nil)
  }
}

// UIImagePickerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    profileView.profilePhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    self.dismissViewControllerAnimated(true, completion: nil)
    uploadImage()
  }

  func uploadImage() {
    //Start activity Indicator
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Uploading Your Photo...")
    var compressionRatio = 1.0
    let photoSize = UIImageJPEGRepresentation(profileView.profilePhoto.image!, 1)
    if (photoSize?.length > 1000000) {
      compressionRatio = 0.005
    }
    else if (photoSize?.length > 500000) {
      compressionRatio = 0.01
    }
    else if (photoSize?.length > 100000){
      compressionRatio = 0.05
    }
    else if (photoSize?.length > 10000) {
      compressionRatio = 0.2
    }
    let photoData = UIImageJPEGRepresentation(profileView.profilePhoto.image!, CGFloat(compressionRatio))
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    userModule.updateProfilePhoto(uid, imageData: photoData){ resultString in
      var message = ""
      if (resultString.isEmpty) {
        dispatch_async(dispatch_get_main_queue()) {
          self.isProfileUpdated = true
          activityIndicator.hideAnimated(true)
          self.navigationController?.popViewControllerAnimated(true)
        }
      }
      else {
        message = resultString
        dispatch_async(dispatch_get_main_queue()) {
          activityIndicator.hideAnimated(true)
          self.utility.displayAlertMessage(message, title: "Alert", sender: self)
        }
      }
    }
  }
}

// UINavigationControllerDelegate
extension EditProfileViewController: UINavigationControllerDelegate {
  func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? ProfileViewController {
      if (isProfileUpdated) {
        controller.initView()
      }
    }
  }

}
