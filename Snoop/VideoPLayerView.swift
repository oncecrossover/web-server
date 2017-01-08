//
//  VideoPLayerView.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/6/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
class VideoPLayerView: UIView {
  var player: AVPlayer?
  var isPlaying = false

  lazy var closeButton: UIButton = {
    let view = UIButton()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setImage(UIImage(named: "close"), forState: .Normal)
    view.addTarget(self, action: #selector(closeView), forControlEvents: .TouchUpInside)
    return view
  }()

  lazy var playButton: UIButton = {
    let view = UIButton()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setImage(UIImage(named: "play"), forState: .Normal)
    view.addTarget(self, action: #selector(handlePause), forControlEvents: .TouchUpInside)
    return view
  }()

  let activityIndicator : UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.startAnimating()
    view.hidesWhenStopped = true
    return view
  }()

  let lengthLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textColor = UIColor.whiteColor()
    view.text = "00:00"
    view.font = view.font.fontWithSize(12)
    view.textAlignment = .Right
    return view
  }()

  let progressLabel : UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textColor = UIColor.whiteColor()
    view.text = "00:00"
    view.font = view.font.fontWithSize(12)
    return view
  }()

  lazy var slider : UISlider = {
    let view = UISlider()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setThumbImage(UIImage(named: "thumb"), forState: .Normal)
    view.addTarget(self, action: #selector(handleSlider), forControlEvents: .ValueChanged)
    return view
  }()

  lazy var container : UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.2)
    let tappedOnPlayer = UITapGestureRecognizer(target: self, action: #selector(handlePause))
    view.addGestureRecognizer(tappedOnPlayer)
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.blackColor()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func handlePause() {
    if (isPlaying) {
      isPlaying = false
      playButton.hidden = false
      player?.pause()
    }
    else {
      isPlaying = true
      playButton.hidden = true
      player?.play()
    }
  }

  func handleSlider() {
    if let duration = player?.currentItem?.duration {
      let totalSeconds = CMTimeGetSeconds(duration)
      let seekTime = CMTime(value: Int64(Float64(slider.value) * totalSeconds), timescale: 1)
      player?.seekToTime(seekTime)
    }
  }

  func closeView() {
    player?.pause()
    container.removeFromSuperview()
    self.removeFromSuperview()
  }

  func setupLoadingControls() {
    addSubview(activityIndicator)
    activityIndicator.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    activityIndicator.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
  }

  func setupPlayingControls() {
    activityIndicator.stopAnimating()
    container.frame = self.frame
    addSubview(container)

    container.addSubview(playButton)
    playButton.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    playButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
    playButton.widthAnchor.constraintEqualToConstant(30).active = true
    playButton.heightAnchor.constraintEqualToConstant(30).active = true
    playButton.hidden = true

    container.addSubview(closeButton)
    closeButton.rightAnchor.constraintEqualToAnchor(rightAnchor, constant : -8).active = true
    closeButton.topAnchor.constraintEqualToAnchor(topAnchor, constant: 24).active = true
    closeButton.widthAnchor.constraintEqualToConstant(30).active = true
    closeButton.heightAnchor.constraintEqualToConstant(30).active = true

    container.addSubview(lengthLabel)
    lengthLabel.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -8).active = true
    lengthLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -16).active = true
    lengthLabel.widthAnchor.constraintEqualToConstant(50).active = true
    lengthLabel.heightAnchor.constraintEqualToConstant(30).active = true

    container.addSubview(progressLabel)
    progressLabel.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: 8).active = true
    progressLabel.bottomAnchor.constraintEqualToAnchor(lengthLabel.bottomAnchor).active = true
    progressLabel.widthAnchor.constraintEqualToConstant(50).active = true
    progressLabel.heightAnchor.constraintEqualToConstant(30).active = true

    container.addSubview(slider)
    slider.rightAnchor.constraintEqualToAnchor(lengthLabel.leftAnchor).active = true
    slider.bottomAnchor.constraintEqualToAnchor(lengthLabel.bottomAnchor).active = true
    slider.leftAnchor.constraintEqualToAnchor(progressLabel.rightAnchor).active = true
    slider.heightAnchor.constraintEqualToConstant(30).active = true
  }

  func setupProgressControls() {
    isPlaying = true
    let interval = CMTime(seconds: 1.0, preferredTimescale: 1)
    player?.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) { time in
      let seconds = CMTimeGetSeconds(time)
      let secondsText = String(format: "%02d", Int(seconds) % 60)
      let minutesText = String(format: "%02d", Int(seconds) / 60)
      self.progressLabel.text = "\(minutesText):\(secondsText)"

      if let duration = self.player?.currentItem?.duration {
        let durationInseconds = CMTimeGetSeconds(duration)
        self.slider.value = Float(seconds/durationInseconds)
      }
    }
  }

  func reset() {
    isPlaying  = false
    playButton.hidden = false
    slider.value = 0
    progressLabel.text = "00:00"
    let seekTime = CMTime(value: 0, timescale: 1)
    player?.seekToTime(seekTime)
    player?.pause()
  }
}
