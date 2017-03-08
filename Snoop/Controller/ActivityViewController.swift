//
//  ActivityViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ActivityViewController: UIViewController {

  @IBOutlet weak var activityTableView: UITableView!

  @IBOutlet weak var segmentedControl: UIView!
  var userModule = User()
  var questionModule = Question()
  var utility = UIUtility()
  var generics = Generics()

  var questions: [ActivityModel] = []
  var answers: [ActivityModel] = []
  var snoops: [ActivityModel] = []

  var tmpQuestions: [ActivityModel] = []
  var tmpAnswers: [ActivityModel] = []
  var tmpSnoops: [ActivityModel] = []

  var refreshControl: UIRefreshControl = UIRefreshControl()

  var activePlayerView : VideoPlayerView?

  var selectedIndex = 0

  lazy var controlBar: CustomSegmentedControl = {
    let frame = self.segmentedControl.frame
    let control = CustomSegmentedControl(frame: frame)
    control.translatesAutoresizingMaskIntoConstraints = false
    return control
  }()

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self) // app might crash without removing observer
  }
}

// override function
extension ActivityViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    activityTableView.rowHeight = UITableViewAutomaticDimension
    activityTableView.estimatedRowHeight = 230
    activityTableView.tableHeaderView = UIView()
    activityTableView.tableFooterView = UIView()

    refreshControl.addTarget(self, action: #selector(ActivityViewController.refresh(_:)), forControlEvents: .ValueChanged)
    activityTableView.addSubview(refreshControl)
    controlBar.delegate = self

    setupSegmentedControl()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadIndex(selectedIndex)
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    activePlayerView?.closeView()
  }
}

//segmentedControlDelegate
extension ActivityViewController: SegmentedControlDelegate {
  func loadIndex(index: Int) {
    selectedIndex = index
    if (index == 0) {
      if (NSUserDefaults.standardUserDefaults().objectForKey("shouldLoadQuestions") == nil
        || NSUserDefaults.standardUserDefaults().boolForKey("shouldLoadQuestions") == true) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldLoadQuestions")
        NSUserDefaults.standardUserDefaults().synchronize()
        loadIndexWithRefresh(index)
      }
      else {
        if (tmpQuestions.count == 0) {
          loadIndexWithRefresh(index)
        }
        else {
          activityTableView.reloadData()
        }
      }
    }
    else if (index == 1) {
      if (NSUserDefaults.standardUserDefaults().objectForKey("shouldLoadAnswers") == nil
        || NSUserDefaults.standardUserDefaults().boolForKey("shouldLoadAnswers") == true) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldLoadAnswers")
        NSUserDefaults.standardUserDefaults().synchronize()
        loadIndexWithRefresh(index)
      }
      else {
        if (tmpAnswers.count == 0) {
          loadIndexWithRefresh(index)
        }
        else {
          activityTableView.reloadData()
        }
      }
    }
    else {
      if (NSUserDefaults.standardUserDefaults().objectForKey("shouldLoadSnoops") == nil
        || NSUserDefaults.standardUserDefaults().boolForKey("shouldLoadSnoops") == true) {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "shouldLoadSnoops")
        NSUserDefaults.standardUserDefaults().synchronize()
        loadIndexWithRefresh(index)
      }
      else {
        if (tmpSnoops.count == 0) {
          loadIndexWithRefresh(2)
        }
        else {
          activityTableView.reloadData()
        }
      }
    }
  }

  func loadIndexWithRefresh(index: Int) {
    activityTableView.userInteractionEnabled = false
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    if (index == 0) {
      tmpQuestions = []
      loadDataWithFilter("asker='" + uid + "'")
    }
    else if (index == 1) {
      tmpAnswers = []
      loadDataWithFilter("responder='" + uid + "'")
    }
    else if (index == 2) {
      tmpSnoops = []
      loadDataWithFilter("uid='" + uid + "'")
    }
  }
}

// Private function
extension ActivityViewController {

  func refresh(sender: AnyObject) {
    activePlayerView?.closeView()
    loadIndexWithRefresh(selectedIndex)
  }

