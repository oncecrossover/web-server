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
class VideoPlayerView: UIView {
  var player: AVPlayer?
  var timeObserver: Any?
  var isPlaying = false

  lazy var closeButton: UIButton = {
    let view = UIButton()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setImage(UIImage(named: "close"), for: UIControlState())
    view.addTarget(self, action: #selector(closeView), for: .touchUpInside)
    return view
  }()

  lazy var playButton: UIButton = {
    let view = UIButton()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setImage(UIImage(named: "play"), for: UIControlState())
    view.contentVerticalAlignment = .fill
    view.contentHorizontalAlignment = .fill
    view.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
    return view
  }()

  let activityIndicator : UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.startAnimating()
    view.hidesWhenStopped = true
    return view
  }()

  let lengthLabel: UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textColor = UIColor.white
    view.text = "00:00"
    view.font = view.font.withSize(12)
    view.textAlignment = .right
    return view
  }()

  let progressLabel : UILabel = {
    let view = UILabel()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.textColor = UIColor.white
    view.text = "00:00"
    view.font = view.font.withSize(12)
    return view
  }()

  lazy var slider : UISlider = {
    let view = UISlider()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setThumbImage(UIImage(named: "thumb"), for: UIControlState())
    view.addTarget(self, action: #selector(handleSlider), for: .valueChanged)
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
    backgroundColor = UIColor.black
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func handlePause() {
    if (isPlaying) {
      isPlaying = false
      playButton.isHidden = false
      player?.pause()
    }
    else {
      isPlaying = true
      playButton.isHidden = true
      player?.play()
    }
  }

  func handleSlider() {
    if let duration = player?.currentItem?.duration {
      let totalSeconds = CMTimeGetSeconds(duration)
      let seekTime = CMTime(value: Int64(Float64(slider.value) * totalSeconds), timescale: 1)
      player?.seek(to: seekTime)
    }
  }

  func closeView() {
    self.gestureRecognizers?.forEach(self.removeGestureRecognizer)
    player?.pause()
    if let _ = self.timeObserver {
      player?.removeTimeObserver(self.timeObserver!)
      self.timeObserver = nil
    }

    UIView.animate(withDuration: 1.0, animations: {
      self.alpha = 0
      }, completion: { (result) in
        self.container.removeFromSuperview()
        self.removeFromSuperview()
    })
  }

  func setupLoadingControls() {
    addSubview(activityIndicator)
    activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }

  func setupPlayingControls() {
    activityIndicator.stopAnimating()
    container.frame = self.frame
    addSubview(container)

    container.addSubview(playButton)
    playButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    playButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    playButton.isHidden = true

    container.addSubview(closeButton)
    closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

    container.addSubview(lengthLabel)
    lengthLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    lengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    lengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    lengthLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

    container.addSubview(progressLabel)
    progressLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
    progressLabel.bottomAnchor.constraint(equalTo: lengthLabel.bottomAnchor).isActive = true
    progressLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    progressLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

    container.addSubview(slider)
    slider.rightAnchor.constraint(equalTo: lengthLabel.leftAnchor).isActive = true
    slider.bottomAnchor.constraint(equalTo: lengthLabel.bottomAnchor).isActive = true
    slider.leftAnchor.constraint(equalTo: progressLabel.rightAnchor).isActive = true
    slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
  }

  func setupProgressControls() {
    let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeView))
    swipeUpGesture.direction = .up
    let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeView))
    swipeDownGesture.direction = .down
    self.addGestureRecognizer(swipeUpGesture)
    self.addGestureRecognizer(swipeDownGesture)

    isPlaying = true
    let interval = CMTime(seconds: 1.0, preferredTimescale: 1)
    self.timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
      let seconds = CMTimeGetSeconds(time)
      let secondsText = String(format: "%02d", Int(seconds) % 60)
      let minutesText = String(format: "%02d", Int(seconds) / 60)
      self?.progressLabel.text = "\(minutesText):\(secondsText)"

      if let duration = self?.player?.currentItem?.duration {
        let durationInseconds = CMTimeGetSeconds(duration)
        self?.slider.value = Float(seconds/durationInseconds)
      }
    }
  }

  func reset() {
    isPlaying  = false
    playButton.isHidden = false
    slider.value = 0
    progressLabel.text = "00:00"
    let seekTime = CMTime(value: 0, timescale: 1)
    player?.seek(to: seekTime)
    player?.pause()
  }
}
