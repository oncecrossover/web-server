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

  let notificationName = "answerRefresh"

  deinit {
    NotificationCenter.default.removeObserver(self) // app might crash without removing observer
  }

  var fullScreenImageView : FullScreenImageView = FullScreenImageView()
}

// override function
extension ActivityViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    activityTableView.rowHeight = UITableViewAutomaticDimension
    activityTableView.estimatedRowHeight = 230
    activityTableView.tableHeaderView = UIView()
    activityTableView.tableFooterView = UIView()

    refreshControl.addTarget(self, action: #selector(ActivityViewController.refresh(_:)), for: .valueChanged)
    activityTableView.addSubview(refreshControl)
    controlBar.delegate = self

    setupSegmentedControl()
    NotificationCenter.default.addObserver(self, selector: #selector(refreshAnswers), name: NSNotification.Name(rawValue: self.notificationName), object: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
      // block base observer has retain cycle issue, remember to unregister observer in deinit
      self.activePlayerView?.reset()
    }
    NotificationCenter.default.addObserver(self, selector: #selector(refreshAnswers), name: NSNotification.Name(rawValue: self.notificationName), object: nil)
    loadIndex(selectedIndex)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self) // app might crash without removing observer
  }
}

//segmentedControlDelegate
extension ActivityViewController: SegmentedControlDelegate {
  func loadIndex(_ index: Int) {
    selectedIndex = index
    if (index == 0) {
      if (UserDefaults.standard.bool(forKey: "shouldLoadQuestions") == true) {
        UserDefaults.standard.set(false, forKey: "shouldLoadQuestions")
        UserDefaults.standard.synchronize()
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
      if (UserDefaults.standard.bool(forKey: "shouldLoadAnswers") == true) {
        UserDefaults.standard.set(false, forKey: "shouldLoadAnswers")
        UserDefaults.standard.synchronize()
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
      if (UserDefaults.standard.bool(forKey: "shouldLoadSnoops") == true) {
        UserDefaults.standard.set(false, forKey: "shouldLoadSnoops")
        UserDefaults.standard.synchronize()
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

  func loadIndexWithRefresh(_ index: Int) {
    activityTableView.isUserInteractionEnabled = false
    controlBar.isUserInteractionEnabled = false
    let uid = UserDefaults.standard.integer(forKey: "uid")
    if (index == 0) {
      tmpQuestions = []
      loadDataWithFilter("asker=\(uid)")
    }
    else if (index == 1) {
      tmpAnswers = []
      loadDataWithFilter("responder=\(uid)")
    }
    else {
      tmpSnoops = []
      loadDataWithFilter("uid=\(uid)")
    }
  }
}

// Private function
extension ActivityViewController {

  func refresh(_ sender: AnyObject) {
    activePlayerView?.closeView()
    loadIndexWithRefresh(selectedIndex)
  }

  func refreshAnswers() {
    loadIndexWithRefresh(1)
  }

  func setupSegmentedControl() {
    self.segmentedControl.isHidden = true
    view.addSubview(controlBar)

    // set up constraint
    let navigationBarHeight = self.navigationController?.navigationBar.frame.height
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let topMargin = navigationBarHeight! + statusBarHeight
    controlBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    controlBar.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin).isActive = true
    controlBar.bottomAnchor.constraint(equalTo: activityTableView.topAnchor).isActive = true
  }

  func setPlaceholderImages(_ cell: ActivityTableViewCell) {
    cell.coverImage.isUserInteractionEnabled = false
    cell.coverImage.image = UIImage()
    cell.askerImage.image = UIImage()
    cell.responderImage.image = UIImage()
  }

  func setupFullScreenImageSettings(_ cell: ActivityTableViewCell) {
    let askerTap = UITapGestureRecognizer(target: fullScreenImageView, action: #selector(fullScreenImageView.imageTapped))
    cell.askerImage.isUserInteractionEnabled = true;
    cell.askerImage.addGestureRecognizer(askerTap)
    let responderTap = UITapGestureRecognizer(target: fullScreenImageView, action: #selector(fullScreenImageView.imageTapped))
    cell.responderImage.isUserInteractionEnabled = true;
    cell.responderImage.addGestureRecognizer(responderTap)
  }

  func loadDataWithFilter(_ filterString: String) {
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)

    indicator.startAnimating()
    indicator.backgroundColor = UIColor.white
    activityTableView.backgroundView = nil
    questionModule.getActivities(filterString, selectedIndex: selectedIndex) { jsonArray in
      for activityInfo in jsonArray as! [[String:AnyObject]] {
        if (self.selectedIndex == 0) {
          let activity = ActivityModel(activityInfo, isSnoop: false)
          self.tmpQuestions.append(activity)
        }
        else if (self.selectedIndex == 1){
          let activity = ActivityModel(activityInfo, isSnoop: false)
          self.tmpAnswers.append(activity)
        }
        else {
          let activity = ActivityModel(activityInfo, isSnoop: true)
          self.tmpSnoops.append(activity)
        }
      }

      DispatchQueue.main.async {
        if (self.selectedIndex == 0) {
          self.questions = self.tmpQuestions
          if (UserDefaults.standard.bool(forKey: "shouldResetQuestionsBadge")) {
            self.tabBarController?.tabBar.items?[2].badgeValue = nil
            UserDefaults.standard.set(false, forKey: "shouldResetQuestionsBadge")
            UserDefaults.standard.synchronize()
          }
        }
        else if (self.selectedIndex == 1){
          self.answers = self.tmpAnswers
          if (UserDefaults.standard.bool(forKey: "shouldResetAnswersBadge")) {
            self.tabBarController?.tabBar.items?[2].badgeValue = nil
            UserDefaults.standard.set(false, forKey: "shouldResetAnswersBadge")
            UserDefaults.standard.synchronize()
          }
        }
        else {
          self.snoops = self.tmpSnoops
        }

        if (jsonArray.count > 0 || !filterString.contains("lastSeenId")) {
          self.activityTableView.reloadData()
        }

        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        self.activityTableView.isUserInteractionEnabled = true
        self.controlBar.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()
      }
    }
  }
}

// delegate
extension ActivityViewController: UITableViewDelegate, UITableViewDataSource, CustomTableBackgroundViewDelegate {

  func didTapButton(_ index: Int) {
    self.tabBarController?.selectedIndex = index
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

  func numberOfSections(in tableView: UITableView) -> Int {
    let frame = CGRect(x: 0, y: 0, width: activityTableView.frame.width, height: activityTableView.frame.height)
    let backgroundView = CustomTableBackgroundView(frame: frame)
    self.activityTableView.backgroundView = nil
    self.activityTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine

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

    activityTableView.separatorStyle = UITableViewCellSeparatorStyle.none
    backgroundView.delegate = self
    activityTableView.backgroundView = backgroundView
    return 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
      as! ActivityTableViewCell

    myCell.isUserInteractionEnabled = false
    var arrayCount = 0
    let uid = UserDefaults.standard.integer(forKey: "uid")
    var filterString = "&limit=10"
    let cellInfo: ActivityModel
    if (selectedIndex == 0) {
      cellInfo = questions[indexPath.row]
      arrayCount = questions.count
      filterString = "asker=\(uid)&lastSeenUpdatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }
    else if (selectedIndex == 1){
      cellInfo = answers[indexPath.row]
      arrayCount = answers.count
      filterString = "responder=\(uid)&lastSeenCreatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }
    else {
      cellInfo = snoops[indexPath.row]
      arrayCount = snoops.count
      filterString = "uid=\(uid)&lastSeenCreatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }

    myCell.rateLabel.text = "$ \(cellInfo.rate)"
    myCell.question.text = cellInfo.question
    myCell.responderName.text = cellInfo.responderName
    myCell.askerName.text = cellInfo.askerName + ":"

    if (!cellInfo.responderTitle.isEmpty) {
      myCell.responderTitle.text = cellInfo.responderTitle
    }

    setPlaceholderImages(myCell)
    setupFullScreenImageSettings(myCell)

    if let askerAvatarUrl = cellInfo.askerAvatarUrl {
      myCell.askerImage.sd_setImage(with: URL(string: askerAvatarUrl))
    }
    else {
      myCell.askerImage.image = UIImage(named: "default")
    }

    if let responderAvatarUrl = cellInfo.responderAvatarUrl {
      myCell.responderImage.sd_setImage(with: URL(string: responderAvatarUrl))
    }
    else {
      myCell.responderImage.image = UIImage(named: "default")
    }

    if (cellInfo.status == "PENDING") {
      myCell.coverImage.image = UIImage()
      myCell.coverImage.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
      myCell.coverImage.isUserInteractionEnabled = false
      myCell.durationLabel.isHidden = true
      myCell.expireLabel.isHidden = false
      if (cellInfo.hoursToExpire > 1) {
        myCell.expireLabel.text = "expires in \(cellInfo.hoursToExpire) hours"
      }
      else {
        myCell.expireLabel.text = "expires in \(cellInfo.hoursToExpire) hour"
      }
    }
    else if (cellInfo.status == "ANSWERED") {
      if let coverImageUrl = cellInfo.answerCoverUrl {
        myCell.coverImage.sd_setImage(with: URL(string: coverImageUrl))
        myCell.coverImage.isUserInteractionEnabled = true
        let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnImage(_:)))
        myCell.coverImage.addGestureRecognizer(tappedOnImage)

        myCell.durationLabel.text = "00:\(cellInfo.duration)"
        myCell.durationLabel.isHidden = false
        myCell.expireLabel.isHidden = true
      }
      else {
        myCell.coverImage.isUserInteractionEnabled = false
      }
    }

    myCell.isUserInteractionEnabled = true

    if (indexPath.row == arrayCount - 1) {
      loadDataWithFilter(filterString)
    }

    return myCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (selectedIndex == 1) {
      let cell = answers[indexPath.row]
      if (cell.status == "PENDING") {
        self.performSegue(withIdentifier: "segueFromActivityToAnswer", sender: indexPath)
      }
    }
  }

}

// UI triggered actions
extension ActivityViewController {
  func tappedOnImage(_ sender:UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.activityTableView)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.activityTableView.indexPathForRow(at: tapLocation)!

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
    let duration = questionInfo.duration
    self.activePlayerView = self.launchVideoPlayer(answerUrl, duration: duration)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "segueFromActivityToAnswer") {
      let indexPath = sender as! IndexPath
      let dvc = segue.destination as! AnswerViewController;
      let questionInfo = answers[indexPath.row]
      dvc.cellInfo = questionInfo
    }
  }
}
