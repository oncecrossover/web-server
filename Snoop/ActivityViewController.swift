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
    loadData()
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
    if ((index == 0 && questions.count == 0) || (index == 1 && answers.count == 0) || (index == 2 && snoops.count == 0)) {
      loadData()
    }
    else {
      self.activityTableView.reloadData()
    }
  }
}

// Private function
extension ActivityViewController {

  func refresh(sender: AnyObject) {
    activePlayerView?.closeView()
    loadData()
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
    controlBar.bottomAnchor.constraintEqualToAnchor(activityTableView.topAnchor, constant: -8).active = true
  }

  func loadData() {
    tmpQuestions = []
    tmpAnswers = []
    tmpSnoops = []
    activityTableView.userInteractionEnabled = false
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    if (selectedIndex == 0) {
      loadDataWithFilter("asker='" + uid + "'")
    }
    else if (selectedIndex == 1) {
      loadDataWithFilter("responder='" + uid + "'")
    }
    else if (selectedIndex == 2) {
      loadDataWithFilter("uid='" + uid + "'")
    }

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

  func loadImagesAsync(cellInfo: ActivityModel, completion: (ActivityModel) -> ()) {
    var url = ""
    if let askerAvatarUrl = cellInfo.askerAvatarUrl {
      url += "uri=" + askerAvatarUrl + "&"
    }
    if let responderAvatarUrl = cellInfo.responderAvatarUrl {
      url += "uri=" + responderAvatarUrl + "&"
    }
    if let answerCoverUrl = cellInfo.answerCoverUrl {
      url += "uri=" + answerCoverUrl + "&"
    }

    if (url.isEmpty) {
      cellInfo.askerImage = NSData()
      cellInfo.responderImage = NSData()
      cellInfo.answerCover = NSData()
      completion(cellInfo)
    }
    else {
      url = String(url.characters.dropLast())
      questionModule.getQuestionDatas(url) { result in
        if let askerAvatarUrl = cellInfo.askerAvatarUrl {
          cellInfo.askerImage = NSData(base64EncodedString: (result[askerAvatarUrl] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
        }
        else {
          cellInfo.askerImage = NSData()
        }

        if let responderAvatarUrl = cellInfo.responderAvatarUrl {
          cellInfo.responderImage = NSData(base64EncodedString: (result[responderAvatarUrl] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
        }
        else {
          cellInfo.responderImage = NSData()
        }

        if let answerCoverUrl = cellInfo.answerCoverUrl {
          cellInfo.answerCover = NSData(base64EncodedString: (result[answerCoverUrl] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
        }
        else {
          cellInfo.answerCover = NSData()
        }
        completion(cellInfo)
      }
    }
  }

  func setImages(myCell: ActivityTableViewCell, info: ActivityModel) {
    if (info.askerImage!.length > 0) {
      myCell.askerImage.image = UIImage(data: info.askerImage!)
    }
    else {
      myCell.askerImage.image = UIImage(named: "default")
    }

    if (info.responderImage!.length > 0) {
      myCell.responderImage.image = UIImage(data: info.responderImage!)
    }
    else {
      myCell.responderImage.image = UIImage(named: "default")
    }

    if (info.status == "PENDING") {
      myCell.coverImage.image = UIImage()
      myCell.coverImage.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
      myCell.coverImage.userInteractionEnabled = false
      myCell.durationLabel.hidden = true
    }
    else if (info.status == "ANSWERED") {
      if (info.answerCover != nil) {
        myCell.coverImage.image = UIImage(data: info.answerCover!)

        myCell.coverImage.userInteractionEnabled = true
        let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnImage(_:)))
        myCell.coverImage.addGestureRecognizer(tappedOnImage)

        myCell.durationLabel.text = "00:\(info.duration)"
        myCell.durationLabel.hidden = false
      }
    }
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
    if (cellInfo.askerImage != nil) {
      // All the async loading is done
      setImages(myCell, info: cellInfo)
      myCell.userInteractionEnabled = true
    }
    else {
      // start async loading
      loadImagesAsync(cellInfo) { result in
        dispatch_async(dispatch_get_main_queue()) {
          self.setImages(myCell, info: cellInfo)
          myCell.userInteractionEnabled = true
        }
      }
    }

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
    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
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
    let url = "uri=" + answerUrl
    questionModule.getQuestionDatas(url) { convertedDictIntoJson in
      if let videoString = convertedDictIntoJson[answerUrl] as? String {
        let data = NSData(base64EncodedString: videoString, options: NSDataBase64DecodingOptions(rawValue: 0))!
        dispatch_async(dispatch_get_main_queue()) {
          let dataPath = self.utility.getFileUrl("videoFile.m4a")
          data.writeToURL(dataPath, atomically: false)
          let player = AVPlayer(URL: dataPath)
          videoPlayerView.player = player
          let playerLayer = AVPlayerLayer(player: player)
          playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
          videoPlayerView.layer.addSublayer(playerLayer)
          playerLayer.frame = videoPlayerView.frame

          videoPlayerView.setupPlayingControls()
          let AVAsset = AVURLAsset(URL: dataPath)
          let duration = AVAsset.duration
          let seconds = CMTimeGetSeconds(duration)
          let secondsText = String(format: "%02d", Int(seconds) % 60)
          let minutesText = String(format: "%02d", Int(seconds) / 60)
          videoPlayerView.lengthLabel.text = "\(minutesText):\(secondsText)"
          videoPlayerView.setupProgressControls()

          player.play()
          NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
            // block base observer has retain cycle issue, remember to unregister observer in deinit
            videoPlayerView.reset()
          }
        }
      }
    }

//    if (utility.isInCache(questionId)) {
//      let pathUrl = self.utility.getFileUrl("audio\(questionId)" + ".m4a")
//
//      self.preparePlayer(NSData(contentsOfURL: pathUrl)!)
//      self.soundPlayer.play()
//    }
//    else {
//      questionModule.getQuestionAudio(questionId) { audioString in
//        if (!audioString.isEmpty) {
//          let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
//          dispatch_async(dispatch_get_main_queue()) {
//            self.preparePlayer(data)
//            self.soundPlayer.play()
//          }
//          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//            let pathUrl = self.utility.getFileUrl("audio\(questionId)" + ".m4a")
//            do {
//              try data.writeToURL(pathUrl, options: .DataWritingAtomic)
//              NSUserDefaults.standardUserDefaults().setBool(true, forKey: String(questionId))
//              NSUserDefaults.standardUserDefaults().synchronize()
//            }
//            catch let error as NSError {
//              print(error.localizedDescription)
//            }
//          }
//        }
//      }
//    }
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
