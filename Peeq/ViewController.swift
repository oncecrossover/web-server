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

  var soundPlayer: AVAudioPlayer!

  var snoopQuestionId = 0

  @IBOutlet weak var feedTable: UITableView!

  var feeds:[(id: Int!, question: String!, responderId: String!, responderName: String!, responderTitle: String!, profileData: NSData!, status: String!)] = []

  override func viewDidLoad() {
    super.viewDidLoad()
//    self.navigationController?.tabBarItem?.badgeValue = "2"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
    if (!isUserLoggedIn){
      self.performSegueWithIdentifier("loginView", sender: self)
    }
    else {
      loadData()
    }
  }

  func loadData() {
    self.feeds = []
    questionModule.getQuestions("*") { jsonArray in
      var count = jsonArray.count
      for feedInfo in jsonArray as! [[String:AnyObject]] {
        let questionId = feedInfo["id"] as! Int
        let question = feedInfo["question"] as! String
        let status = feedInfo["status"] as! String
        let responderId = feedInfo["responder"] as! String
        let askerId = feedInfo["asker"] as! String
        let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!

        if (uid == askerId || uid == responderId || status == "EXPIRED") {
          count--
          continue
        }

        self.userModule.getProfile(responderId) {name, title, _, avatarImage in
          self.feeds.append((id: questionId, question: question, responderId: responderId, responderName: name,
            responderTitle: title, profileData: avatarImage, status: status))
          count--
          if (count == 0) {
            dispatch_async(dispatch_get_main_queue()) {
              self.feedTable.reloadData()
            }
          }
        }
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

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 120
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return feeds.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! FeedTableViewCell
    let feedInfo = feeds[indexPath.row]

    if (feedInfo.profileData.length > 0) {
      myCell.profileImage.image = UIImage(data: feedInfo.profileData)
    }

    myCell.questionLabel.text = feedInfo.question
    myCell.titleLabel.text = feedInfo.responderName + " | " + feedInfo.responderTitle

    if (feedInfo.status == "PENDING") {
      myCell.snoopImage.userInteractionEnabled = false
      myCell.snoopImage.image = UIImage(named: "pending")
    }
    else {
      myCell.snoopImage.image = UIImage(named: "snoop")
      myCell.snoopImage.userInteractionEnabled = true
      let tappedOnImage = UITapGestureRecognizer(target: self, action: "tappedOnImage:")
      myCell.snoopImage.addGestureRecognizer(tappedOnImage)
    }

    return myCell
  }


  func tappedOnImage(sender:UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.feedTable)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.feedTable.indexPathForRowAtPoint(tapLocation)!
    let questionInfo = feeds[indexPath.row]
    let questionId = questionInfo.id
    questionModule.getQuestionAudio(questionId) { audioString in
      if (!audioString.isEmpty) {
        let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
        dispatch_async(dispatch_get_main_queue()) {
          self.preparePlayer(data)
          self.soundPlayer.play()
          self.snoopQuestionId = questionId
        }
      }
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
    questionModule.createSnoop(self.snoopQuestionId) { resultString in
    }
  }
}

