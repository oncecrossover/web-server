//
//  EditProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {


  @IBOutlet weak var profilePhoto: UIImageView!

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var titleField: UITextField!
  @IBOutlet weak var aboutField: UITextView!
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var uploadButton: UIButton!
  @IBOutlet weak var rateField: UITextField!

  @IBOutlet weak var firstUnderline: UIView!
  @IBOutlet weak var secondUnderline: UIView!
  @IBOutlet weak var thirdUnderline: UIView!
  @IBOutlet weak var fourthUnderline: UIView!
  @IBOutlet weak var submitButton: UIButton!

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var rateLabel: UILabel!
  @IBOutlet weak var answerQuestionLabel: UILabel!

  @IBOutlet weak var aboutCount: UILabel!
  @IBOutlet weak var nameCount: UILabel!
  @IBOutlet weak var titleCount: UILabel!

  var textColor = UIColor.blackColor()
  var labelColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)

  var profileValues: (name: String!, title: String!, about: String!, avatarImage:  UIImage!, rate: Double!)

  var userModule = User()
  var utility = UIUtility()

  var contentOffset: CGPoint = CGPointZero

  var activeText: UIView?

  var isProfileUpdated = false
  var isEditingProfile = false

  let placeHolder = "Add a short description of your expertise and your interests"

  var nameExceeded = false
  var titleExceeded = false
  var aboutExceeded = false
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initView()

    setupInputLimits()

    if (profileValues.avatarImage != nil) {
      profilePhoto.image = profileValues.avatarImage
    }

    if (isEditingProfile) {
      submitButton.setTitle("Save", forState: .Normal)
    }
    else {
      submitButton.setTitle("Apply", forState: .Normal)
    }

    submitButton.enabled = true

    self.contentOffset = self.scrollView.contentOffset
    self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(EditProfileViewController.dismissKeyboard(_:))))

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

    navigationController?.delegate = self
  }

  func setupInputLimits() {
    nameField.addTarget(self, action: #selector(handleNameLimit(_:)), forControlEvents: .EditingChanged)
    titleField.addTarget(self, action: #selector(handleTitleLimit(_:)), forControlEvents: .EditingChanged)
  }

  func initView() {
    // fill in values for all the editable fields
    titleField.text = profileValues.title
    titleField.textColor = textColor
    titleCount.hidden = true

    nameField.text = profileValues.name
    nameField.textColor = textColor
    nameCount.hidden = true

    if (profileValues.about.isEmpty) {
      aboutField.text = placeHolder
      aboutField.textColor = labelColor
    }
    else {
      aboutField.text = profileValues.about
      aboutField.textColor = textColor
    }

    aboutCount.hidden = true

    rateField.text = String(profileValues.rate)
    rateField.textColor = textColor

    nameLabel.textColor = labelColor
    titleLabel.textColor = labelColor
    rateLabel.textColor = labelColor
    answerQuestionLabel.textColor = labelColor

    firstUnderline.backgroundColor = labelColor
    secondUnderline.backgroundColor = labelColor
    thirdUnderline.backgroundColor = labelColor
    fourthUnderline.backgroundColor = labelColor
  }

  func textViewDidChange(textView: UITextView) {
    aboutCount.hidden = false
    let remainder = 80 - textView.text!.characters.count
    aboutCount.text = remainder < 0 ? "-" : "\(remainder)"
    aboutCount.textColor = remainder < 0 ? UIColor.redColor() : UIColor.defaultColor()
    aboutExceeded = remainder < 0
    submitButton.enabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  func handleNameLimit(sender: UITextField) {
    nameCount.hidden = false
    let remainder = 20 - sender.text!.characters.count
    nameCount.text = remainder < 0 ? "-" : "\(remainder)"
    nameCount.textColor = remainder < 0 ? UIColor.redColor() : UIColor.defaultColor()
    nameExceeded = remainder < 0
    submitButton.enabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  func handleTitleLimit(sender: UITextField) {
    titleCount.hidden = false
    let remainder = 30 - sender.text!.characters.count
    titleCount.text = remainder < 0 ? "-" : "\(remainder)"
    titleCount.textColor = remainder < 0 ? UIColor.redColor() : UIColor.defaultColor()
    titleExceeded = remainder < 0
    submitButton.enabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  func textViewDidBeginEditing(textView: UITextView) {
    if (self.aboutField.textColor == labelColor) {
      self.aboutField.text = ""
      self.aboutField.textColor = UIColor.blackColor()
    }
  }

  func textViewDidEndEditing(textView: UITextView) {
    if (self.aboutField.text.isEmpty) {
      self.aboutField.text = placeHolder
      self.aboutField.textColor = labelColor
    }

    activeText = nil
    aboutCount.hidden = true
  }

  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    activeText = aboutField
    return true
  }

  func keyboardWillShow(notification: NSNotification)
  {
    //Need to calculate keyboard exact size due to Apple suggestions
    self.scrollView.scrollEnabled = true
    let info : NSDictionary = notification.userInfo!
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
    let keyboardHeight = keyboardSize!.height

    var aRect : CGRect = self.scrollView.frame
    aRect.size.height -= keyboardHeight
    if let _ = activeText
    {
      // pt is the lower left corner of the rectangular textfield or textview
      let pt = CGPointMake(activeText!.frame.origin.x, activeText!.frame.origin.y + activeText!.frame.size.height)
      if (!CGRectContainsPoint(aRect, pt))
      {
        // Compute the exact offset we need to scroll the view up
        let offset = activeText!.frame.origin.y + activeText!.frame.size.height - (aRect.origin.y + aRect.size.height)
        self.scrollView.setContentOffset(CGPointMake(0, self.contentOffset.y + offset + 20), animated: true)
      }
    }

    
  }

  func keyboardWillHide(notification: NSNotification)
  {
    nameCount.hidden = true
    titleCount.hidden = true
    self.view.endEditing(true)
    self.scrollView.setContentOffset(CGPointMake(0, self.contentOffset.y), animated: true)
  }

  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.endEditing(true)
  }

  @IBAction func saveButtonTapped(sender: AnyObject) {
    //First start the activity indicator
    var text = "Updating Profile..."
    if (isEditingProfile == false) {
      text = "Thank you for your appplication..."
      if (titleField.text!.isEmpty || aboutField.text!.isEmpty || aboutField.text! == placeHolder) {
        utility.displayAlertMessage("please include your title and a short description of yourself", title: "Missing Info", sender: self)
        return
      }
    }

    if (aboutField.text! == placeHolder) {
      aboutField.text = ""
    }

    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: text)
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    dismissKeyboard()
    var newRate = 0.0
    if (!rateField.text!.isEmpty) {
      newRate = Double(rateField.text!)!
    }

    if (newRate < 0.0) {
      // In real app, this should never happen since we don't provide keyboard that can input negative
      self.utility.displayAlertMessage("Your rate cannot be negative", title: "Alert", sender: self)
      return
    }
    
    userModule.updateProfile(uid!, name: nameField.text!, title: titleField.text!, about: aboutField.text,
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
        if (self.isEditingProfile == false) {
          self.userModule.applyToTakeQuestion(uid!) { result in
            if (!result.isEmpty) {
              dispatch_async(dispatch_get_main_queue()) {
                activityIndicator.hideAnimated(true)
                self.utility.displayAlertMessage("An error occurs. Please apply later", title: "Alert", sender: self)
              }
            }
            else {
              // application successfully submitted
              let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
              dispatch_after(time, dispatch_get_main_queue()) {
                self.isProfileUpdated = true
                activityIndicator.hideAnimated(true)
                self.navigationController?.popViewControllerAnimated(true)
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

  @IBAction func uploadButtonTapped(sender: AnyObject) {
    let myPickerController = UIImagePickerController()
    myPickerController.delegate = self
    myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    self.presentViewController(myPickerController, animated:  true, completion: nil)
  }

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    profilePhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    self.dismissViewControllerAnimated(true, completion: nil)
    uploadImage()
  }

  func uploadImage() {
    //Start activity Indicator
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Uploading Your Photo...")
    var compressionRatio = 1.0
    let photoSize = UIImageJPEGRepresentation(profilePhoto.image!, 1)
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
    let photoData = UIImageJPEGRepresentation(profilePhoto.image!, CGFloat(compressionRatio))
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

  func dismissKeyboard(sender:UIGestureRecognizer) {
    self.view.endEditing(true)
  }

  func dismissKeyboard() {
    nameField.resignFirstResponder()
    titleField.resignFirstResponder()
    aboutField.resignFirstResponder()
  }

  func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? ProfileViewController {
      if (isProfileUpdated) {
        controller.initView()
      }
    }
  }

}
