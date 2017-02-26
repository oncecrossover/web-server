//
//  ContentViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/8/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

  var pageIndex:Int!
  var imageName:String!

  lazy var imageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .ScaleAspectFit
    view.image = UIImage(named: self.imageName)
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(imageView)
    view.addConstraintsWithFormat("H:|-4-[v0]-4-|", views: imageView)
    view.addConstraintsWithFormat("V:|-4-[v0]-4-|", views: imageView)
  }

}
