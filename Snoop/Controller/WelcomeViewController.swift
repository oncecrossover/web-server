//
//  WelcomeViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/19/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class WelcomeViewController: UIViewController {
  let videoPlayerView = UIView()
  var player: AVPlayer?
  lazy var signupButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.backgroundColor = UIColor.defaultColor()
    button.setTitle("Sign Up", for: UIControlState())
    button.setTitleColor(UIColor.white, for: UIControlState())

    button.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var loginButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.defaultColor().cgColor
    button.setTitle("Log In", for: UIControlState())
    button.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    button.backgroundColor = UIColor.white

    button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    view.backgroundColor = UIColor.white
    view.addSubview(videoPlayerView)
    view.addSubview(signupButton)
    view.addSubview(loginButton)

    view.addConstraintsWithFormat("H:|[v0]|", views: videoPlayerView)
    view.addConstraintsWithFormat("V:|[v0]|", views: videoPlayerView)

    // Setup button
    signupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
    signupButton.heightAnchor.constraint(equalToConstant: 47).isActive = true
    signupButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -12).isActive = true
    signupButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
    loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
    loginButton.heightAnchor.constraint(equalTo: signupButton.heightAnchor).isActive = true
    loginButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 12).isActive = true
    loginButton.bottomAnchor.constraint(equalTo: signupButton.bottomAnchor).isActive = true

    NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil) { (_) in
      self.player?.pause()
    }

    NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil) { (_) in
      self.player?.play()
    }

    UserDefaults.standard.set(true, forKey: "isUserWelcomed")
    UserDefaults.standard.synchronize()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Config().getConfigByKey("welcome.video.url") { dict in
      let url = dict["value"] as! String
      DispatchQueue.main.async {
        self.player = AVPlayer(url: URL(string: url)!)
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.videoPlayerView.layer.addSublayer(playerLayer)
        playerLayer.frame = self.videoPlayerView.frame
        self.player?.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil) { notification in
          DispatchQueue.main.async {
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
          }
        }
      }

    }

  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.player?.pause()
    self.player = nil
    NotificationCenter.default.removeObserver(self)
  }
}

// Extension for IB related actions
extension WelcomeViewController {

  func signupButtonTapped() {
    let vc = SignupViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  func loginButtonTapped(){
    let vc = LoginViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }
}