  func setupSegmentedControl() {
    self.segmentedControl.hidden = true
    view.addSubview(controlBar)

    // set up constraint
    let navigationBarHeight = self.navigationController?.navigationBar.frame.height
    let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
    let topMargin = navigationBarHeight! + statusBarHeight
    controlBar.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    controlBar.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
    controlBar.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: topMargin).active = true
    controlBar.bottomAnchor.constraintEqualToAnchor(activityTableView.topAnchor).active = true
  }

  func createActitivyModel(questionInfo: [String:AnyObject], isSnoop: Bool) -> ActivityModel{
    var questionId = questionInfo["id"] as! Int
    if (isSnoop) {
      questionId = questionInfo["quandaId"] as! Int
    }

    let question = questionInfo["question"] as! String
    let status = questionInfo["status"] as! String
    var rate = 0.0
    if (questionInfo["rate"] != nil) {
      rate = questionInfo["rate"] as! Double
    }

    //        let hoursToExpire = questionInfo["hoursToExpire"] as! Int

    let responderAvatarUrl = questionInfo["responderAvatarUrl"] as? String
    let responderName = questionInfo["responderName"] as! String
    let responderTitle = questionInfo["responderTitle"] as! String
    let askerAvatarUrl = questionInfo["askerAvatarUrl"] as? String
    let answerCoverUrl = questionInfo["answerCoverUrl"] as? String
    let answerUrl = questionInfo["answerUrl"] as? String
    let askerName = questionInfo["askerName"] as! String
    let duration = questionInfo["duration"] as! Int
    let createdTime = questionInfo["createdTime"] as! Double

    return ActivityModel(_id: questionId, _question: question, _status: status, _rate: rate, _duration: duration, _askerName: askerName, _responderName: responderName, _responderTitle: responderTitle, _answerCoverUrl: answerCoverUrl, _askerAvatarUrl: askerAvatarUrl, _responderAvatarUrl: responderAvatarUrl, _answerURl: answerUrl, _lastSeenTime: createdTime)
  }

  func setPlaceholderImages(cell: ActivityTableViewCell) {
    cell.coverImage.userInteractionEnabled = false
    cell.coverImage.image = UIImage()
    cell.askerImage.image = UIImage()
    cell.responderImage.image = UIImage()
  }

  func loadDataWithFilter(filterString: String) {
    let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)

    indicator.startAnimating()
    indicator.backgroundColor = UIColor.whiteColor()
    activityTableView.backgroundView = nil
    questionModule.getActivities(filterString, selectedIndex: selectedIndex) { jsonArray in
      for activityInfo in jsonArray as! [[String:AnyObject]] {
        let activity = self.createActitivyModel(activityInfo, isSnoop: false)
        if (self.selectedIndex == 0) {
          self.tmpQuestions.append(activity)
        }
        else if (self.selectedIndex == 1){
          self.tmpAnswers.append(activity)
        }
        else {
          self.tmpSnoops.append(activity)
        }
      }

      dispatch_async(dispatch_get_main_queue()) {
        if (self.selectedIndex == 0) {
          self.questions = self.tmpQuestions
        }
        else if (self.selectedIndex == 1){
          self.answers = self.tmpAnswers
        }
        else {
          self.snoops = self.tmpSnoops
        }

        if (jsonArray.count > 0 || !filterString.containsString("lastSeenId")) {
          self.activityTableView.reloadData()
        }

        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        self.activityTableView.userInteractionEnabled = true
        self.refreshControl.endRefreshing()
        self.tabBarController?.tabBar.items?[2].badgeValue = nil
      }
    }

  }
}

// delegate
extension ActivityViewController: UITableViewDelegate, UITableViewDataSource, CustomTableBackgroundViewDelegate {

  func didTapButton(index: Int) {
    self.tabBarController?.selectedIndex = index
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (selectedIndex == 0) {
      return self.questions.count
    }
    else if (selectedIndex == 1) {
      return self.answers.count
    }
    else if (selectedIndex == 2) {
      return self.snoops.count
    }
    return 0
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let frame = CGRectMake(0, 0, activityTableView.frame.width, activityTableView.frame.height)
    let backgroundView = CustomTableBackgroundView(frame: frame)
    self.activityTableView.backgroundView = nil
    self.activityTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

    if (selectedIndex == 0) {
      if (questions.count == 0) {
        backgroundView.setLabelText("You haven't asked any questions yet.\n Let's discover someone interesting")
        backgroundView.setButtonImage(UIImage(named: "discoverButton")!)
      }
      else {
        return 1
      }
    }
    else if (selectedIndex == 1) {
      if (answers.count == 0) {
        backgroundView.setLabelText("Apply to take questions, check your application status,\n or change your rate")
        backgroundView.setButtonImage(UIImage(named: "profile")!)
      }
      else {
        return 1
      }
    }
    else if (selectedIndex == 2) {
      if (snoops.count == 0) {
        backgroundView.setLabelText("You haven't listened to any questions so far.\n Let's see what's trending")
        backgroundView.setButtonImage(UIImage(named: "trending")!)
      }
      else {
        return 1
      }
    }

    activityTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    backgroundView.delegate = self
    activityTableView.backgroundView = backgroundView
    return 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath)
      as! ActivityTableViewCell

