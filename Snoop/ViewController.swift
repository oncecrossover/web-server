//
//  ViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/10/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {

  var questionModule = Question()
  var userModule = User()
  var generics = Generics()

  var refreshControl: UIRefreshControl = UIRefreshControl()

  var soundPlayer: AVAudioPlayer!

  var paidSnoops: Set<Int> = []

  var activeCellIndex: Int!

  @IBOutlet weak var feedTable: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var feeds:[FeedsModel] = []
  var tmpFeeds:[FeedsModel] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    feedTable.rowHeight = UITableViewAutomaticDimension
    feedTable.estimatedRowHeight = 130

    refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: .ValueChanged)
    feedTable.addSubview(refreshControl)

    let logo = UIImage(named: "logo")
    let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 130, height: 40))
    logoView.contentMode = .ScaleAspectFit
    logoView.image = logo
    self.navigationItem.titleView = logoView
  }
  
  override func viewDidAppear(animated: Bool) {
    let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
    if (!isUserLoggedIn){
      self.performSegueWithIdentifier("loginView", sender: self)
    }
    else {
      if (feeds.count == 0){
        loadData()
      }
      else {
        if (NSUserDefaults.standardUserDefaults().objectForKey("shouldLoadHome") == nil ||
          NSUserDefaults.standardUserDefaults().boolForKey("shouldLoadHome") == true) {
          NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldLoadHome")
          NSUserDefaults.standardUserDefaults().synchronize()
          loadData()
        }
      }
    }
  }

  func refresh(sender:AnyObject) {
    loadData()
  }

  func loadData(){
    tmpFeeds = []
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let url = "uid='" + uid + "'"
    loadData(url)
  }

  func loadData(url: String!) {
    feedTable.userInteractionEnabled = false
    self.paidSnoops = []
    activityIndicator.startAnimating()
    let encodedUrl = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    let myUrl = NSURL(string: generics.HTTPHOST + "newsfeeds?" + encodedUrl!)
    generics.getFilteredObjects(myUrl!) { jsonArray in
      for feedInfo in jsonArray as! [[String:AnyObject]] {
        let questionId = feedInfo["id"] as! Int
        let question = feedInfo["question"] as! String
        let responderId = feedInfo["responderId"] as! String
        let numberOfSnoops = feedInfo["snoops"] as! Int
        let name = feedInfo["responderName"] as! String
        let updatedTime = feedInfo["updatedTime"] as! Double!

        var title = ""
        if (feedInfo["responderTitle"] != nil) {
          title = feedInfo["responderTitle"] as! String
        }

        var avatarImage = NSData()
        if ((feedInfo["responderAvatarImage"] as? String) != nil) {
          avatarImage = NSData(base64EncodedString: (feedInfo["responderAvatarImage"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
        }

        self.tmpFeeds.append(FeedsModel(_name: name, _title: title, _avatarImage: avatarImage, _id: questionId, _question: question, _status: "ANSWERED", _responderId: responderId, _snoops: numberOfSnoops, _updatedTime: updatedTime))
      }

      self.feeds = self.tmpFeeds
      dispatch_async(dispatch_get_main_queue()) {
        self.activityIndicator.stopAnimating()
        if (jsonArray.count > 0) {
          self.feedTable.reloadData()
        }
        self.feedTable.userInteractionEnabled = true
        self.refreshControl.endRefreshing()
      }
    }
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.feedTable.bounds.size.width,
      self.feedTable.bounds.size.height))
    self.feedTable.backgroundView = nil
    self.feedTable.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

    if (feeds.count == 0) {
      noDataLabel.text = "You have no news feeds yet."
    }
    else {
      return 1
    }

    noDataLabel.textColor = UIColor.grayColor()
    noDataLabel.textAlignment = NSTextAlignment.Center
    self.feedTable.separatorStyle = UITableViewCellSeparatorStyle.None
    self.feedTable.backgroundView = noDataLabel

    return 0
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return feeds.count
  }


  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! FeedTableViewCell
    let feedInfo = feeds[indexPath.row]

    if (feedInfo.avatarImage.length > 0) {
      myCell.profileImage.image = UIImage(data: feedInfo.avatarImage)
    }
    else {
      myCell.profileImage.image = UIImage(named: "default")
    }

    myCell.profileImage.userInteractionEnabled = true
    let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedOnProfile(_:)))
    myCell.profileImage.addGestureRecognizer(tappedOnImage)

    myCell.questionLabel.text = feedInfo.question
    myCell.numOfSnoops.text = String(feedInfo.snoops)

    if (feedInfo.title.isEmpty) {
      myCell.titleLabel.text = feedInfo.name
    }
    else {
      myCell.titleLabel.text = feedInfo.name + " | " + feedInfo.title
    }

    if (feedInfo.status == "PENDING") {
      myCell.snoopImage.userInteractionEnabled = false
      myCell.snoopImage.image = UIImage(named: "pending")
    }
    else {
      if (self.paidSnoops.contains(feedInfo.id)) {
        if (feedInfo.isPlaying == true) {
          myCell.snoopImage.image = UIImage(named: "stop")
        }
        else {
          myCell.snoopImage.image = UIImage(named: "listen")
        }

        myCell.snoopImage.userInteractionEnabled = true
        let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedToListen(_:)))
        myCell.snoopImage.addGestureRecognizer(tappedOnImage)
      }
      else {
        myCell.snoopImage.image = UIImage(named: "snoop")
        myCell.snoopImage.userInteractionEnabled = true
        let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedOnImage(_:)))
        myCell.snoopImage.addGestureRecognizer(tappedOnImage)
      }
    }

    if (indexPath.row == feeds.count - 1) {
      let lastSeenId = feeds[indexPath.row].id
      let updatedTime = Int64(feeds[indexPath.row].updatedTime)
      let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
      let url = "uid='" + uid + "'&lastSeenUpdatedTime=\(updatedTime)&lastSeenId=\(lastSeenId)&limit=5"
      loadData(url)
    }

    return myCell
  }

  func tappedOnProfile(sender:UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.feedTable)
    let indexPath = self.feedTable.indexPathForRowAtPoint(tapLocation)!
    let responderId = self.feeds[indexPath.row].responderId
    self.userModule.getProfile(responderId) {name, title, about, avatarImage, rate in
      let profileInfo:[String:AnyObject] = ["uid": responderId, "name" : name, "title" : title, "about" : about,
        "avatarImage" : avatarImage, "rate" : rate]
      dispatch_async(dispatch_get_main_queue()) {
        self.performSegueWithIdentifier("homeToAsk", sender: profileInfo)
      }
    }
  }

  func tappedToListen(sender:UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.feedTable)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.feedTable.indexPathForRowAtPoint(tapLocation)!
    let questionInfo = feeds[indexPath.row]
    let questionId = questionInfo.id
    if (questionInfo.isPlaying == true) {
      self.soundPlayer.stop()
      questionInfo.isPlaying = false
      self.feedTable.reloadData()
      return
    }

    activeCellIndex = indexPath.row
    questionModule.getQuestionAudio(questionId) { audioString in
      if (!audioString.isEmpty) {
        let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
        dispatch_async(dispatch_get_main_queue()) {
          self.preparePlayer(data)
          questionInfo.isPlaying = true
          self.feedTable.reloadData()
          self.soundPlayer.play()
        }
      }
    }
  }

  func tappedOnImage(sender: UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.feedTable)
    let indexPath = self.feedTable.indexPathForRowAtPoint(tapLocation)!
    self.performSegueWithIdentifier("homeToPayment", sender: indexPath)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "homeToPayment") {
      let indexPath = sender as! NSIndexPath
      let dvc = segue.destinationViewController as! ChargeViewController
      let feed = feeds[indexPath.row]
      dvc.chargeInfo = (amount: 1.50, type: "SNOOPED", quandaId: feed.id)
      dvc.isSnooped = true
    }
    else if (segue.identifier == "homeToAsk") {
      let dvc = segue.destinationViewController as! AskViewController
      let profileInfo = sender as! [String:AnyObject]
      let uid = profileInfo["uid"] as! String
      let name = profileInfo["name"] as! String
      let title = profileInfo["title"] as! String
      let about = profileInfo["about"] as! String
      let avatarImage = profileInfo["avatarImage"] as! NSData
      let rate = profileInfo["rate"] as! Double
      dvc.profileInfo = DiscoverModel(_name: name, _title: title, _avatarImage: avatarImage, _uid: uid, _about: about, _rate: rate, _updatedTime: 0)
    }
  }


  func preparePlayer(data: NSData!) {
    do {
      soundPlayer = try AVAudioPlayer(data: data)
      soundPlayer.delegate = self
      soundPlayer.prepareToPlay()
      soundPlayer.volume = 1.0
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }

  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    feeds[activeCellIndex].isPlaying = false
    feedTable.reloadData()
  }

  @IBAction func unwindSegueToHome(segue: UIStoryboardSegue) {
  }
}

