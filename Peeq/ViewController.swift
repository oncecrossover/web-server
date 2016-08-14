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

  var soundPlayer: AVAudioPlayer!

  var snoopQuestionId = 0

  var paymentInfo:(quandaId: Int!, index: Int!)

  @IBOutlet weak var feedTable: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var feeds:[(id: Int!, question: String!, responderId: String!, responderName: String!, responderTitle: String!, profileData: NSData!, status: String!, asker: String!)] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    print("called")
    let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
    if (!isUserLoggedIn){
      self.performSegueWithIdentifier("loginView", sender: self)
    }
    else {
      loadData()
    }
  }

  func loadData() {
    if (paymentInfo.index != nil) {
      let paidFeed = feeds[paymentInfo.index]
      feeds = []
      feeds.append(paidFeed)
    }
    else {
      self.feeds = []
    }
    
    activityIndicator.startAnimating()
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let myUrl = NSURL(string: "http://localhost:8080/newsfeeds/" + uid)
    generics.getFilteredObjects(myUrl!) { jsonArray in
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

        self.userModule.getProfile(responderId) {name, title, _, avatarImage, _ in
          self.feeds.append((id: questionId, question: question, responderId: responderId, responderName: name,
            responderTitle: title, profileData: avatarImage, status: status, asker: askerId))
          count--
          if (count == 0) {
            dispatch_async(dispatch_get_main_queue()) {
              self.activityIndicator.stopAnimating()
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

    if (feedInfo.responderTitle.isEmpty) {
      myCell.titleLabel.text = feedInfo.responderName
    }
    else {
      myCell.titleLabel.text = feedInfo.responderName + " | " + feedInfo.responderTitle
    }

    if (feedInfo.status == "PENDING") {
      myCell.snoopImage.userInteractionEnabled = false
      myCell.snoopImage.image = UIImage(named: "pending")
    }
    else {
      if (paymentInfo.index != nil && paymentInfo.index == indexPath.row) {
        myCell.snoopImage.image = UIImage(named: "listen")
        myCell.snoopImage.userInteractionEnabled = true
        let tappedOnImage = UITapGestureRecognizer(target: self, action: "tappedToListen:")
        myCell.snoopImage.addGestureRecognizer(tappedOnImage)
      }
      else {
        myCell.snoopImage.image = UIImage(named: "snoop")
        myCell.snoopImage.userInteractionEnabled = true
        let tappedOnImage = UITapGestureRecognizer(target: self, action: "tappedOnImage:")
        myCell.snoopImage.addGestureRecognizer(tappedOnImage)
      }
    }

    return myCell
  }


  func tappedToListen(sender:UIGestureRecognizer) {
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

  func tappedOnImage(sender: UIGestureRecognizer) {
    let tapLocation = sender.locationInView(self.feedTable)
    let indexPath = self.feedTable.indexPathForRowAtPoint(tapLocation)!
    self.performSegueWithIdentifier("homeToPayment", sender: indexPath)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "homeToPayment") {
      let indexPath = sender as! NSIndexPath
      let dvc = segue.destinationViewController as! ChargeViewController;
      let feed = feeds[indexPath.row]
      dvc.chargeInfo = (amount: 1.00, type: "SNOOPED", quandaId: feed.id,
        asker: feed.asker, responder: feed.responderId, index: indexPath.row)
      dvc.isSnooped = true
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

