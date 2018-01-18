//
//  EditProfileViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import Photos

class EditProfileViewController: UIViewController {

  var profileView: EditProfileView!

  lazy var submitButton: UIButton = {
    let button = CustomButton()
    button.isEnabled = true
    if (self.isEditingProfile) {
      button.setTitle("Save", for: UIControlState())
    }
    else {
      button.setTitle("Apply", for: UIControlState())
    }

    button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    return button
  }()

  lazy var permissionView: PermissionView = {
    let view = PermissionView()
    view.setHeader("Allow CryptoGo to access your photos")
    view.setInstruction("1. Open iPhone Settings \n2. Tap Privacy \n3. Tap Photos \n4. Set CryptoGo to ON")
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  var labelColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)

  var profileValues: (name: String?, title: String?, about: String?, avatarUrl:  String?, rate: Int?)

  lazy var userModule = User()
  lazy var utility = UIUtility()
  lazy var category = Category()

  var contentOffset: CGPoint = CGPoint.zero

  var activeInputText: UIView?

  var isProfileUpdated = false
  var isEditingProfile = false
  var isSnooper = false

  let placeHolder = "Add a short description of your expertise and your interests"

  var nameExceeded = false
  var titleExceeded = false
  var aboutExceeded = false

  var selectedExpertise: [ExpertiseModel] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white

    initView()

    /* correctly handle:
     case 1: there are no firstName and lastName at all
     case 2: there is only firstName or lastName
     case 3: there are both firstName or lastName
     */
    let names = profileValues.name?.characters.split{$0 == " "}.map(String.init)
    let firstName = names?.first
    let lastName = names?.dropFirst().first

    profileView.fillValues(profileValues.avatarUrl, firstName: firstName, lastName: lastName, title: profileValues.title!, about: profileValues.about!)
    profileView.fillRate(profileValues.rate!)

    setupInputLimits()

    NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    navigationController?.delegate = self

    self.navigationItem.title = "Edit"
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.contentOffset = profileView.contentOffset
  }
}

// Helper in init view
extension EditProfileViewController {
  func initView() {
    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 100)
    if (self.isEditingProfile && !isSnooper) {
      profileView = EditProfileView(frame: frame, includeExpertise: false, selectedExpertise: selectedExpertise)
    }
    else {
      profileView = EditProfileView(frame: frame, includeExpertise: true, selectedExpertise: selectedExpertise)
    }

    self.view.addSubview(profileView)
    self.view.addSubview(submitButton)

