//
//  CustomCameraView.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

protocol CustomCameraViewDelegate {
  func didCancel(overlayView: CustomCameraView)
  func didShoot(overlayView:CustomCameraView)
  func didBack(overlayView: CustomCameraView)
  func didNext(overlayView: CustomCameraView)
  func stopRecording(overlayView: CustomCameraView)
}

class CustomCameraView: UIView {

  var delegate: CustomCameraViewDelegate! = nil
  var isRecording = false
  var recordTimer = NSTimer()
  var count = 0

  let navBar: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(white: 0, alpha: 0.2)
    return view
  }()

  let time: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    return label
  }()

  lazy var backButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Back", forState: .Normal)
    button.addTarget(self, action: #selector(handleBack), forControlEvents: .TouchUpInside)
    button.titleLabel?.textColor = UIColor.whiteColor()
    return button
  }()

  let reminder: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    label.font = UIFont.systemFontOfSize(64)
    return label
  }()

  let bottomBar: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(white: 0, alpha: 0.2)
    return view
  }()

  lazy var cancelButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Cancel", forState: .Normal)
    button.addTarget(self, action: #selector(handleCancel), forControlEvents: .TouchUpInside)
    button.titleLabel?.textColor = UIColor.whiteColor()
    return button
  }()

  lazy var nextButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Next", forState: .Normal)
    button.addTarget(self, action: #selector(handleNext), forControlEvents: .TouchUpInside)
    button.titleLabel?.textColor = UIColor.whiteColor()
    return button
  }()

  lazy var recordButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: "record"), forState: .Normal)
    button.addTarget(self, action: #selector(handleShoot), forControlEvents: .TouchUpInside)
    return button
  }()

  func handleShoot() {
    delegate.didShoot(self)
  }

  func handleBack() {
    delegate.didBack(self)
  }

  func handleCancel() {
    delegate.didCancel(self)
  }

  func handleNext(){
    delegate.didNext(self)
  }

  func update() {
    time.text = String(format: "00:%02d", count)
    if(count > 50) {
      reminder.hidden = false
      let remainder = 60 - count
      reminder.text = "\(remainder)"
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
    recordButton.setImage(UIImage(named: "triangle"), forState: .Normal)
    backButton.hidden = false
    nextButton.hidden = false
    recordTimer.invalidate()
    count = 0
    reminder.hidden = true
    time.hidden = true
  }

  func prepareToRecord() {
    time.text = "00:00"
    time.hidden = false
    recordButton.setImage(UIImage(named: "record"), forState: .Normal)
    cancelButton.setTitle("cancel", forState: .Normal)
    backButton.hidden = true
    nextButton.hidden = true
    reminder.hidden = true
  }

  func startTimer() {
    recordTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CustomCameraView.update), userInfo: nil, repeats: true)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    self.backgroundColor = UIColor.clearColor()
    addSubview(navBar)
    addSubview(bottomBar)
    addSubview(backButton)
    addSubview(time)
    addSubview(reminder)
    addSubview(cancelButton)
    addSubview(recordButton)
    addSubview(nextButton)

    // setup constraints for top bar
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: [], metrics: nil, views: ["v0": navBar]))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v0(40)]", options: [], metrics: nil, views: ["v0" : navBar]))

    // Add constraints for cancel button and time label
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[v0(55)]", options: [], metrics: nil, views: ["v0" : backButton]))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[v0(30)]", options: [], metrics: nil, views: ["v0": backButton]))
    time.centerXAnchor.constraintEqualToAnchor(navBar.centerXAnchor).active = true
    time.centerYAnchor.constraintEqualToAnchor(navBar.centerYAnchor).active = true
    time.widthAnchor.constraintEqualToConstant(60).active = true
    time.heightAnchor.constraintEqualToConstant(20).active = true

    // Add constraints for bottom bar
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: [], metrics: nil, views: ["v0": bottomBar]))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[v0(80)]|", options: [], metrics: nil, views: ["v0" : bottomBar]))

    // Setup bottom buttons
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[v0(55)]", options: [], metrics: nil, views: ["v0" : cancelButton]))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[v0(30)]-25-|", options: [], metrics: nil, views: ["v0" : cancelButton]))
    recordButton.centerXAnchor.constraintEqualToAnchor(bottomBar.centerXAnchor).active = true
    recordButton.centerYAnchor.constraintEqualToAnchor(bottomBar.centerYAnchor).active = true
    recordButton.widthAnchor.constraintEqualToConstant(55).active =  true
    recordButton.heightAnchor.constraintEqualToConstant(55).active = true
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[v0(55)]-8-|", options: [], metrics: nil, views: ["v0" : nextButton]))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[v0(30)]-25-|", options: [], metrics: nil, views: ["v0" : nextButton]))

    // Add constraints for countdown label
    reminder.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    reminder.bottomAnchor.constraintEqualToAnchor(bottomBar.topAnchor, constant: -40).active = true
    reminder.widthAnchor.constraintEqualToConstant(40).active = true
    reminder.heightAnchor.constraintEqualToConstant(80).active = true

    prepareToRecord()
}

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
