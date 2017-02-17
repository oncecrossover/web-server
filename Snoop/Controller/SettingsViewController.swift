//
//  SettingsViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/8/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  var fileName : String?
  var navigationTitle : String?

  let webView: UIWebView = {
    let view = UIWebView()
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    self.navigationController?.navigationItem.title = navigationTitle
    view.addSubview(webView)
    view.addConstraintsWithFormat("H:|[v0]|", views: webView)
    view.addConstraintsWithFormat("V:|[v0]|", views: webView)
    webView.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "html")!)))
  }

}