    myCell.userInteractionEnabled = false
    var arrayCount = 0
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    var filterString = "&limit=10"
    let cellInfo: ActivityModel
    if (selectedIndex == 0) {
      cellInfo = questions[indexPath.row]
      arrayCount = questions.count
      filterString = "asker='\(uid)'&lastSeenUpdatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }
    else if (selectedIndex == 1){
      cellInfo = answers[indexPath.row]
      arrayCount = answers.count
      filterString = "responder='\(uid)'&lastSeenCreatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }
    else {
      cellInfo = snoops[indexPath.row]
      arrayCount = snoops.count
      filterString = "uid='\(uid)'&lastSeenCreatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }

    myCell.rateLabel.text = "$ \(cellInfo.rate)"
    myCell.question.text = cellInfo.question
    myCell.responderName.text = cellInfo.responderName
    myCell.askerName.text = cellInfo.askerName + ":"

    if (!cellInfo.responderTitle.isEmpty) {
      myCell.responderTitle.text = cellInfo.responderTitle
    }

    setPlaceholderImages(myCell)

    if let askerAvatarUrl = cellInfo.askerAvatarUrl {
      myCell.askerImage.sd_setImageWithURL(NSURL(string: askerAvatarUrl))
    }
    else {
      myCell.askerImage.image = UIImage(named: "default")
    }

    if let responderAvatarUrl = cellInfo.responderAvatarUrl {
      myCell.responderImage.sd_setImageWithURL(NSURL(string: responderAvatarUrl))
    }
    else {
      myCell.responderImage.image = UIImage(named: "default")
    }

    if (cellInfo.status == "PENDING") {
      myCell.coverImage.image = UIImage()
      myCell.coverImage.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
      myCell.coverImage.userInteractionEnabled = false
      myCell.durationLabel.hidden = true
    }
    else if (cellInfo.status == "ANSWERED") {
      if let coverImageUrl = cellInfo.answerCoverUrl {
        myCell.coverImage.sd_setImageWithURL(NSURL(string: coverImageUrl))
        myCell.coverImage.userInteractionEnabled = true
        let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnImage(_:)))
        myCell.coverImage.addGestureRecognizer(tappedOnImage)

        myCell.durationLabel.text = "00:\(cellInfo.duration)"
        myCell.durationLabel.hidden = false
      }
      else {
        myCell.coverImage.userInteractionEnabled = false
      }
    }

    myCell.userInteractionEnabled = true

    if (indexPath.row == arrayCount - 1) {
      loadDataWithFilter(filterString)
    }

    return myCell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (selectedIndex == 1) {
      let cell = answers[indexPath.row]
      if (cell.status == "PENDING") {
        self.performSegueWithIdentifier("segueFromActivityToAnswer", sender: indexPath)
      }
    }
  }

}

// UI triggered actions
extension ActivityViewController {
  func tappedOnImage(sender:UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.activityTableView)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.activityTableView.indexPathForRowAtPoint(tapLocation)!
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

    let questionInfo:ActivityModel

    if (selectedIndex == 0) {
      questionInfo = questions[indexPath.row]
    }
    else if (selectedIndex == 1) {
      questionInfo = answers[indexPath.row]
    }
    else {
      questionInfo = snoops[indexPath.row]
    }

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

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "segueFromActivityToAnswer") {
      let indexPath = sender as! NSIndexPath
      let dvc = segue.destinationViewController as! AnswerViewController;
      let questionInfo = answers[indexPath.row]
      dvc.cellInfo = questionInfo
    }
  }
}
