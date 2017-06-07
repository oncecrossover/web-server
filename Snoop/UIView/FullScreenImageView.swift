//
//  FullScreenImageView.swift
//  Snoop
//
//  Created by Xiaobing Zhou on 6/6/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
/**
 * This class is a reusable UIView to show image in full screen.
 */
class FullScreenImageView : UIView {

  /**
   * this blackView is used to mask any current active
   * view to black to simulate black full screen.
   */
  lazy var blackView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 1)
    return view
  }()

  /* the specific image will be shown in full screen in this imageView */
  lazy var imageView : UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    view.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage))
    view.addGestureRecognizer(tap)
    return view;
  }()

  /* a function to restore full screen to previous orginal view */
  func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.imageView.alpha = 0
    }, completion: nil)
  }

  /* do full screen rendering */
  func imageTapped(_ sender: UITapGestureRecognizer) {
    if let window = UIApplication.shared.keyWindow {
      /* setup blackView */
      window.addSubview(blackView)
      blackView.frame = window.frame

      /* setup imageView */
      let circleImageView = sender.view as! UIImageView
      self.imageView.image = circleImageView.image;
      window.addSubview(self.imageView)
      self.imageView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
      self.imageView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
      self.imageView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
      self.imageView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true

      /* animate imageView in full screen */
      self.blackView.alpha = 0
      self.imageView.alpha = 0;
      UIView.animate(withDuration: 0.5, animations: {
        self.blackView.alpha = 1
        self.imageView.alpha = 1
      })
    }
  }
}
