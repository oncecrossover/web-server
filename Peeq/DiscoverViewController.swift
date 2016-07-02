//
//  DiscoverViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/29/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var discoverTableView: UITableView!
  var uids = [String]()
  var names: [String] = []
  var titles: [String] = []
  var abouts: [String] = []
  var avatarUrls = [String]()

  var userModule = User()
  override func viewDidLoad() {
    super.viewDidLoad()
    loadImages()

    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
//    loadImages()
  }

  func loadImages() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    userModule.getDiscover(uid) { jsonArray in
      for profileInfo in jsonArray as! [[String:AnyObject]] {
        self.uids.append(profileInfo["uid"] as! String)
        self.names.append(profileInfo["fullName"] as! String)

        if let profileTitle = profileInfo["title"] as? String {
          self.titles.append(profileTitle)
        }
        else {
          self.titles.append("")
        }

        if let profileAbout = profileInfo["aboutMe"] as? String {
          self.abouts.append(profileAbout)
        }
        else {
          self.abouts.append("")
        }

        if let profileUrl = profileInfo["avatarUrl"] as? String {
          self.avatarUrls.append(profileUrl)
        }
        else {
          self.avatarUrls.append("")
        }
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.discoverTableView.reloadData()
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return uids.count
  }

  func tappedOnImage(sender:UITapGestureRecognizer){
    self.performSegueWithIdentifier("segueFromDiscoverToAsk", sender: sender)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "segueFromDiscoverToAsk") {
      let dvc = segue.destinationViewController as! AskViewController

      //using sender, we can get the point in respect to the table view
      let tapLocation = sender!.locationInView(self.discoverTableView)

      //using the tapLocation, we retrieve the corresponding indexPath
      let indexPath = self.discoverTableView.indexPathForRowAtPoint(tapLocation)!

//      let indexPath = self.discoverTableView.indexPathForSelectedRow!

      dvc.uid = self.uids[indexPath.row]
      print("uid is : \(dvc.uid)")
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("discoverCell",
      forIndexPath: indexPath) as! DiscoverTableViewCell

    // TODO: Make these calls asynchronous to improve performance
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//      let imageString = self.avatarUrls[indexPath.row]
//      if (!imageString.isEmpty) {
//        let imageUrl = NSURL(string: imageString)
//        let imageData = NSData(contentsOfURL: imageUrl!)
//        dispatch_async(dispatch_get_main_queue()) {
//          if (imageData != nil) {
//            myCell.discoverImageView.image = UIImage(data: imageData!)
//          }
//        }
//      }
//
//      myCell.discoverImageView.layer.cornerRadius = myCell.discoverImageView.frame.size.width / 2
//      myCell.discoverImageView.clipsToBounds = true
//      myCell.discoverImageView.layer.borderColor = UIColor.blackColor().CGColor
//      myCell.discoverImageView.layer.borderWidth = 1
//
//      myCell.discoverImageView.userInteractionEnabled = true
//      let tappedOnImage = UITapGestureRecognizer(target: self, action: "tappedOnImage:")
//      myCell.discoverImageView.addGestureRecognizer(tappedOnImage)
//
//      myCell.name.text = self.names[indexPath.row]
//      myCell.title.text = self.titles[indexPath.row]
//      myCell.about.text = self.abouts[indexPath.row]
//
//      myCell.about.numberOfLines = 0
//      myCell.about.lineBreakMode = NSLineBreakMode.ByWordWrapping
//      myCell.about.sizeToFit()
//      myCell.about.font = myCell.about.font.fontWithSize(12)
//
//      myCell.name.numberOfLines = 1
//      myCell.name.font = UIFont.boldSystemFontOfSize(18)
//      myCell.name.lineBreakMode = NSLineBreakMode.ByCharWrapping
//      myCell.name.sizeToFit()
//      
//      myCell.title.font = myCell.title.font.fontWithSize(15)
//    });

    let imageString = self.avatarUrls[indexPath.row]
    if (!imageString.isEmpty) {
      let imageUrl = NSURL(string: imageString)
      let imageData = NSData(contentsOfURL: imageUrl!)
      if (imageData != nil) {
        myCell.discoverImageView.image = UIImage(data: imageData!)
      }
    }

    myCell.discoverImageView.layer.cornerRadius = myCell.discoverImageView.frame.size.width / 2
    myCell.discoverImageView.clipsToBounds = true
    myCell.discoverImageView.layer.borderColor = UIColor.blackColor().CGColor
    myCell.discoverImageView.layer.borderWidth = 1

    myCell.discoverImageView.userInteractionEnabled = true
    let tappedOnImage = UITapGestureRecognizer(target: self, action: "tappedOnImage:")
    myCell.discoverImageView.addGestureRecognizer(tappedOnImage)

    myCell.name.text = self.names[indexPath.row]
    myCell.title.text = self.titles[indexPath.row]
    myCell.about.text = self.abouts[indexPath.row]

    myCell.about.numberOfLines = 0
    myCell.about.lineBreakMode = NSLineBreakMode.ByWordWrapping
    myCell.about.sizeToFit()
    myCell.about.font = myCell.about.font.fontWithSize(12)

    myCell.name.numberOfLines = 1
    myCell.name.font = UIFont.boldSystemFontOfSize(18)
    myCell.name.lineBreakMode = NSLineBreakMode.ByCharWrapping
    myCell.name.sizeToFit()

    myCell.title.font = myCell.title.font.fontWithSize(15)

    return myCell
  }

}
