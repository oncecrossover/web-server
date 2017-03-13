//
//  ViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/10/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {

  var questionModule = Question()
  var userModule = User()
  var generics = Generics()
  var coinModule = Coin()
  var utilityModule = UIUtility()

  var refreshControl: UIRefreshControl = UIRefreshControl()

  var paidSnoops: Set<Int> = []
  var activeIndexPath: NSIndexPath?

  var activePlayerView: VideoPlayerView?

  var coinCount = 0
  lazy var coinView: CoinButtonView = {
    let view = CoinButtonView(frame: CGRect(origin: .zero, size: CGSize(width: 55, height: 20)))
    return view
  }()

  lazy var blackView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.5)
    return view
  }()

  lazy var payWithCoinsView: PayWithCoinsView = {
    let view = PayWithCoinsView()
    view.layer.cornerRadius = 6
    view.clipsToBounds = true
    view.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), forControlEvents: .TouchUpInside)
    view.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), forControlEvents: .TouchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  @IBOutlet weak var feedTable: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var feeds:[FeedsModel] = []
  var tmpFeeds:[FeedsModel] = []

  var fileName = "videoFile.m4a"
  let notificationName = "coinsAdded"

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self) // app might crash without removing observer
  }
}

// Override functions
extension ViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    feedTable.rowHeight = UITableViewAutomaticDimension
    feedTable.estimatedRowHeight = 130

    refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: .ValueChanged)
    feedTable.addSubview(refreshControl)

    let logo = UIImage(named: "logo")
    let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 68, height: 20))
    logoView.contentMode = .ScaleAspectFit
    logoView.image = logo
    self.navigationItem.titleView = logoView

    coinView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coinButtonTapped)))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: coinView)

    // We add the left button only to center the logo view in the nav bar.
    // We need a better solution later one
    let leftButton = UIButton()
    leftButton.frame = CGRect(origin: .zero, size: CGSize(width: 55, height: 20))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.addCoins(_:)), name: self.notificationName, object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    let isUserSignedUp = NSUserDefaults.standardUserDefaults().boolForKey("isUserSignedUp")
    if (!isUserSignedUp) {
      let vc = UINavigationController(rootViewController: WelcomeViewController())
      self.presentViewController(vc, animated: true, completion: nil)
    }

    let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
    if (!isUserLoggedIn){
      let vc = UINavigationController(rootViewController: LoginViewController())
      self.presentViewController(vc, animated: true, completion: nil)
    }
    else {
      if (feeds.count == 0){
        loadData()
        loadCoinCount()
      }
      else {
        if (NSUserDefaults.standardUserDefaults().objectForKey("shouldLoadHome") == nil ||
          NSUserDefaults.standardUserDefaults().boolForKey("shouldLoadHome") == true) {
          NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldLoadHome")
          NSUserDefaults.standardUserDefaults().synchronize()
          loadData()
          loadCoinCount()
        }
      }
    }
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    activePlayerView?.closeView()
  }
}

// Private function
extension ViewController {

  func loadCoinCount() {
    coinModule.getCoinsCount() { result in
      let coinCount = result["amount"] as! Int
      self.coinCount = coinCount
      dispatch_async(dispatch_get_main_queue()) {
        self.loadCoinCount(coinCount)
      }
    }
  }

  func loadCoinCount(count: Int) {
    self.coinView.setCount(count)
  }

  func addCoins(notification: NSNotification) {
    if let uid = notification.userInfo?["uid"] as? String {
      let currentUid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
      // Check if these two are the same user if app relaunches or user signs out.
      if (currentUid == uid) {
        if let amount = notification.userInfo?["amount"] as? Int {
          self.coinCount += amount
          loadCoinCount(coinCount)
        }
      }
    }
  }

  func refresh(sender:AnyObject) {
    loadData()
  }

  func loadData(){
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let url = "uid='" + uid + "'"
    tmpFeeds = []
    self.paidSnoops = []
    loadData(url)
  }

