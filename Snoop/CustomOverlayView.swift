//
//  CustomOverlayView.swift
//  Snoop
//
//  Created by Bowen Zhang on 12/1/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

protocol CustomOverlayDelegate {
  func didCancel(overlayView:CustomOverlayView)
  func didShoot(overlayView:CustomOverlayView)
  func didBack(overlayView: CustomOverlayView)
  func didNext(overlayView: CustomOverlayView)
}

class CustomOverlayView: UIView {
  var delegate:CustomOverlayDelegate! = nil

  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var shootButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  var isRecording = false

  override func awakeFromNib() {
    super.awakeFromNib()
    shootButton.setImage(UIImage(named: "record"), forState: .Normal)
    cancelButton.setTitle("cancel", forState: .Normal)
    backButton.hidden = true
    nextButton.hidden = true
  }

  @IBAction func shootButtonTapped(sender: AnyObject) {
    delegate.didShoot(self)
  }

  @IBAction func cancelButtonTapped(sender: AnyObject) {
    delegate.didCancel(self)
  }
  
  @IBAction func backButtonTapped(sender: AnyObject) {
    delegate.didBack(self)
  }
  @IBAction func nextButtonTapped(sender: AnyObject) {
    delegate.didNext(self)
  }
}
