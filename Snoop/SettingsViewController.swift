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

  @IBOutlet weak var webView: UIWebView!
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = navigationTitle
    webView.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "html")!)))
  }

}
