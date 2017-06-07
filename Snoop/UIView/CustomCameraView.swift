//
//  CustomCameraView.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/20/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

protocol CustomCameraViewDelegate {
  func didDelete(_ overlayView: CustomCameraView)
  func didShoot(_ overlayView:CustomCameraView)
  func didBack(_ overlayView: CustomCameraView)
  func didNext(_ overlayView: CustomCameraView)
  func didPlay(_ overlayView: CustomCameraView)
  func didSwitch(_ overlayView: CustomCameraView)
  func stopRecording(_ overlayView: CustomCameraView)
}

class CustomCameraView: UIView {

  var delegate: CustomCameraViewDelegate! = nil
  var isRecording = false
  var recordTimer = Timer()
  var blinkTimer = Timer()
  var count = 0
  var lastCount = 0
  var listOfProgress: [Int] = []

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

  lazy var playButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: "triangle"), for: UIControlState())
    button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
    button.titleLabel?.textColor = UIColor.white
    return button
  }()

  lazy var switchButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: "switch"), for: UIControlState())
    button.addTarget(self, action: #selector(handleSwitch), for: .touchUpInside)
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
    view.backgroundColor = UIColor(white: 0, alpha: 0.7)
    return view
  }()

  lazy var deleteButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "delete"), for: UIControlState())
    button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
    button.titleLabel?.textColor = UIColor.white
    return button
  }()

  lazy var nextButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "next"), for: UIControlState())
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

  let progressBar: UIProgressView = {
    let view = UIProgressView()
    view.transform = CGAffineTransform(scaleX: 1, y: 2)
    view.trackTintColor = UIColor.lightGray
    view.progressTintColor = UIColor.defaultColor()
    return view
  }()

  var deleteHighlightBar: UIView?

  func handleShoot() {
    delegate.didShoot(self)
  }

  func handleBack() {
    delegate.didBack(self)
  }

  func handleDelete() {
    prepareToDeleteSegment()
    delegate.didDelete(self)
  }

  func handleNext(){
    delegate.didNext(self)
  }

  func handlePlay() {
    delegate.didPlay(self)
  }

  func handleSwitch() {
    delegate.didSwitch(self)
  }

  func update() {
    time.text = String(format: "00:%02d", count)
    let progress = Float(count)/Float(60)
    progressBar.setProgress(progress, animated: true)
    if(count > 50) {
      reminder.isHidden = false
      let remainder = 60 - count
      reminder.text = "\(remainder)"
      if (count == 60) {
        delegate.stopRecording(self)
        recordButton.isHidden = true
      }
    }
    count = count + 1
  }

  func blink() {
    if (self.deleteHighlightBar?.backgroundColor == UIColor.red) {
      self.deleteHighlightBar?.backgroundColor = UIColor.clear
    }
    else {
      self.deleteHighlightBar?.backgroundColor = UIColor.red
    }
  }

  func resetProgressBarAndCount() {
    let progress = listOfProgress.reduce(0, +)
    self.progressBar.setProgress(Float(progress/60), animated: true)
    self.count = progress
    self.lastCount = progress
  }

  func deleteSegment() {
    // We need to do several things here.
    if (listOfProgress.count > 0) {
      // Delete the last segment
      listOfProgress.removeLast()

      // reset the clock count
      self.count = listOfProgress.reduce(0, +)
      self.time.text = String(format: "00:%02d", count)

      // reset progress bar
      progressBar.setProgress(Float(self.count)/Float(60), animated: true)

      // hide highlight bar
      hideHighlightBar()

      recordButton.isHidden = false
    }

    if (listOfProgress.count == 0) {
      prepareToRecord()
    }
  }

  func createDeleteHighlightBar() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.red
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }

  func hideHighlightBar() {
    UIView.animate(withDuration: 0.5) {
      self.blinkTimer.invalidate()
      self.deleteHighlightBar?.alpha = 0
      self.deleteHighlightBar?.removeFromSuperview()
      self.deleteHighlightBar = nil
    }
  }

  func cancelDeleteSegment() {
    hideHighlightBar()
  }

  func prepareToDeleteSegment() {
    if (listOfProgress.count > 0) {
      // 1. compute the width of highlight bar
      let width = Float(self.listOfProgress.last!)/Float(60) * Float(self.frame.width)

      // 2. compute the trailing anchor of highlight bar
      let anchor = Float(Float(1) - self.progressBar.progress) * Float(self.frame.width)

      // 3. Present highlight bar
      self.deleteHighlightBar = createDeleteHighlightBar()
      self.deleteHighlightBar?.alpha = 0
      addSubview(deleteHighlightBar!)
      deleteHighlightBar?.heightAnchor.constraint(equalTo: progressBar.heightAnchor, multiplier: 2).isActive = true
      deleteHighlightBar?.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor).isActive = true
      deleteHighlightBar?.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
      deleteHighlightBar?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -CGFloat(anchor)).isActive = true

      UIView.animate(withDuration: 0.5) {
        self.layoutIfNeeded()
        DispatchQueue.main.async {
          UIView.animate(withDuration: 0.5) {
            self.deleteHighlightBar?.alpha = 1
            // start the blinking effect of highlight bar
            self.blinkTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(CustomCameraView.blink), userInfo: nil, repeats: true)
          }
        }
      }
    }
  }

  func hideCameraControls() {
    startTimer()
    recordButton.setImage(UIImage(named: "recording"), for: UIControlState())
    deleteButton.isHidden = true
    nextButton.isHidden = true
    playButton.isHidden = true
    switchButton.isHidden = true
  }
  func showCameraControls() {
    // The function is invoked when user just finishes on segment of recording
    isRecording = false
    deleteButton.isHidden = false
    backButton.isHidden = false
    nextButton.isHidden = false
    playButton.isHidden = false
    switchButton.isHidden = false
    reminder.isHidden = true
    recordButton.setImage(UIImage(named: "record"), for: UIControlState())
    recordTimer.invalidate()
    listOfProgress.append(count - lastCount)
  }

  func prepareToRecord() {
    // This function is invoked when we first launch the camera view
    time.text = "00:00"
    time.isHidden = false
    isRecording = false
    recordButton.setImage(UIImage(named: "record"), for: UIControlState())
    backButton.isHidden = false

    // Initially, we don't show the next button
    nextButton.isHidden = true

    // Initially, we hide the play button since there is nothing to play
    playButton.isHidden = true

    // Initially, we also hide the delete button since there is nothing to delete
    deleteButton.isHidden = true

    // We show reminder only in the last 10 seconds of recording
    reminder.isHidden = true

    // We initialize the following values to origin
    count = 0
    lastCount = 0
    listOfProgress = []
  }

  func startTimer() {
    // When starting recording, we need to store the starting time in self.lastCount
    self.lastCount = self.count
    recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(CustomCameraView.update), userInfo: nil, repeats: true)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    self.backgroundColor = UIColor.clear
    addSubview(navBar)
    addSubview(bottomBar)
    addSubview(progressBar)
    addSubview(backButton)
    addSubview(switchButton)
    addSubview(time)
    addSubview(reminder)
    addSubview(deleteButton)
    addSubview(recordButton)
    addSubview(nextButton)
    addSubview(playButton)

    // setup constraints for top bar
    addConstraintsWithFormat("H:|[v0]|", views: navBar)
    addConstraintsWithFormat("V:|[v0(40)]", views: navBar)

    // Add constraints for cancel button and time label
    addConstraintsWithFormat("H:|-8-[v0(55)]", views: backButton)
    addConstraintsWithFormat("V:|-5-[v0(30)]", views: backButton)
    addConstraintsWithFormat("H:[v0(55)]-8-|", views: switchButton)
    addConstraintsWithFormat("V:|-5-[v0(30)]", views: switchButton)
    time.centerXAnchor.constraint(equalTo: navBar.centerXAnchor).isActive = true
    time.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
    time.widthAnchor.constraint(equalToConstant: 60).isActive = true
    time.heightAnchor.constraint(equalToConstant: 20).isActive = true

    // Add constraints for bottom bar
    addConstraintsWithFormat("H:|[v0]|", views: bottomBar)
    addConstraintsWithFormat("V:[v0(80)]|", views: bottomBar)

    // Add constraints for progress bar
    addConstraintsWithFormat("H:|[v0]|", views: progressBar)
    progressBar.topAnchor.constraint(equalTo: bottomBar.topAnchor).isActive = true

    // Setup bottom buttons
    recordButton.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor).isActive = true
    recordButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor).isActive = true
    recordButton.widthAnchor.constraint(equalToConstant: 55).isActive =  true
    recordButton.heightAnchor.constraint(equalToConstant: 55).isActive = true

    addConstraintsWithFormat("H:|-30-[v0(40)]", views: deleteButton)
    deleteButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
    deleteButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

    addConstraintsWithFormat("H:[v0(40)]-30-|", views: nextButton)
    nextButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    nextButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true

    addConstraintsWithFormat("V:[v0(30)]-10-[v1]", views: playButton, bottomBar)
    playButton.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor).isActive = true
    playButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

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
