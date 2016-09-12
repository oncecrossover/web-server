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
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var profiles: [DiscoverModel] = []
  var filteredProfiles: [DiscoverModel] = []

  var refreshControl: UIRefreshControl = UIRefreshControl()

  let searchController = UISearchController(searchResultsController: nil)

  var userModule = User()
  override func viewDidLoad() {
    super.viewDidLoad()

    discoverTableView.rowHeight = UITableViewAutomaticDimension
    discoverTableView.estimatedRowHeight = 80

    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    discoverTableView.tableHeaderView = searchController.searchBar
    self.definesPresentationContext = true

    refreshControl.addTarget(self, action: #selector(DiscoverViewController.refresh(_:)), forControlEvents: .ValueChanged)
    discoverTableView.addSubview(refreshControl)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if (profiles.count == 0) {
      loadImages()
    }
    else {
      let shouldLoadDiscover = NSUserDefaults.standardUserDefaults().boolForKey("shouldLoadDiscover")
      if (shouldLoadDiscover) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldLoadDiscover")
        NSUserDefaults.standardUserDefaults().synchronize()
        loadImages()
      }
    }
  }

  func filterContentForSearchText(searchText: String, scope: String = "All") {
    filteredProfiles = profiles.filter { profile in
      return profile.name.lowercaseString.containsString(searchText.lowercaseString)
    }
    self.discoverTableView.reloadData()

  }

  func refresh(sender:AnyObject) {
    loadImages()
    refreshControl.endRefreshing()
  }

  func loadImages() {
    discoverTableView.userInteractionEnabled = false
    profiles = []
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    activityIndicator.startAnimating()
    userModule.getDiscover(uid, filterString: "*") { jsonArray in
      for profileInfo in jsonArray as! [[String:AnyObject]] {
        let profileUid = profileInfo["uid"] as! String
        if (profileUid == uid) {
          continue
        }
        let profileName = profileInfo["fullName"] as! String
        var profileTitle = ""
        var profileAbout = ""
        var rate = 0.0
        var avatarImage = NSData()

        if profileInfo["title"] as? String != nil {
          profileTitle = profileInfo["title"] as! String
        }

        if profileInfo["aboutMe"] as? String != nil {
          profileAbout = profileInfo["aboutMe"] as! String
        }

        if profileInfo["rate"] as? Double != nil {
          rate = profileInfo["rate"] as! Double
        }

        if profileInfo["avatarImage"] as? String != nil {
          avatarImage = NSData(base64EncodedString: profileInfo["avatarImage"] as! String, options: NSDataBase64DecodingOptions(rawValue: 0))!
        }

        self.profiles.append(DiscoverModel(_name: profileName, _title: profileTitle, _avatarImage: avatarImage, _uid: profileUid, _about: profileAbout, _rate: rate))
      }

      self.activityIndicator.stopAnimating()

      dispatch_async(dispatch_get_main_queue()) {
        self.discoverTableView.reloadData()
        self.discoverTableView.userInteractionEnabled = true
      }

    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (searchController.active && searchController.searchBar.text != "") {
      return filteredProfiles.count
    }
    return profiles.count
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "segueFromDiscoverToAsk") {
      let dvc = segue.destinationViewController as! AskViewController

      let indexPath = self.discoverTableView.indexPathForSelectedRow!

      if (searchController.active && searchController.searchBar.text != "") {
        dvc.profileInfo = self.filteredProfiles[indexPath.row]
      }
      else {
        dvc.profileInfo = self.profiles[indexPath.row]
      }
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier("segueFromDiscoverToAsk", sender: self)
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


    let profile: DiscoverModel
    if (searchController.active && searchController.searchBar.text != "") {
      profile = self.filteredProfiles[indexPath.row]
    }
    else {
      profile = self.profiles[indexPath.row]
    }

    if (profile.avatarImage.length > 0) {
      myCell.discoverImageView.image = UIImage(data: profile.avatarImage)
    }
    else {
      myCell.discoverImageView.image = UIImage(named: "default")
    }

    myCell.name.text = profile.name
    myCell.title.text = profile.title
    myCell.about.text = profile.about

    return myCell
  }

}


extension DiscoverViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}
