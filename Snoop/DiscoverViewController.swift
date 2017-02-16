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

  var profiles: [DiscoverModel] = []
  var filteredProfiles: [DiscoverModel] = []
  var tmpProfiles: [DiscoverModel] = []

  var refreshControl: UIRefreshControl = UIRefreshControl()

  let searchController = UISearchController(searchResultsController: nil)

  var userModule = User()
  var questionModule = Question()
  override func viewDidLoad() {
    super.viewDidLoad()

    discoverTableView.rowHeight = UITableViewAutomaticDimension
    discoverTableView.estimatedRowHeight = 80
    discoverTableView.tableFooterView = UIView()

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
      loadProfiles()
    }
    else {
      if (NSUserDefaults.standardUserDefaults().objectForKey("shouldLoadDiscover") == nil ||
        NSUserDefaults.standardUserDefaults().boolForKey("shouldLoadDiscover") == true) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldLoadDiscover")
        NSUserDefaults.standardUserDefaults().synchronize()
        loadProfiles()
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
    loadProfiles()
  }

  func loadProfiles() {
    discoverTableView.userInteractionEnabled = false
    tmpProfiles = []
    let url = "takeQuestion='APPROVED'&limit=10"
    loadProfiles(url)
  }

  func loadProfiles(url: String!) {
    let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)

    indicator.startAnimating()
    indicator.backgroundColor = UIColor.whiteColor()
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    var didLoadNewProfiles = false
    userModule.getDiscover(url) { jsonArray in
      for profileInfo in jsonArray as! [[String:AnyObject]] {
        let profileUid = profileInfo["uid"] as! String
        if (profileUid == uid) {
          continue
        }
        let profileName = profileInfo["fullName"] as! String
        let updatedTime = profileInfo["updatedTime"] as! Double!
        var profileTitle = ""
        var profileAbout = ""
        var rate = 0.0

        if profileInfo["title"] as? String != nil {
          profileTitle = profileInfo["title"] as! String
        }

        if profileInfo["aboutMe"] as? String != nil {
          profileAbout = profileInfo["aboutMe"] as! String
        }

        if profileInfo["rate"] as? Double != nil {
          rate = profileInfo["rate"] as! Double
        }

        let avatarUrl = profileInfo["avatarUrl"] as? String

        self.tmpProfiles.append(DiscoverModel(_name: profileName, _title: profileTitle, _avatarImage: nil, _uid: profileUid, _about: profileAbout, _rate: rate, _updatedTime: updatedTime, _avatarUrl: avatarUrl))
        didLoadNewProfiles = true
      }
      self.profiles = self.tmpProfiles

      dispatch_async(dispatch_get_main_queue()) {
        if (didLoadNewProfiles || !String(url).containsString("lastSeenId")) {
          self.discoverTableView.reloadData()
        }
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        self.discoverTableView.userInteractionEnabled = true
        self.refreshControl.endRefreshing()
      }
    }

  }

  func loadImageAsync(cellInfo: DiscoverModel, completion: (DiscoverModel) -> ()) {
    if let avatarUrl = cellInfo.avatarUrl {
      cellInfo.avatarImage = NSData(contentsOfURL: NSURL(string: avatarUrl)!)
    }
    else {
      cellInfo.avatarImage = NSData()
    }
    completion(cellInfo)
  }

  func setImage(myCell: DiscoverTableViewCell, cellInfo: DiscoverModel) {
    if (cellInfo.avatarImage!.length > 0) {
      myCell.discoverImageView.image = UIImage(data: cellInfo.avatarImage!)
    }
    else {
      myCell.discoverImageView.image = UIImage(named: "default")
    }
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
    myCell.userInteractionEnabled = false
    let cellInfo: DiscoverModel
    if (searchController.active && searchController.searchBar.text != "") {
      cellInfo = self.filteredProfiles[indexPath.row]
    }
    else {
      cellInfo = self.profiles[indexPath.row]
    }


    myCell.name.text = cellInfo.name
    myCell.title.text = cellInfo.title
    myCell.about.text = cellInfo.about

    if let avatarUrl = cellInfo.avatarUrl {
      myCell.discoverImageView.sd_setImageWithURL(NSURL(string: avatarUrl))
    }
    else {
      myCell.discoverImageView.image = UIImage(named: "default")
    }

    if (!searchController.active && searchController.searchBar.text == "") {
      if (indexPath.row == profiles.count - 1) {
        let updatedTime = Int64(cellInfo.updatedTime)
        let lastSeenId = cellInfo.uid
        let url = "takeQuestion='APPROVED'&limit=10&lastSeenUpdatedTime=\(updatedTime)&lastSeenId='" + lastSeenId + "'"
        loadProfiles(url)
      }
    }
    return myCell

  }

}


extension DiscoverViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
}
