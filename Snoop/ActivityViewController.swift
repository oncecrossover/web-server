//
//  ActivityViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate {

  @IBOutlet weak var activityTableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  var userModule = User()
  var questionModule = Question()
  var utility = UIUtility()
  var generics = Generics()

  var soundPlayer: AVAudioPlayer!
  var activeCell: (Bool!, Int!)!

  var questions:[QuestionModel] = []

  var answers:[AnswerModel] = []

  var snoops:[SnoopModel] = []

  var refreshControl: UIRefreshControl = UIRefreshControl()

  override func viewDidLoad() {
    super.viewDidLoad()

    activityTableView.rowHeight = UITableViewAutomaticDimension
    activityTableView.estimatedRowHeight = 120

    refreshControl.addTarget(self, action: #selector(ActivityViewController.refresh(_:)), forControlEvents: .ValueChanged)
    activityTableView.addSubview(refreshControl)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadData()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    stopPlayer()
  }

  func stopPlayer() {
    if (self.soundPlayer != nil) {
      if (self.soundPlayer.playing) {
        self.soundPlayer.stop()
        if (self.activeCell != nil) {
          if (self.activeCell.0!) {
            snoops[self.activeCell.1].isPlaying = false
          }
          else {
            questions[self.activeCell.1].isPlaying = false
          }
        }
      }
    }
  }

  @IBAction func segmentedControlClicked(sender: AnyObject) {
    stopPlayer()
    loadData()
  }

  func refresh(sender: AnyObject) {
    loadData()
    refreshControl.endRefreshing()
  }

  func loadData() {
    activityTableView.userInteractionEnabled = false
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    if (segmentedControl.selectedSegmentIndex == 0) {
      questions = []
      loadDataWithFilter("asker='" + uid + "'")
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      answers = []
      loadDataWithFilter("responder='" + uid + "'")
    }
    else if (segmentedControl.selectedSegmentIndex == 2) {
      snoops = []
      loadSnoops(uid)
    }

  }

  func loadDataWithFilter(filterString: String) {
    var isQuestion = true
    if (filterString.containsString("responder")) {
      isQuestion = false
    }
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
          var avatarImage = NSData()
          if ((questionInfo["responderAvatarImage"] as? String) != nil) {
            avatarImage = NSData(base64EncodedString: (questionInfo["responderAvatarImage"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
          }

          let name = questionInfo["responderName"] as! String
          let title = questionInfo["responderTitle"] as! String
          self.questions.append(QuestionModel(_name: name, _title: title, _avatarImage: avatarImage, _id: questionId, _question: question, _status: status, _isPlaying: false, _rate: rate, _hoursToExpire: hoursToExpire))

        }
        else if (self.segmentedControl.selectedSegmentIndex == 1) {
          var avatarImage = NSData()
          if ((questionInfo["askerAvatarImage"] as? String) != nil) {
            avatarImage = NSData(base64EncodedString: (questionInfo["askerAvatarImage"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))!
          }

          let name = questionInfo["askerName"] as! String
          let title = questionInfo["askerTitle"] as! String
          self.answers.append(AnswerModel(_name: name, _title: title, _avatarImage: avatarImage, _id: questionId, _question: question, _status: status, _hoursToExpire: hoursToExpire, _rate: rate))
        }
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.activityTableView.reloadData()
        self.activityTableView.userInteractionEnabled = true
      }
    }

  }

  func loadSnoops(uid: String) {
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
        self.snoops.append(snoopModel)
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.activityTableView.reloadData()
        self.activityTableView.userInteractionEnabled = true
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
    var questionInfo:QuandaModel

    var isSnoop = false
    if (segmentedControl.selectedSegmentIndex == 0) {
      questionInfo = questions[indexPath.row]
    }
    else {
      questionInfo = snoops[indexPath.row]
      isSnoop = true
    }

    self.activeCell = (isSnoop, indexPath.row)

    if (questionInfo.isPlaying!) {
      stopPlayer()
      self.activityTableView.reloadData()
      return
    }

    if (isSnoop) {
      snoops[self.activeCell.1].isPlaying = true
    }
    else {
      questions[self.activeCell.1].isPlaying = true
    }

    self.activityTableView.reloadData()

    let questionId = questionInfo.id
    questionModule.getQuestionAudio(questionId) { audioString in
      if (!audioString.isEmpty) {
        let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
        dispatch_async(dispatch_get_main_queue()) {
          self.preparePlayer(data)
          self.soundPlayer.play()
        }
      }
    }
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
      let myCell = tableView.dequeueReusableCellWithIdentifier("questionCell", forIndexPath: indexPath)
        as! QuestionTableViewCell

      var cellInfo: QuandaModel
      if (segmentedControl.selectedSegmentIndex == 2) {
        cellInfo = snoops[indexPath.row]
        myCell.rateLabel.hidden = true
      }
      else {
        cellInfo = questions[indexPath.row]
        myCell.rateLabel.text = "$\(cellInfo.rate)"
        myCell.rateLabel.hidden = false
      }

      myCell.questionText.text = cellInfo.question

      if (cellInfo.title.isEmpty) {
        myCell.titleLabel.text = cellInfo.name
      }
      else {
        myCell.titleLabel.text = "\(cellInfo.name)" + " | "  + "\(cellInfo.title)"
      }

      if (cellInfo.avatarImage.length > 0) {
        myCell.profileImage.image = UIImage(data: cellInfo.avatarImage)
      }

      if (cellInfo.status == "PENDING") {
        var expireText = "Expires In \(cellInfo.hoursToExpire) Hours"
        if (cellInfo.hoursToExpire == 1) {
          expireText = "Expires In 1 Hour"
        }
        let x = myCell.listenImage.frame.size.width * 0.4
        let y = myCell.listenImage.frame.size.height/3
        let textPoint = CGPointMake(x, y)
        let originalImage = UIImage(named: "pending")
        myCell.listenImage.image = utility.addTextToImage(expireText, inImage: originalImage!, atPoint: textPoint)
        myCell.listenImage.userInteractionEnabled = false
      }
      else if (cellInfo.status == "EXPIRED") {
        myCell.listenImage.image = UIImage(named: "expired")
        myCell.listenImage.userInteractionEnabled = false
      }
      else {
        if (cellInfo.isPlaying!) {
          myCell.listenImage.image = UIImage(named: "stop")
        }
        else {
          myCell.listenImage.image = UIImage(named: "listen")
        }

        myCell.listenImage.userInteractionEnabled = true
        let tappedOnButton = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnImage(_:)))
        myCell.listenImage.addGestureRecognizer(tappedOnButton)
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
        content: questionInfo.question, rate: questionInfo.rate)
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
    if (self.activeCell.0!){
      snoops[self.activeCell.1].isPlaying = false
    }
    else {
      questions[self.activeCell.1].isPlaying = false
    }

    self.activityTableView.reloadData()
  }
}
