//
//  extension.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/11/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension String {
  func toBool() -> Bool {
    switch self {
    case "TRUE", "True", "true", "YES", "Yes", "yes", "1":
      return true
    case "FALSE", "False", "false", "NO", "No", "no", "0":
      return false
    default:
      return false
    }
  }
}

extension Int {
  func toTimeFormat() -> String {
    let minute = self / 60
    let seconds = self % 60
    return String(format:"%02i:%02i", minute, seconds)
  }
}

extension UIColor {
  public class func defaultColor() -> UIColor {
    return UIColor(red: 51/255, green: 181/255, blue: 159/255, alpha: 1.0)
  }

  public class func disabledColor() -> UIColor {
    return UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
  }

  public class func secondaryTextColor() -> UIColor {
    return UIColor(red: 140/255, green: 157/255, blue: 170/255, alpha: 1.0)
  }
}

extension UIView {
  public func addConstraintsWithFormat(_ format: String, views: UIView...) {
    var viewDictionary = [String: UIView]()
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      view.translatesAutoresizingMaskIntoConstraints = false
      viewDictionary[key] = view
    }

    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewDictionary))
  }
}

extension UIViewController {
  func launchVideoPlayer(_ answerUrl: String, duration: Int) -> VideoPlayerView {
    let videoPlayerView = VideoPlayerView()
    let bounds = UIScreen.main.bounds

    let oldFrame = CGRect(x: 0, y: bounds.size.height, width: bounds.size.width, height: 0)
    videoPlayerView.frame = oldFrame
    let newFrame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
    self.tabBarController?.view.addSubview(videoPlayerView)
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      videoPlayerView.frame = newFrame
      videoPlayerView.setupLoadingControls()
    }, completion: nil)

    let player = AVPlayer(url: URL(string: answerUrl)!)
    videoPlayerView.player = player
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    videoPlayerView.layer.addSublayer(playerLayer)
    playerLayer.frame = videoPlayerView.frame
    videoPlayerView.setupPlayingControls()
    let secondsText = String(format: "%02d", duration % 60)
    let minutesText = String(format: "%02d", duration / 60)
    videoPlayerView.lengthLabel.text = "\(minutesText):\(secondsText)"
    videoPlayerView.setupProgressControls()

    player.play()
    return videoPlayerView
  }

  public func displayConfirmation(_ msg: String) {
    let confirmView = ConfirmView()
    confirmView.translatesAutoresizingMaskIntoConstraints = false
    confirmView.setMessage(msg)
    view.addSubview(confirmView)
    confirmView.widthAnchor.constraint(equalToConstant: 160).isActive = true
    confirmView.heightAnchor.constraint(equalToConstant: 90).isActive = true
    confirmView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    confirmView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    confirmView.alpha = 0
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      confirmView.alpha = 1
    }, completion: nil)
    let time = DispatchTime.now() + Double(2 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        confirmView.alpha = 0
      }) { (result) in
        confirmView.removeFromSuperview()
      }
    }
  }
}
