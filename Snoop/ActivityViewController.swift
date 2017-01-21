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

  var questions:[ActivityModel] = []

  var answers:[ActivityModel] = []

  var snoops:[ActivityModel] = []

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
    loadData()
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
    activityTableView.userInteractionEnabled = false
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    if (selectedIndex == 0) {
      loadDataWithFilter("asker='" + uid + "'")
    }
    else if (selectedIndex == 1) {
      loadDataWithFilter("responder='" + uid + "'")
    }
    else if (selectedIndex == 2) {
      loadSnoops(uid)
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

    var responderImage = NSData()
    if ((questionInfo["responderAvatarImage"] as? String) != nil) {
      responderImage = NSData(base64EncodedString: (questionInfo["responderAvatarImage"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
    }

    let responderName = questionInfo["responderName"] as! String
    let responderTitle = questionInfo["responderTitle"] as! String

    var askerImage = NSData()
    if ((questionInfo["askerAvatarImage"] as? String) != nil) {
      askerImage = NSData(base64EncodedString: (questionInfo["askerAvatarImage"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
    }

    var coverImage = NSData()
    if ((questionInfo["answerCover"] as? String) != nil) {
      coverImage = NSData(base64EncodedString: (questionInfo["answerCover"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
    }

    let askerName = questionInfo["askerName"] as! String
    let duration = questionInfo["duration"] as! Int

    return ActivityModel(_id: questionId, _question: question, _status: status, _rate: rate, _answerCover: coverImage, _duration: duration, _askerName: askerName, _askerImage: askerImage, _responderName: responderName, _responderTitle: responderTitle, _responderImage: responderImage)
  }

  func loadDataWithFilter(filterString: String) {
    var isQuestion = true
    var tmpQuestions:[ActivityModel] = []
    var tmpAnswers:[ActivityModel] = []

    if (filterString.containsString("responder")) {
      isQuestion = false
    }

    let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)

    indicator.startAnimating()
    indicator.backgroundColor = UIColor.whiteColor()
    activityTableView.backgroundView = nil
    questionModule.getQuestions(filterString, isQuestion: isQuestion) { jsonArray in
      for questionInfo in jsonArray as! [[String:AnyObject]] {
        let activity = self.createActitivyModel(questionInfo, isSnoop: false)
        if (self.selectedIndex == 0) {
          tmpQuestions.append(activity)
        }
        else {
          tmpAnswers.append(activity)
        }
      }

      dispatch_async(dispatch_get_main_queue()) {
        if (isQuestion) {
          self.questions = tmpQuestions
        }
        else {
          self.answers = tmpAnswers
        }
        self.activityTableView.reloadData()
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        self.activityTableView.userInteractionEnabled = true
        self.refreshControl.endRefreshing()
      }
    }

  }

  func loadSnoops(uid: String) {
    var tmpSnoops:[ActivityModel] = []
    let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)

    indicator.startAnimating()
    indicator.backgroundColor = UIColor.whiteColor()
    activityTableView.backgroundView = nil
    questionModule.getSnoops(uid) { jsonArray in
      for questionInfo in jsonArray as! [[String:AnyObject]] {
        let activity = self.createActitivyModel(questionInfo, isSnoop: true)
        tmpSnoops.append(activity)
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.snoops = tmpSnoops
        self.activityTableView.reloadData()
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        self.activityTableView.userInteractionEnabled = true
        self.refreshControl.endRefreshing()
      }
    }
  }

}

// delegate
extension ActivityViewController: UITableViewDelegate, UITableViewDataSource {

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
    let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.activityTableView.bounds.size.width,
      self.activityTableView.bounds.size.height))
    let x = (self.activityTableView.bounds.size.width - 280) / 2
    let y = self.activityTableView.bounds.size.height * 3 / 4 - 30
    let button = RoundCornerButton(frame: CGRect(x: x, y: y, width: 280, height: 55))
    button.layer.cornerRadius = 4
    self.activityTableView.backgroundView = nil
    self.activityTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

    if (selectedIndex == 0) {
      if (questions.count == 0) {
        noDataLabel.text = "You haven't asked any questions yet. Let's discover someone interesting"

        button.setImage(UIImage(named: "discoverButton"), forState: .Normal)
        button.addTarget(self, action: #selector(ActivityViewController.tappedOnDiscoverButton(_:)), forControlEvents: .TouchUpInside)
      }
      else {
        return 1
      }
    }
    else if (selectedIndex == 1) {
      if (answers.count == 0) {
        noDataLabel.text = "Apply to take questions, check your application status, or change your rate"
        button.setImage(UIImage(named: "profile"), forState: .Normal)
        button.addTarget(self, action: #selector(ActivityViewController.tappedOnProfileButton(_:)), forControlEvents: .TouchUpInside)
      }
      else {
        return 1
      }
    }
    else if (selectedIndex == 2) {
      if (snoops.count == 0) {
        noDataLabel.text = "You haven't listened to any questions so far. Let's see what's trending"
        button.setImage(UIImage(named: "trending"), forState: .Normal)
        button.addTarget(self, action: #selector(ActivityViewController.tappedOnHomeButton(_:)), forControlEvents: .TouchUpInside)
      }
      else {
        return 1
      }
    }

    noDataLabel.textColor = UIColor.lightGrayColor()
    noDataLabel.textAlignment = NSTextAlignment.Center
    noDataLabel.numberOfLines = 0
    self.activityTableView.separatorStyle = UITableViewCellSeparatorStyle.None

    let customView = UIView(frame: CGRectMake(0, 0, self.activityTableView.bounds.size.width,
      self.activityTableView.bounds.size.height))
    customView.addSubview(noDataLabel)
    customView.addSubview(button)
    self.activityTableView.backgroundView = customView

    return 0
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if (selectedIndex == 0 && questions[indexPath.row].status == "EXPIRED") {
      return true
    }
    return false
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (selectedIndex == 0) {
      if (editingStyle == .Delete) {
        let quandaId = questions[indexPath.row].id
        questions.removeAtIndex(indexPath.row)
        let jsonData = ["active" : "FALSE"]
        let url = NSURL(string: "http://localhost:8080/quandas/" + "\(quandaId)")!
        generics.updateObject(url, jsonData: jsonData) { result in
          if (result.isEmpty) {
            dispatch_async(dispatch_get_main_queue()) {
              self.activityTableView.reloadData()
            }
          }
        }
      }
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath)
      as! ActivityTableViewCell

    let cellInfo: ActivityModel
    if (selectedIndex == 0) {
      cellInfo = questions[indexPath.row]
    }
    else if (selectedIndex == 1){
      cellInfo = answers[indexPath.row]
    }
    else {
      cellInfo = snoops[indexPath.row]
    }

    myCell.rateLabel.text = "$ \(cellInfo.rate)"

    myCell.question.text = cellInfo.question

    myCell.responderName.text = cellInfo.responderName

    if (!cellInfo.responderTitle.isEmpty) {
      myCell.responderTitle.text = cellInfo.responderTitle
    }

    if (cellInfo.responderImage.length > 0) {
      myCell.responderImage.image = UIImage(data: cellInfo.responderImage)
    }
    else {
      myCell.responderImage.image = UIImage(named: "default")
    }

    if (cellInfo.status == "PENDING") {
      myCell.coverImage.image = UIImage()
      myCell.coverImage.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
      myCell.durationLabel.hidden = true
    }
    else if (cellInfo.status == "ANSWERED") {
      myCell.coverImage.image = UIImage(data: cellInfo.answerCover)

      myCell.coverImage.userInteractionEnabled = true
      let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnImage(_:)))
      myCell.coverImage.addGestureRecognizer(tappedOnImage)

      myCell.durationLabel.text = "00:\(cellInfo.duration)"
      myCell.durationLabel.hidden = false
    }

    myCell.askerName.text = cellInfo.askerName + ":"

    if (cellInfo.askerImage.length > 0) {
      myCell.askerImage.image = UIImage(data: cellInfo.askerImage)
    }
    else {
      myCell.askerImage.image = UIImage(named: "default")
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

  func tappedOnHomeButton(sender: AnyObject) {
    self.tabBarController?.selectedIndex = 0
  }

  func tappedOnDiscoverButton(sender: AnyObject) {
    self.tabBarController?.selectedIndex = 1
  }

  func tappedOnProfileButton(sender: AnyObject) {
    self.tabBarController?.selectedIndex = 3
  }

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

    let questionId = questionInfo.id
    questionModule.getQuestionMedia(questionId) { audioString in
      if (!audioString.isEmpty) {
        let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
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