  func loadData(url: String!) {
    feedTable.userInteractionEnabled = false
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

        let avatarImageUrl = feedInfo["responderAvatarUrl"] as? String
        let coverUrl = feedInfo["answerCoverUrl"] as? String
        let answerUrl = feedInfo["answerUrl"] as? String

        let duration = feedInfo["duration"] as! Int
        let rate = feedInfo["rate"] as! Int
        self.tmpFeeds.append(FeedsModel(_name: name, _title: title, _id: questionId, _question: question, _status: "ANSWERED", _responderId: responderId, _snoops: numberOfSnoops, _updatedTime: updatedTime,  _duration: duration, _avatarImageUrl: avatarImageUrl, _coverUrl: coverUrl, _answerUrl: answerUrl, _rate: rate))
      }

      self.feeds = self.tmpFeeds
      dispatch_async(dispatch_get_main_queue()) {
        self.activityIndicator.stopAnimating()
        // reload table only if there is additonal data or when we are loading the first batch
        if (jsonArray.count > 0 || !String(myUrl).containsString("lastSeenId")) {
          self.feedTable.reloadData()
        }
        self.feedTable.userInteractionEnabled = true
        self.refreshControl.endRefreshing()
      }
    }
  }

  func setPlaceholderImages(myCell: FeedTableViewCell) {
    myCell.profileImage.userInteractionEnabled = false
    myCell.coverImage.userInteractionEnabled = false
    myCell.profileImage.image = UIImage(named: "default")
    myCell.coverImage.image = UIImage()
  }

  func getCacheDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    return paths[0]
  }

  func getFileUrl() -> NSURL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.stringByAppendingPathComponent(fileName)
    return NSURL(fileURLWithPath: path)
  }

}

// Delegate methods
extension ViewController : UITableViewDataSource, UITableViewDelegate {

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
    myCell.userInteractionEnabled = false

    let feedInfo = feeds[indexPath.row]
    myCell.nameLabel.text = feedInfo.name


    myCell.questionLabel.text = feedInfo.question
    myCell.numOfSnoops.text = String(feedInfo.snoops)

    if (feedInfo.title.isEmpty) {
      myCell.titleLabel.text = ""
    }
    else {
      myCell.titleLabel.text = feedInfo.title
    }

    // setup rate label
    if (self.paidSnoops.contains(feedInfo.id)) {
      myCell.rateLabel.text = nil
      myCell.rateLabel.backgroundColor = UIColor(patternImage: UIImage(named: "unlocked")!)
    }
    else {
      if (feedInfo.rate > 0) {
        myCell.rateLabel.backgroundColor = UIColor(red: 255/255, green: 183/255, blue: 78/255, alpha: 0.8)
        myCell.rateLabel.text = "$1.5"
      }
      else {
        myCell.rateLabel.backgroundColor = UIColor.defaultColor()
        myCell.rateLabel.text = "Free"
      }
    }

    setPlaceholderImages(myCell)
    if (feedInfo.status == "PENDING") {
      myCell.coverImage.userInteractionEnabled = false
      myCell.coverImage.image = UIImage()
    }
    else {
      if let coverUrl = feedInfo.coverUrl {
        myCell.coverImage.sd_setImageWithURL(NSURL(string: coverUrl))
      }
      myCell.coverImage.userInteractionEnabled = true
      myCell.durationLabel.text = "00:\(feedInfo.duration)"
      myCell.durationLabel.hidden = false

      if (self.paidSnoops.contains(feedInfo.id)) {
        let tappedToWatch = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedToWatch(_:)))
        myCell.coverImage.addGestureRecognizer(tappedToWatch)
      }
      else {
        let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedOnImage(_:)))
        myCell.coverImage.addGestureRecognizer(tappedOnImage)
      }
    }

    // set profile image
    if let profileUrl = feedInfo.avatarImageUrl {
      myCell.profileImage.sd_setImageWithURL(NSURL(string: profileUrl))
    }

    myCell.profileImage.userInteractionEnabled = true
    let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedOnProfile(_:)))
    myCell.profileImage.addGestureRecognizer(tappedOnImage)

    myCell.userInteractionEnabled = true

    if (indexPath.row == feeds.count - 1) {
      let lastSeenId = feeds[indexPath.row].id
      let updatedTime = Int64(feeds[indexPath.row].updatedTime)
      let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
      let url = "uid='" + uid + "'&lastSeenUpdatedTime=\(updatedTime)&lastSeenId=\(lastSeenId)&limit=5"
      loadData(url)
    }

    return myCell
  }
}

// Segue action
extension ViewController {

