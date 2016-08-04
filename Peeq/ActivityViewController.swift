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

  var soundPlayer: AVAudioPlayer!
  var activeCell: (Bool!, Int!)!

  var questions:[(id: Int!, question: String!, status: String!, responderImage: NSData!,
  responderName: String!, responderTitle: String!, isPlaying: Bool!)] = []
  var answers:[(id: Int!, question: String!, status: String!, askerImage: NSData!,
    askerName: String!, askerTitle: String!, askerId: String!)] = []
  var snoops:[(id: Int!, question: String!, status: String!, responderImage: NSData!, responderName: String!,
  responderTitle: String!, isPlaying: Bool!)] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
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

  func loadData() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    if (segmentedControl.selectedSegmentIndex == 0) {
      questions = []
      loadDataWithFilter("asker=" + uid)
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      answers = []
      loadDataWithFilter("responder=" + uid)
    }
    else if (segmentedControl.selectedSegmentIndex == 2) {
      snoops = []
      loadSnoops(uid)
    }

  }

  func loadDataWithFilter(filterString: String) {
    questionModule.getQuestions(filterString) { jsonArray in
      var count = jsonArray.count
      if count == 0 {
        dispatch_async(dispatch_get_main_queue()) {
          self.activityTableView.reloadData()
        }
        return
      }
      for questionInfo in jsonArray as! [[String:AnyObject]] {
        let questionId = questionInfo["id"] as! Int
        let question = questionInfo["question"] as! String
        let status = questionInfo["status"] as! String

        if (self.segmentedControl.selectedSegmentIndex == 0) {
          let responderId = questionInfo["responder"] as! String
          self.userModule.getProfile(responderId) {name, title, about, avatarImage, _ in
            self.questions.append((id: questionId, question: question, status: status,
              responderImage: avatarImage, responderName: name, responderTitle: title, isPlaying: false))
            count--
            if (count == 0) {
              dispatch_async(dispatch_get_main_queue()) {
                self.activityTableView.reloadData()
              }
            }
          }
        }
        else if (self.segmentedControl.selectedSegmentIndex == 1) {
          let askerId = questionInfo["asker"] as! String
          self.userModule.getProfile(askerId){name, title, about, avatarImage, _ in
            self.answers.append((id: questionId, question: question, status: status,
              askerImage: avatarImage, askerName: name, askerTitle: title, askerId: askerId))
            count--
            if (count == 0) {
              dispatch_async(dispatch_get_main_queue()) {
                self.activityTableView.reloadData()
              }
            }
          }
        }
      }
    }

  }

  func loadSnoops(uid: String) {
    questionModule.getSnoops(uid) { jsonArray in
      var count = jsonArray.count
      if count == 0 {
        dispatch_async(dispatch_get_main_queue()) {
          self.activityTableView.reloadData()
        }
        return
      }
      for snoop in jsonArray as! [[String:AnyObject]] {
        let questionId = snoop["quandaId"] as! Int
        self.questionModule.getQuestionById(questionId) { responderId, question in
          self.userModule.getProfile(responderId) {name, title, _, avatarImage, _ in
            self.snoops.append((id: questionId, question: question, status: "ANSWERED", responderImage: avatarImage,
              responderName: name, responderTitle: title, isPlaying: false))
            count--
            if (count == 0) {
              dispatch_async(dispatch_get_main_queue()) {
                self.activityTableView.reloadData()
              }
            }
          }
        }
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

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 120
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
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedOnDiscoverButton:")
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
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedOnHomeButton:")
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
    var questionInfo:(id: Int!, question: String!, status: String!, responderImage: NSData!,
    responderName: String!, responderTitle: String!, isPlaying: Bool!)

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

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if (segmentedControl.selectedSegmentIndex == 0 || segmentedControl.selectedSegmentIndex == 2) {
      let myCell = tableView.dequeueReusableCellWithIdentifier("questionCell", forIndexPath: indexPath)
        as! QuestionTableViewCell

      var cellInfo:(id: Int!, question: String!, status: String!, responderImage: NSData!,
      responderName: String!, responderTitle: String!, isPlaying: Bool!)
      if (segmentedControl.selectedSegmentIndex == 2) {
        cellInfo = snoops[indexPath.row]
      }
      else {
        cellInfo = questions[indexPath.row]
      }

      myCell.questionText.text = cellInfo.question

      if (cellInfo.responderTitle.isEmpty) {
        myCell.titleLabel.text = cellInfo.responderName
      }
      else {
        myCell.titleLabel.text = "\(cellInfo.responderName)" + " | "  + "\(cellInfo.responderTitle)"
      }

      if (cellInfo.responderImage.length > 0) {
        myCell.profileImage.image = UIImage(data: cellInfo.responderImage)
      }

      if (cellInfo.status == "PENDING") {
        myCell.listenImage.image = UIImage(named: "pending")
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
        let tappedOnButton = UITapGestureRecognizer(target: self, action: "tappedOnImage:")
        myCell.listenImage.addGestureRecognizer(tappedOnButton)

      }


      return myCell
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      let myCell = tableView.dequeueReusableCellWithIdentifier("answerCell", forIndexPath: indexPath) as! AnswerTableViewCell
      let answer = answers[indexPath.row]
      myCell.askerName.text = answer.askerName
      if (answer.askerImage.length > 0) {
        myCell.profileImage.image = UIImage(data: answer.askerImage)
      }

      myCell.status.text = answer.status

      if (answer.status == "PENDING") {
        myCell.status.textColor = UIColor.orangeColor()
      }
      else if (answer.status == "ANSWERED") {
        myCell.status.textColor = UIColor(red: 0.125, green: 0.55, blue: 0.17, alpha: 1.0)
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
      dvc.question = (id: questionInfo.id, avatarImage: questionInfo.askerImage, askerName: questionInfo.askerName,
        askerId: questionInfo.askerId, status: questionInfo.status,
        content: questionInfo.question)
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
