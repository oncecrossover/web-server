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

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {

  @IBOutlet weak var activityTableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  var userModule = User()
  var questionModule = Question()
  var utility = UIUtility()
  var generics = Generics()

  var soundPlayer: AVAudioPlayer!
  var activeCell: (Bool!, Int!)!

  var questions:[ActivityModel] = []

  var answers:[AnswerModel] = []

  var snoops:[SnoopModel] = []

  var refreshControl: UIRefreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()

    activityTableView.rowHeight = UITableViewAutomaticDimension
    activityTableView.estimatedRowHeight = 230

    refreshControl.addTarget(self, action: #selector(ActivityViewController.refresh(_:)), forControlEvents: .ValueChanged)
    activityTableView.addSubview(refreshControl)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadData()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }

  @IBAction func segmentedControlClicked(sender: AnyObject) {
    loadData()
  }

  func refresh(sender: AnyObject) {
    loadData()
  }

  func loadData() {
    activityTableView.userInteractionEnabled = false
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    if (segmentedControl.selectedSegmentIndex == 0) {
      loadDataWithFilter("asker='" + uid + "'")
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      loadDataWithFilter("responder='" + uid + "'")
    }
    else if (segmentedControl.selectedSegmentIndex == 2) {
      loadSnoops(uid)
    }

  }

  func loadDataWithFilter(filterString: String) {
    var isQuestion = true
    var tmpQuestions:[ActivityModel] = []
    var tmpAnswers:[AnswerModel] = []

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
        let questionId = questionInfo["id"] as! Int
        let question = questionInfo["question"] as! String
        let status = questionInfo["status"] as! String
        var rate = 0.0
        if (questionInfo["rate"] != nil) {
          rate = questionInfo["rate"] as! Double
        }

        let hoursToExpire = questionInfo["hoursToExpire"] as! Int

        if (self.segmentedControl.selectedSegmentIndex == 0) {
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
          tmpQuestions.append(ActivityModel(_id: questionId, _question: question, _status: status, _rate: rate, _answerCover: coverImage, _askerName: askerName, _askerImage: askerImage, _responderName: responderName, _responderTitle: responderTitle, _responderImage: responderImage))

        }
        else if (self.segmentedControl.selectedSegmentIndex == 1) {
          var avatarImage = NSData()
          if ((questionInfo["askerAvatarImage"] as? String) != nil) {
            avatarImage = NSData(base64EncodedString: (questionInfo["askerAvatarImage"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
          }

          let name = questionInfo["askerName"] as! String
          var title = ""
          if ((questionInfo["askerTitle"] as? String) != nil) {
            title = questionInfo["askerTitle"] as! String
          }
          tmpAnswers.append(AnswerModel(_name: name, _title: title, _avatarImage: avatarImage, _id: questionId, _question: question, _status: status, _hoursToExpire: hoursToExpire, _rate: rate))
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
    var tmpSnoops:[SnoopModel] = []
    let indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)

    indicator.startAnimating()
    indicator.backgroundColor = UIColor.whiteColor()
    activityTableView.backgroundView = nil
    questionModule.getSnoops(uid) { jsonArray in
      for snoop in jsonArray as! [[String:AnyObject]] {
        let questionId = snoop["quandaId"] as! Int
        let question = snoop["question"] as! String

        var avatarImage = NSData()
        if ((snoop["responderAvatarImage"] as? String) != nil) {
          avatarImage = NSData(base64EncodedString: (snoop["responderAvatarImage"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
        }

        let name = snoop["responderName"] as! String
        var title = ""
        if ((snoop["responderTitle"] as? String) != nil) {
          title = snoop["responderTitle"] as! String
        }

        let snoopModel = SnoopModel(_name: name, _title: title, _avatarImage: avatarImage, _id: questionId, _question: question, _status: "ANSWERED", _isPlaying: false)
        tmpSnoops.append(snoopModel)
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

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (segmentedControl.selectedSegmentIndex == 0) {
      return self.questions.count
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      return self.answers.count
    }
    else if (segmentedControl.selectedSegmentIndex == 2) {
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

    if (segmentedControl.selectedSegmentIndex == 0) {
      if (questions.count == 0) {
        noDataLabel.text = "You haven't asked any questions yet. Let's discover someone interesting"

        button.setImage(UIImage(named: "discoverButton"), forState: .Normal)
        button.userInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnDiscoverButton(_:)))
        button.addGestureRecognizer(gestureRecognizer)
      }
      else {
        return 1
      }
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      if (answers.count == 0) {
        noDataLabel.text = "You have no answer requests so far"
      }
      else {
        return 1
      }
    }
    else if (segmentedControl.selectedSegmentIndex == 2) {
      if (snoops.count == 0) {
        noDataLabel.text = "You haven't listened to any questions so far. Let's see what's trending"
        button.setImage(UIImage(named: "trendingButton"), forState: .Normal)
        button.userInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnHomeButton(_:)))
        button.addGestureRecognizer(gestureRecognizer)
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

  func tappedOnHomeButton(sender: UIGestureRecognizer) {
    self.tabBarController?.selectedIndex = 0
  }

  func tappedOnDiscoverButton(sender: UIGestureRecognizer) {
    self.tabBarController?.selectedIndex = 1
  }

  func tappedOnImage(sender:UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.activityTableView)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.activityTableView.indexPathForRowAtPoint(tapLocation)!
    var questionInfo:ActivityModel

    questionInfo = questions[indexPath.row]


    let questionId = questionInfo.id
    let activityIndicator = utility.createCustomActivityIndicator(self.view, text: "Loading Answer...")
    questionModule.getQuestionAudio(questionId) { audioString in
      if (!audioString.isEmpty) {
        let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
        dispatch_async(dispatch_get_main_queue()) {
          let dataPath = self.utility.getFileUrl("videoFile.m4a")
          data.writeToURL(dataPath, atomically: false)
          activityIndicator.hideAnimated(true)
          let videoAsset = AVAsset(URL: dataPath)
          let playerItem = AVPlayerItem(asset: videoAsset)

          //Play the video
          let player = AVPlayer(playerItem: playerItem)
          let playerViewController = AVPlayerViewController()
          playerViewController.player = player
          self.presentViewController(playerViewController, animated: true) {
            playerViewController.player?.play()
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

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if (segmentedControl.selectedSegmentIndex == 0 && questions[indexPath.row].status == "EXPIRED") {
      return true
    }
    return false
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (segmentedControl.selectedSegmentIndex == 0) {
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
    if (segmentedControl.selectedSegmentIndex == 0 || segmentedControl.selectedSegmentIndex == 2) {
      let myCell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath)
        as! ActivityTableViewCell

      let cellInfo = questions[indexPath.row]
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
      }
      else if (cellInfo.status == "ANSWERED") {
        myCell.coverImage.image = UIImage(data: cellInfo.answerCover)

        myCell.coverImage.userInteractionEnabled = true
        let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnImage(_:)))
        myCell.coverImage.addGestureRecognizer(tappedOnImage)
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
    else if (segmentedControl.selectedSegmentIndex == 1) {
      let myCell = tableView.dequeueReusableCellWithIdentifier("answerCell", forIndexPath: indexPath) as! AnswerTableViewCell
      let answer = answers[indexPath.row]
      myCell.askerName.text = answer.name
      myCell.rateLabel.text = "$\(answer.rate)"
      if (answer.avatarImage.length > 0) {
        myCell.profileImage.image = UIImage(data: answer.avatarImage)
      }
      else {
        myCell.profileImage.image = UIImage(named: "default")
      }

      myCell.status.text = answer.status

      if (answer.status == "PENDING") {
        myCell.status.textColor = UIColor.orangeColor()
        myCell.expiration.text = "expires in \(answer.hoursToExpire) hrs"
        myCell.expiration.hidden = false
      }
      else if (answer.status == "ANSWERED") {
        myCell.status.textColor = UIColor(red: 0.125, green: 0.55, blue: 0.17, alpha: 1.0)
        myCell.expiration.hidden = true
      }
      myCell.question.text = answer.question

      return myCell
    }
    return tableView.dequeueReusableCellWithIdentifier("questionCell", forIndexPath: indexPath) as! QuestionTableViewCell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if segmentedControl.selectedSegmentIndex == 1 {
      self.performSegueWithIdentifier("segueFromActivityToAnswer", sender: indexPath)
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "segueFromActivityToAnswer") {
      let indexPath = sender as! NSIndexPath
      let dvc = segue.destinationViewController as! AnswerViewController;
      let questionInfo = answers[indexPath.row]
      dvc.question = (id: questionInfo.id, avatarImage: questionInfo.avatarImage, askerName: questionInfo.name,
        status: questionInfo.status,
        content: questionInfo.question, rate: questionInfo.rate, hoursToExpire : questionInfo.hoursToExpire)
    }
    
  }

}
