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
  @IBOutlet weak var imageView: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()

    imageView.image = UIImage(named: imageName)
  }

}
