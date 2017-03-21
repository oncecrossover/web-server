//
//  CustomCameraView.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

protocol CustomCameraViewDelegate {
  func didCancel(_ overlayView: CustomCameraView)
  func didShoot(_ overlayView:CustomCameraView)
  func didBack(_ overlayView: CustomCameraView)
  func didNext(_ overlayView: CustomCameraView)
  func stopRecording(_ overlayView: CustomCameraView)
}

class CustomCameraView: UIView {

  var delegate: CustomCameraViewDelegate! = nil
  var isRecording = false
  var recordTimer = Timer()
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
    label.textColor = UIColor.white
    label.textAlignment = .center
    return label
  }()

  lazy var backButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Back", for: UIControlState())
    button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    button.titleLabel?.textColor = UIColor.white
    return button
  }()

  let reminder: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor.white
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 64)
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
    button.setTitle("Cancel", for: UIControlState())
    button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
    button.titleLabel?.textColor = UIColor.white
    return button
  }()

  lazy var nextButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Next", for: UIControlState())
    button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    button.titleLabel?.textColor = UIColor.white
    return button
  }()

  lazy var recordButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: "record"), for: UIControlState())
    button.addTarget(self, action: #selector(handleShoot), for: .touchUpInside)
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
      reminder.isHidden = false
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
    cancelButton.isHidden = false
    cancelButton.setTitle("retake", for: UIControlState())
    recordButton.setImage(UIImage(named: "triangle"), for: UIControlState())
    backButton.isHidden = false
    nextButton.isHidden = false
    recordTimer.invalidate()
    count = 0
    reminder.isHidden = true
    time.isHidden = true
  }

  func prepareToRecord() {
    time.text = "00:00"
    time.isHidden = false
    isRecording = false
    recordButton.setImage(UIImage(named: "record"), for: UIControlState())
    cancelButton.setTitle("cancel", for: UIControlState())
    backButton.isHidden = true
    nextButton.isHidden = true
    reminder.isHidden = true
    count = 0
  }

  func startTimer() {
    recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(CustomCameraView.update), userInfo: nil, repeats: true)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    self.backgroundColor = UIColor.clear
    addSubview(navBar)
    addSubview(bottomBar)
    addSubview(backButton)
    addSubview(time)
    addSubview(reminder)
    addSubview(cancelButton)
    addSubview(recordButton)
    addSubview(nextButton)

    // setup constraints for top bar
    addConstraintsWithFormat("H:|[v0]|", views: navBar)
    addConstraintsWithFormat("V:|[v0(40)]", views: navBar)

    // Add constraints for cancel button and time label
    addConstraintsWithFormat("H:|-8-[v0(55)]", views: backButton)
    addConstraintsWithFormat("V:|-5-[v0(30)]", views: backButton)
    time.centerXAnchor.constraint(equalTo: navBar.centerXAnchor).isActive = true
    time.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
    time.widthAnchor.constraint(equalToConstant: 60).isActive = true
    time.heightAnchor.constraint(equalToConstant: 20).isActive = true

    // Add constraints for bottom bar
    addConstraintsWithFormat("H:|[v0]|", views: bottomBar)
    addConstraintsWithFormat("V:[v0(80)]|", views: bottomBar)

    // Setup bottom buttons
    addConstraintsWithFormat("H:|-8-[v0(55)]", views: cancelButton)
    addConstraintsWithFormat("V:[v0(30)]-25-|", views: cancelButton)

    recordButton.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor).isActive = true
    recordButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor).isActive = true
    recordButton.widthAnchor.constraint(equalToConstant: 55).isActive =  true
    recordButton.heightAnchor.constraint(equalToConstant: 55).isActive = true

    addConstraintsWithFormat("H:[v0(55)]-8-|", views: nextButton)
    addConstraintsWithFormat("V:[v0(30)]-25-|", views: nextButton)

    // Add constraints for countdown label
    reminder.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    reminder.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -40).isActive = true
    reminder.widthAnchor.constraint(equalToConstant: 40).isActive = true
    reminder.heightAnchor.constraint(equalToConstant: 80).isActive = true

    prepareToRecord()
}

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