    // Setup constraints
    self.view.addConstraintsWithFormat("H:|[v0]|", views: submitButton)
    submitButton.topAnchor.constraint(equalTo: profileView.bottomAnchor).isActive = true
    if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
      submitButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -tabBarHeight).isActive = true
    }
    else {
      submitButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -49).isActive = true
    }

    profileView.about.value.delegate = self
    profileView.rate.value.delegate = self

    profileView.changeButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
  }

  func setupInputLimits() {
    profileView.firstName.value.addTarget(self, action: #selector(handleFirstNameLimit(_:)), for: .editingChanged)
    profileView.lastName.value.addTarget(self, action: #selector(handleLastNameLimit(_:)), for: .editingChanged)
    profileView.title.value.addTarget(self, action: #selector(handleTitleLimit(_:)), for: .editingChanged)
  }
}

// Helper functions
extension EditProfileViewController {
  @objc func handleFirstNameLimit(_ sender: UITextField) {
    profileView.firstName.limit.isHidden = false
    let remainder = 20 - sender.text!.characters.count
    profileView.firstName.limit.text = "\(remainder)"
    profileView.firstName.limit.textColor = remainder < 0 ? UIColor.red : UIColor.defaultColor()
    nameExceeded = remainder < 0
    submitButton.isEnabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  @objc func handleLastNameLimit(_ sender: UITextField) {
    profileView.lastName.limit.isHidden = false
    let remainder = 20 - sender.text!.characters.count
    profileView.lastName.limit.text = "\(remainder)"
    profileView.lastName.limit.textColor = remainder < 0 ? UIColor.red : UIColor.defaultColor()
    nameExceeded = remainder < 0
    submitButton.isEnabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  @objc func handleTitleLimit(_ sender: UITextField) {
    profileView.title.limit.isHidden = false
    let remainder = 30 - sender.text!.characters.count
    profileView.title.limit.text = "\(remainder)"
    profileView.title.limit.textColor = remainder < 0 ? UIColor.red : UIColor.defaultColor()
    titleExceeded = remainder < 0
    submitButton.isEnabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  @objc func keyboardWillShow(_ notification: Notification)
  {
    //Need to calculate keyboard exact size due to Apple suggestions
    profileView.isScrollEnabled = true
    let info : NSDictionary = notification.userInfo! as NSDictionary
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    // We need to add 20 to count for the height of keyboard hint
    let keyboardHeight = keyboardSize!.height + 20;

    var aRect : CGRect = profileView.frame
    // We need to add 100 to count for the height of submitbutton and tabbar
    aRect.size.height = aRect.size.height + 100 - keyboardHeight
    if let _ = activeInputText
    {
      // pt is the lower left corner of the rectangular textfield or textview
      let pt = CGPoint(x: activeInputText!.frame.origin.x, y: activeInputText!.frame.origin.y + activeInputText!.frame.size.height)
      let ptInProfileView = activeInputText?.convert(pt, to: profileView)

      if (!aRect.contains(ptInProfileView!))
      {
        // Compute the exact offset we need to scroll the view up
        DispatchQueue.main.async {
          let offset = ptInProfileView!.y - (aRect.origin.y + aRect.size.height)
          self.profileView.setContentOffset(CGPoint(x: 0, y: self.contentOffset.y + offset + 40),animated: true)
        }
      }
    }
  }

  @objc func keyboardWillHide(_ notification: Notification)
  {
    profileView.firstName.limit.isHidden = true
    profileView.lastName.limit.isHidden = true
    profileView.title.limit.isHidden = true
    self.view.endEditing(true)
    profileView.setContentOffset(CGPoint(x: 0, y: self.contentOffset.y), animated: true)
  }

  func dismissKeyboard() {
    profileView.firstName.value.resignFirstResponder()
    profileView.lastName.value.resignFirstResponder()
    profileView.title.value.resignFirstResponder()
    profileView.about.value.resignFirstResponder()
    profileView.rate.value.resignFirstResponder()
  }
}

extension EditProfileViewController: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    activeInputText = profileView.rate.value
    return true;
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    activeInputText = nil
  }
}

extension EditProfileViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    profileView.about.limit.isHidden = false
    let remainder = 80 - textView.text!.characters.count
    profileView.about.limit.text = "\(remainder)"
    profileView.about.limit.textColor = remainder < 0 ? UIColor.red : UIColor.defaultColor()
    aboutExceeded = remainder < 0
    submitButton.isEnabled = !nameExceeded && !titleExceeded && !aboutExceeded
  }

  func textViewDidBeginEditing(_ textView: UITextView) {
    if (profileView.about.value.textColor == labelColor) {
      profileView.about.value.text = ""
      profileView.about.value.textColor = UIColor.black
    }
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if (profileView.about.value.text.isEmpty) {
      profileView.about.value.text = placeHolder
      profileView.about.value.textColor = labelColor
    }

    activeInputText = nil
    profileView.about.limit.isHidden = true
  }

  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    activeInputText = profileView.about.value
    return true
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
}

// IB related actions
extension EditProfileViewController {

  func trimmingSpaces(_ strValue: String!) -> String! {
    return strValue.trimmingCharacters(in: CharacterSet.whitespaces)
  }

  func fieldsNotReadyToSubmit() -> Bool {
    return
      trimmingSpaces(profileView.firstName.value.text!).isEmpty
      || trimmingSpaces(profileView.lastName.value.text!).isEmpty
      || trimmingSpaces(profileView.title.value.text!).isEmpty
      || trimmingSpaces(profileView.about.value.text!).isEmpty
      || profileView.about.value.text! == placeHolder;
  }

  @objc func submitButtonTapped() {
    dismissKeyboard()
    if (fieldsNotReadyToSubmit()) {
      utility.displayAlertMessage("please include name, title and description", title: "Missing Info", sender: self)
      return
    }

    //First start the activity indicator
    var text = "Updating Profile..."
    if (isEditingProfile == false) {
      text = "Thanks for your appplication..."
    }

    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: text)
    let uid = UserDefaults.standard.string(forKey: "uid")
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
    userModule.updateProfile(uid!, name: fullName, title: profileView.title.value.text!, about: profileView.about.value.textColor == labelColor ? "" :  profileView.about.value.text!,
      rate: newRate){ resultString in
      var message = "Your profile is successfully updated!"
      if (!resultString.isEmpty) {
        message = resultString
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
          self.utility.displayAlertMessage(message, title: "Alert", sender: self)
        }
      }
      else {
        if (self.isEditingProfile == false || self.isSnooper) {
          // Update a user's expertise areas
          self.category.updateInterests(uid!, interests: self.profileView.expertise.populateCategoriesToUpdate()) { result in
            if (!result.isEmpty) {
              DispatchQueue.main.async {
                activityIndicator.hide(animated: true)
                self.utility.displayAlertMessage("An error occurs. Please apply later", title: "Alert", sender: self)
              }
            }
            else {
              if (self.isEditingProfile == false) {
                // The users are applying to be a snooper
                self.userModule.applyToTakeQuestion(uid!) { result in
                  if (!result.isEmpty) {
                    DispatchQueue.main.async {
                      activityIndicator.hide(animated: true)
                      self.utility.displayAlertMessage("An error occurs. Please apply later", title: "Alert", sender: self)
                    }
                  }
                  else {
                    // application successfully submitted
                    DispatchQueue.main.async {
                      self.isProfileUpdated = true
                      activityIndicator.hide(animated: true)
                      _ = self.navigationController?.popViewController(animated: true)
                    }
                  }
                }
              }
              else {
                DispatchQueue.main.async {
                  self.isProfileUpdated = true
                  activityIndicator.hide(animated: true)
                  _ = self.navigationController?.popViewController(animated: true)
                }
              }

            }
          }
        }
        else {
          // We use the delay so users can always see the activity indicator showing profile is being updated
          let time = DispatchTime.now() + Double(1 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
          DispatchQueue.main.asyncAfter(deadline: time) {
            self.isProfileUpdated = true
            activityIndicator.hide(animated: true)
            _ = self.navigationController?.popViewController(animated: true)
          }
        }
      }
    }
  }

  @objc func uploadButtonTapped() {
    if (PHPhotoLibrary.authorizationStatus() == .denied) {
      if let window = UIApplication.shared.keyWindow {
        window.addSubview(permissionView)
        window.addConstraintsWithFormat("H:|[v0]|", views: permissionView)
        window.addConstraintsWithFormat("V:|[v0]|", views: permissionView)
        permissionView.alpha = 0
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
          self.permissionView.alpha = 1
        }, completion: nil)
        return
      }
    }

    let myPickerController = UIImagePickerController()
    myPickerController.delegate = self
    myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
    self.present(myPickerController, animated:  true, completion: nil)
  }
}

// UIImagePickerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    profileView.profilePhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    self.dismiss(animated: true, completion: nil)
    uploadImage()
  }

  func uploadImage() {
    //Start activity Indicator
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Uploading Your Photo...")
    var compressionRatio = 1.0
    let photoSize = UIImageJPEGRepresentation(profileView.profilePhoto.image!, 1)
    if let size = photoSize?.count {
      if (size > 1000000) {
        compressionRatio = 0.005
      }
      else if (size > 500000) {
        compressionRatio = 0.01
      }
      else if (size > 100000){
        compressionRatio = 0.05
      }
      else if (size > 10000) {
        compressionRatio = 0.2
      }
    }

    let photoData = UIImageJPEGRepresentation(profileView.profilePhoto.image!, CGFloat(compressionRatio))
    let uid = UserDefaults.standard.string(forKey: "uid")
    userModule.updateProfilePhoto(uid!, imageData: photoData){ resultString in
      var message = ""
      if (resultString.isEmpty) {
        DispatchQueue.main.async {
          self.isProfileUpdated = true
          activityIndicator.hide(animated: true)
          if let url = self.profileValues.avatarUrl {
            SDImageCache.shared().removeImage(forKey: url, fromDisk: true, withCompletion: nil)
          }
          self.displayConfirmation("Photo Updated!")
        }
      }
      else {
        message = resultString
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
          self.utility.displayAlertMessage(message, title: "Alert", sender: self)
        }
      }
    }
  }
}

// UINavigationControllerDelegate
extension EditProfileViewController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if let controller = viewController as? ProfileViewController {
      if (isProfileUpdated) {
        controller.initView()
      }
    }
  }

}
