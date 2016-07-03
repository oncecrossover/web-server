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

  var profiles: [(uid: String!, name: String!, title: String!, about: String!, avatarUrl:String!)] = []
  var filteredProfiles: [(uid: String!, name: String!, title: String!, about: String!, avatarUrl:String!)] = []

  let searchController = UISearchController(searchResultsController: nil)

  var userModule = User()
  override func viewDidLoad() {
    super.viewDidLoad()
    loadImages()

    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    discoverTableView.tableHeaderView = searchController.searchBar

    // Do any additional setup after loading the view.
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.navigationItem.title = "Discover"
  }


  func filterContentForSearchText(searchText: String, scope: String = "All") {
    filteredProfiles = profiles.filter { profile in
      return profile.name.lowercaseString.containsString(searchText.lowercaseString)
    }
    self.discoverTableView.reloadData()

  }

  func loadImages() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    activityIndicator.startAnimating()
    userModule.getDiscover(uid, filterString: "*") { jsonArray in
      for profileInfo in jsonArray as! [[String:AnyObject]] {
        let profileUid = profileInfo["uid"] as! String
        let profileName = profileInfo["fullName"] as! String
        var profileTitle = ""
        var profileAbout = ""
        var profileUrl = ""

        if profileInfo["title"] as? String != nil {
          profileTitle = profileInfo["title"] as! String
        }

        if profileInfo["aboutMe"] as? String != nil {
          profileAbout = profileInfo["aboutMe"] as! String
        }

        if profileInfo["avatarUrl"] as? String  != nil {
          profileUrl = profileInfo["avatarUrl"] as! String
        }

        self.profiles.append((uid: profileUid, name: profileName, title: profileTitle, about: profileAbout, avatarUrl: profileUrl))
      }

      self.activityIndicator.stopAnimating()

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
    if (searchController.active && searchController.searchBar.text != "") {
      return filteredProfiles.count
    }
    return profiles.count
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

      if (searchController.active && searchController.searchBar.text != "") {
        dvc.profileInfo = self.filteredProfiles[indexPath.row]
      }
      else {
        dvc.profileInfo = self.profiles[indexPath.row]
      }
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


    let profile: (uid: String!, name: String!, title: String!, about: String!, avatarUrl:String!)
    if (searchController.active && searchController.searchBar.text != "") {
      profile = self.filteredProfiles[indexPath.row]
    }
    else {
      profile = self.profiles[indexPath.row]
    }

    let imageString = profile.avatarUrl
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

    myCell.name.text = profile.name
    myCell.title.text = profile.title
    myCell.about.text = profile.about

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


extension DiscoverViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}
