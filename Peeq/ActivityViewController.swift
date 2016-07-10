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

  var questions:[(id: Int!, question: String!, status: String!, responderImage: NSData!,
  responderName: String!, responderTitle: String!)] = []
  var answers:[(id: Int!, question: String!, status: String!, askerImage: NSData!,
  askerName: String!, askerTitle: String!, askerId: String!)] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func segmentedControlClicked(sender: AnyObject) {
    if (segmentedControl.selectedSegmentIndex == 0) {
      if (questions.count == 0) {
        loadData()
      }
      else {
        self.activityTableView.reloadData()
      }
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      if (answers.count == 0) {
        loadData()
      }
      else {
        self.activityTableView.reloadData()
      }
    }
    else if (segmentedControl.selectedSegmentIndex == 2) {
      self.activityTableView.reloadData()
    }
  }

  func loadData() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    if segmentedControl.selectedSegmentIndex == 0 {
      loadDataWithFilter("asker=" + uid)
    }
    else if segmentedControl.selectedSegmentIndex == 1 {
      loadDataWithFilter("responder=" + uid)
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
          self.userModule.getProfile(responderId) {name, title, about, avatarImage in
            self.questions.append((id: questionId, question: question, status: status,
              responderImage: avatarImage, responderName: name, responderTitle: title))
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
          self.userModule.getProfile(askerId){name, title, about, avatarImage in
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

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (segmentedControl.selectedSegmentIndex == 0) {
      return self.questions.count
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      return self.answers.count
    }
    return 0
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 120
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.activityTableView.bounds.size.width,
      self.activityTableView.bounds.size.height))
    self.activityTableView.backgroundView = nil
    self.activityTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine

    if (segmentedControl.selectedSegmentIndex == 0) {
      if (questions.count == 0) {
        noDataLabel.text = "You haven't asked any questions yet"
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
    else {
      noDataLabel.text = "You have no snoops so far"
    }

    noDataLabel.textColor = UIColor.grayColor()
    noDataLabel.textAlignment = NSTextAlignment.Center
    self.activityTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    self.activityTableView.backgroundView = noDataLabel

    return 0
  }

  func tappedOnButton(sender:UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.activityTableView)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.activityTableView.indexPathForRowAtPoint(tapLocation)!
    let questionInfo = questions[indexPath.row]
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
    if segmentedControl.selectedSegmentIndex == 0 {
      let myCell = tableView.dequeueReusableCellWithIdentifier("questionCell", forIndexPath: indexPath)
        as! QuestionTableViewCell
      let question = questions[indexPath.row]
      myCell.questionText.text = question.question
      myCell.titleLabel.text = "\(question.responderName)" + " | "  + "\(question.responderTitle)"
      if (question.responderImage.length > 0) {
        myCell.profileImage.image = UIImage(data: question.responderImage)
      }

      if question.status == "PENDING" {
        myCell.listenButton.hidden = true
      }

      myCell.listenButton.userInteractionEnabled = true
      let tappedOnButton = UITapGestureRecognizer(target: self, action: "tappedOnButton:")
      myCell.listenButton.addGestureRecognizer(tappedOnButton)

      return myCell
    }
    else if segmentedControl.selectedSegmentIndex == 1 {
      let myCell = tableView.dequeueReusableCellWithIdentifier("answerCell", forIndexPath: indexPath) as! AnswerTableViewCell
      let answer = answers[indexPath.row]
      myCell.askerName.text = answer.askerName
      if (answer.askerImage.length > 0) {
        myCell.profileImage.image = UIImage(data: answer.askerImage)
      }
      myCell.status.text = answer.status
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
  }


}