  func coinButtonTapped() {
    let vc = CoinsViewController()
    vc.numOfCoins = self.coinCount
    vc.homeViewController = self
    self.presentViewController(vc, animated: true, completion: nil)
  }

  func confirmButtonTapped() {
    UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
    }) { (result) in
      let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
      let quandaId = self.feeds[self.activeIndexPath!.row].id
      let quandaData: [String:AnyObject] = ["id": quandaId]
      let jsonData: [String:AnyObject] = ["uid": uid, "type": "SNOOPED", "quanda": quandaData]
      self.generics.createObject(self.generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
        if (result.isEmpty) {
          dispatch_async(dispatch_get_main_queue()) {
            self.paidSnoops.insert(quandaId)
            self.feedTable.reloadRowsAtIndexPaths([self.activeIndexPath!], withRowAnimation: .None)
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()) {
            self.utilityModule.displayAlertMessage("there is an error processing your payment. Please try later", title: "Error", sender: self)
          }
        }
      }
    }
  }

  func cancelButtonTapped() {
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
      }, completion: nil)
  }

  func tappedOnProfile(sender:UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.feedTable)
    let indexPath = self.feedTable.indexPathForRowAtPoint(tapLocation)!
    let responderId = self.feeds[indexPath.row].responderId
    self.userModule.getProfile(responderId) {name, title, about, avatarUrl, rate, _ in
      let discoverModel = DiscoverModel(_name: name, _title: title, _uid: responderId, _about: about, _rate: rate, _updatedTime: 0, _avatarUrl: avatarUrl)
      dispatch_async(dispatch_get_main_queue()) {
        self.performSegueWithIdentifier("homeToAsk", sender: discoverModel)
      }
    }
  }

  func tappedToWatch(sender:UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.feedTable)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.feedTable.indexPathForRowAtPoint(tapLocation)!

    let videoPlayerView = VideoPlayerView()
    let bounds = UIScreen.mainScreen().bounds

    let oldFrame = CGRect(x: 0, y: bounds.size.height, width: bounds.size.width, height: 0)
    videoPlayerView.frame = oldFrame
    let newFrame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
    self.tabBarController?.view.addSubview(videoPlayerView)
    activePlayerView = videoPlayerView
    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
      videoPlayerView.frame = newFrame
      videoPlayerView.setupLoadingControls()
      }, completion: nil)

    let questionInfo = feeds[indexPath.row]
    let answerUrl = questionInfo.answerUrl!

    let player = AVPlayer(URL: NSURL(string: answerUrl)!)
    videoPlayerView.player = player
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    videoPlayerView.layer.addSublayer(playerLayer)
    playerLayer.frame = videoPlayerView.frame
    videoPlayerView.setupPlayingControls()
    let duration = questionInfo.duration
    let secondsText = String(format: "%02d", duration % 60)
    let minutesText = String(format: "%02d", duration / 60)
    videoPlayerView.lengthLabel.text = "\(minutesText):\(secondsText)"
    videoPlayerView.setupProgressControls()

    player.play()
    NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
      // block base observer has retain cycle issue, remember to unregister observer in deinit
      videoPlayerView.reset()
    }
  }

  func tappedOnImage(sender: UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.feedTable)
    let indexPath = self.feedTable.indexPathForRowAtPoint(tapLocation)!
    self.activeIndexPath = indexPath
    if let window = UIApplication.sharedApplication().keyWindow {
      window.addSubview(blackView)
      blackView.frame = window.frame
      window.addSubview(payWithCoinsView)
      payWithCoinsView.centerXAnchor.constraintEqualToAnchor(window.centerXAnchor).active = true
      payWithCoinsView.centerYAnchor.constraintEqualToAnchor(window.centerYAnchor).active = true
      payWithCoinsView.widthAnchor.constraintEqualToConstant(260).active = true
      payWithCoinsView.heightAnchor.constraintEqualToConstant(176).active = true
      blackView.alpha = 0
      payWithCoinsView.alpha = 0
      UIView.animateWithDuration(0.5) {
        self.blackView.alpha = 1
        self.payWithCoinsView.alpha = 1
      }
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "homeToAsk") {
      let dvc = segue.destinationViewController as! AskViewController
      let profileInfo = sender as! DiscoverModel
      dvc.profileInfo = profileInfo
    }
  }

  @IBAction func unwindSegueToHome(segue: UIStoryboardSegue) {
  }
}


