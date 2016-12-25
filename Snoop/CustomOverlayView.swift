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
  func stopRecording(overlayView: CustomOverlayView)
}

class CustomOverlayView: UIView {
  var delegate:CustomOverlayDelegate! = nil

  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var shootButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var timer: UILabel!
  @IBOutlet weak var countdown: UILabel!
  var isRecording = false
  var recordTimer = NSTimer()
  var count = 0

  override func awakeFromNib() {
    super.awakeFromNib()
    prepareToRecord()
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

  func update() {
    timer.text = String(format: "00:%02d", count)
    if(count > 50) {
      countdown.hidden = false
      let remainder = 60 - count
      countdown.text = "\(remainder)"
      if (count == 60) {
        delegate.stopRecording(self)
        reset()
      }
    }
    count = count + 1
  }

  func reset() {
    isRecording = false
    cancelButton.hidden = false
    cancelButton.setTitle("retake", forState: .Normal)
    shootButton.setImage(UIImage(named: "triangle"), forState: .Normal)
    backButton.hidden = false
    nextButton.hidden = false
    recordTimer.invalidate()
    count = 0
    countdown.hidden = true
    timer.hidden = true
  }

  func prepareToRecord() {
    timer.text = "00:00"
    timer.hidden = false
    shootButton.setImage(UIImage(named: "record"), forState: .Normal)
    cancelButton.setTitle("cancel", forState: .Normal)
    backButton.hidden = true
    nextButton.hidden = true
    countdown.hidden = true
  }

  func startTimer() {
    recordTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CustomOverlayView.update), userInfo: nil, repeats: true)
  }
}
