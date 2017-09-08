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

    refreshControl.addTarget(self, action: #selector(DiscoverViewController.refresh(_:)), for: .valueChanged)
    discoverTableView.addSubview(refreshControl)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if (profiles.count == 0) {
      loadProfiles()
    }
    else {
      if (UserDefaults.standard.object(forKey: "shouldLoadDiscover") == nil ||
        UserDefaults.standard.bool(forKey: "shouldLoadDiscover") == true) {
        UserDefaults.standard.set(false, forKey: "shouldLoadDiscover")
        UserDefaults.standard.synchronize()
        loadProfiles()
      }
    }
  }

  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    /* remove whitespaces from both ends, otherwise cause URL.init failure */
    let trimmedSearchText = searchText.trimmingCharacters(in: CharacterSet.whitespaces)
    tmpProfiles = []
    let url = "takeQuestion='APPROVED'&limit=10&fullName='%25\(trimmedSearchText.lowercased())%25'"
    loadProfiles(url, isSearch: true)
  }

  func refresh(_ sender:AnyObject) {
    loadProfiles()
  }

  func loadProfiles() {
    discoverTableView.isUserInteractionEnabled = false
    tmpProfiles = []
    let url = "takeQuestion='APPROVED'&limit=10"
    loadProfiles(url, isSearch: false)
  }

  func loadProfiles(_ url: String!, isSearch: Bool) {
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)

    indicator.startAnimating()
    indicator.backgroundColor = UIColor.white
    let uid = UserDefaults.standard.string(forKey: "uid")
    var didLoadNewProfiles = false
    userModule.getDiscover(url) { jsonArray in
      for profileInfo in jsonArray as! [[String:AnyObject]] {
        let profileUid = profileInfo["id"] as! String
        if (profileUid == uid) {
          continue
        }
        let profileName = profileInfo["fullName"] as! String
        let updatedTime = profileInfo["updatedTime"] as! Double
        var profileTitle = ""
        var profileAbout = ""
        var rate = 0

        if profileInfo["title"] as? String != nil {
          profileTitle = profileInfo["title"] as! String
        }

        if profileInfo["aboutMe"] as? String != nil {
          profileAbout = profileInfo["aboutMe"] as! String
        }

        if profileInfo["rate"] as? Int != nil {
          rate = profileInfo["rate"] as! Int
        }

        let avatarUrl = profileInfo["avatarUrl"] as? String

        self.tmpProfiles.append(DiscoverModel(_name: profileName, _title: profileTitle, _uid: profileUid, _about: profileAbout, _rate: rate, _updatedTime: updatedTime, _avatarUrl: avatarUrl))
        didLoadNewProfiles = true
      }
      if (isSearch) {
        self.filteredProfiles = self.tmpProfiles
      }
      else {
        self.profiles = self.tmpProfiles
      }

      DispatchQueue.main.async {
        if (didLoadNewProfiles || !String(url).contains("lastSeenId")) {
          self.discoverTableView.reloadData()
        }
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        self.discoverTableView.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()
      }
    }

  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (searchController.isActive && searchController.searchBar.text != "") {
      return filteredProfiles.count
    }
    return profiles.count
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "segueFromDiscoverToAsk") {
      let dvc = segue.destination as! AskViewController

      let indexPath = self.discoverTableView.indexPathForSelectedRow!

      if (searchController.isActive && searchController.searchBar.text != "") {
        dvc.profileInfo = self.filteredProfiles[indexPath.row]
      }
      else {
        dvc.profileInfo = self.profiles[indexPath.row]
      }
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.performSegue(withIdentifier: "segueFromDiscoverToAsk", sender: self)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCell(withIdentifier: "discoverCell",
                                                             for: indexPath) as! DiscoverTableViewCell
    myCell.isUserInteractionEnabled = false
    let cellInfo: DiscoverModel
    if (searchController.isActive && searchController.searchBar.text != "") {
      cellInfo = self.filteredProfiles[indexPath.row]
    }
    else {
      cellInfo = self.profiles[indexPath.row]
    }


    myCell.name.text = cellInfo.name
    myCell.title.text = cellInfo.title

    if let avatarUrl = cellInfo.avatarUrl {
      myCell.discoverImageView.sd_setImage(with: URL(string: avatarUrl))
    }
    else {
      myCell.discoverImageView.cosmeticizeImage(cosmeticHints: cellInfo.name)
    }

    myCell.isUserInteractionEnabled = true

    if (!searchController.isActive && searchController.searchBar.text == "") {
      if (indexPath.row == profiles.count - 1) {
        let updatedTime = Int64(cellInfo.updatedTime)
        let lastSeenId = cellInfo.uid
        let url = "takeQuestion='APPROVED'&limit=10&lastSeenUpdatedTime=\(updatedTime)&lastSeenId=" + "\(lastSeenId)"
        loadProfiles(url, isSearch: false)
      }
    }
    else {
      if (indexPath.row == filteredProfiles.count - 1) {
        let updatedTime = Int64(cellInfo.updatedTime)
        let lastSeenId = cellInfo.uid
        let url = "takeQuestion='APPROVED'&limit=10&lastSeenUpdatedTime=\(updatedTime)&lastSeenId=" + "\(lastSeenId)" + "&fullName='%25\(getUrlQualifiedSearchText())%25'"
        loadProfiles(url, isSearch: true)
      }
    }
    return myCell

  }

}


extension DiscoverViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(getUrlQualifiedSearchText())
  }

  func getUrlQualifiedSearchText() -> String {
    /* remove whitespaces from both ends, otherwise cause URL.init failure */
    return searchController.searchBar.text!.trimmingCharacters(in: .whitespaces)
  }
}
