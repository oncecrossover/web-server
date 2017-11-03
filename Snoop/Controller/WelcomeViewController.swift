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
  var isMuted = true
  lazy var signupButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.backgroundColor = UIColor.defaultColor()
    button.setTitle("Sign Up", for: UIControlState())
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)

    button.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var loginButton: UIButton = {
    let button = UIButton()
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.white.cgColor
    button.setTitle("Log In", for: UIControlState())
    button.setTitleColor(UIColor.defaultColor(), for: UIControlState())
    button.backgroundColor = UIColor.white
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)

    button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  lazy var unmuteButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "unmute"), for: .normal)
    button.addTarget(self, action: #selector(unmuteButtonTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  let questionLabel: UILabel = {
    let questionLabel = UILabel()
    questionLabel.textAlignment = .center
    questionLabel.layer.cornerRadius = 10
    questionLabel.clipsToBounds = true
    questionLabel.textColor = UIColor(white: 0, alpha: 0.7)
    questionLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
    questionLabel.text = "What is vInsider? Why did we build it?"
    questionLabel.font = UIFont.systemFont(ofSize: 16)
    questionLabel.numberOfLines = 0
    questionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
    questionLabel.translatesAutoresizingMaskIntoConstraints = false
    return questionLabel
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    view.backgroundColor = UIColor.white
    view.addSubview(videoPlayerView)
    view.addSubview(questionLabel)
    view.addSubview(signupButton)
    view.addSubview(loginButton)
    view.addSubview(unmuteButton)

    view.addConstraintsWithFormat("H:|[v0]|", views: videoPlayerView)
    view.addConstraintsWithFormat("V:|[v0]|", views: videoPlayerView)

    // Setup buttons
    signupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
    signupButton.heightAnchor.constraint(equalToConstant: 47).isActive = true
    signupButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -12).isActive = true
    signupButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
    loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
    loginButton.heightAnchor.constraint(equalTo: signupButton.heightAnchor).isActive = true
    loginButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 12).isActive = true
    loginButton.bottomAnchor.constraint(equalTo: signupButton.bottomAnchor).isActive = true

    unmuteButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
    unmuteButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
    unmuteButton.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor).isActive = true
    unmuteButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 67).isActive = true

    /* setup question label */
    questionLabel.leadingAnchor.constraint(equalTo: signupButton.leadingAnchor).isActive = true
    questionLabel.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor).isActive = true
    questionLabel.heightAnchor.constraint(equalToConstant: 72).isActive = true;
    questionLabel.bottomAnchor.constraint(equalTo: signupButton.topAnchor, constant: -25).isActive = true

    NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { (_) in
      self.player?.pause()
    }

    NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { (_) in
      self.player?.play()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Config().getConfigByKey("welcome.video.url") { dict in
      let url = dict["value"] as! String
      DispatchQueue.main.async {
        self.player = AVPlayer(url: URL(string: url)!)
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPlayerView.layer.addSublayer(playerLayer)
        playerLayer.frame = self.videoPlayerView.frame
        self.player?.volume = 0
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

  @objc func unmuteButtonTapped() {
    if (isMuted) {
      isMuted = false
      self.player?.volume = 1.0
      self.unmuteButton.setImage(UIImage(named: "mute"), for: .normal)
    }
    else {
      isMuted = true
      self.player?.volume = 0
      self.unmuteButton.setImage(UIImage(named: "unmute"), for: .normal)
    }
  }

  @objc func signupButtonTapped() {
    UserDefaults.standard.set(true, forKey: "isUserWelcomed")
    UserDefaults.standard.synchronize()
    let vc = SignupViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @objc func loginButtonTapped(){
    UserDefaults.standard.set(true, forKey: "isUserWelcomed")
    UserDefaults.standard.synchronize()
    let vc = LoginViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }
}


