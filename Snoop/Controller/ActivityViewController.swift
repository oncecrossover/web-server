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
  var socialGateway: SocialGateway!
  var shareActionSheet: ShareActionSheet!
  @IBOutlet weak var activityTableView: UITableView!

  @IBOutlet weak var segmentedControl: UIView!
  var userModule = User()
  var questionModule = Question()
  var utility = UIUtility()
  var generics = Generics()
  var thumbProxy = ThumbProxy()
  var qaStatProxy = QaStatProxy()

  var questions: [ActivityModel] = []
  var answers: [ActivityModel] = []
  var snoops: [ActivityModel] = []
  var questionsQaStats:[QaStatModel] = []
  var answersQaStats:[QaStatModel] = []
  var snoopsQaStats:[QaStatModel] = []

  var tmpQuestions: [ActivityModel] = []
  var tmpAnswers: [ActivityModel] = []
  var tmpSnoops: [ActivityModel] = []
  var tmpQuestionsQaStats:[QaStatModel] = []
  var tmpAnswersQaStats:[QaStatModel] = []
  var tmpSnoopsQaStats:[QaStatModel] = []

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

  lazy var permissionView: PermissionView = {
    let view = PermissionView()
    view.setHeader("Allow vInsider to access your photos")
    view.setInstruction("1. Open iPhone Settings \n2. Tap Privacy \n3. Tap Photos \n4. Set vInsider to ON")
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
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
    socialGateway = SocialGateway(hostingController: self, permissionAlert: self.permissionView)
    shareActionSheet = ShareActionSheet(socialGateway)
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
    let uid = UserDefaults.standard.string(forKey: "uid")
    if (index == 0) {
      tmpQuestions = []
      tmpQuestionsQaStats = []
      loadDataWithFilter("asker=\(uid!)")
    }
    else if (index == 1) {
      tmpAnswers = []
      tmpAnswersQaStats = []
      loadDataWithFilter("responder=\(uid!)")
    }
    else {
      tmpSnoops = []
      tmpSnoopsQaStats = []
      loadDataWithFilter("uid=\(uid!)")
    }
  }
}

// Private function
extension ActivityViewController {

  @objc func refresh(_ sender: AnyObject) {
    activePlayerView?.closeView()
    loadIndexWithRefresh(selectedIndex)
  }

  @objc func refreshAnswers() {
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
    var qaStatFilter = ""
    questionModule.getActivities(filterString, selectedIndex: selectedIndex) { jsonEntries in
      for jsonEntry in jsonEntries as! [[String:AnyObject]] {
        var questionId = ""
        if (self.selectedIndex == 0) {
          questionId = jsonEntry["id"] as! String
          let activity = ActivityModel(jsonEntry, isSnoop: false)
          self.tmpQuestions.append(activity)
        }
        else if (self.selectedIndex == 1){
          questionId = jsonEntry["id"] as! String
          let activity = ActivityModel(jsonEntry, isSnoop: false)
          self.tmpAnswers.append(activity)
        }
        else {
          questionId = jsonEntry["quandaId"] as! String
          let activity = ActivityModel(jsonEntry, isSnoop: true)
          self.tmpSnoops.append(activity)
        }
        qaStatFilter += "quandaId=\(questionId)&"
      }

      // load qa stats data
      qaStatFilter += "uid=\(self.getUid())"
      self.qaStatProxy.getQaStats(qaStatFilter) {
        qaStatEntries in

        for qaStatEntry in qaStatEntries as! [[String:AnyObject]] {
          if (self.selectedIndex == 0) {
            self.tmpQuestionsQaStats.append(QaStatModel(qaStatEntry))
          } else if (self.selectedIndex == 1) {
            self.tmpAnswersQaStats.append(QaStatModel(qaStatEntry))
          } else {
            self.tmpSnoopsQaStats.append(QaStatModel(qaStatEntry))
          }
        }

        DispatchQueue.main.async {
          if (self.selectedIndex == 0) {
            self.questions = self.tmpQuestions
            self.questionsQaStats = self.tmpQuestionsQaStats
            if (UserDefaults.standard.bool(forKey: "shouldResetQuestionsBadge")) {
              self.tabBarController?.tabBar.items?[2].badgeValue = nil
              UserDefaults.standard.set(false, forKey: "shouldResetQuestionsBadge")
              UserDefaults.standard.synchronize()
            }
          }
          else if (self.selectedIndex == 1){
            self.answers = self.tmpAnswers
            self.answersQaStats = self.tmpAnswersQaStats
            if (UserDefaults.standard.bool(forKey: "shouldResetAnswersBadge")) {
              self.tabBarController?.tabBar.items?[2].badgeValue = nil
              UserDefaults.standard.set(false, forKey: "shouldResetAnswersBadge")
              UserDefaults.standard.synchronize()
            }
          }
          else {
            self.snoops = self.tmpSnoops
            self.snoopsQaStats = self.tmpSnoopsQaStats
          }

          if (jsonEntries.count > 0 || !filterString.contains("lastSeenId")) {
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

  func isAnswerOrSnoopSegmentSelected() -> Bool {
    return self.selectedIndex == 1 || self.selectedIndex == 2;
  }

  /**
   * Setup asker info, e.g. name and avatar
   */
  func setupAskerInfo(_ myCell: ActivityTableViewCell, myCellInfo: ActivityModel) {
    /* show or hide real name */
    myCell.askerName.text =
      (myCellInfo.isAskerAnonymous && isAnswerOrSnoopSegmentSelected() ? "Anonymous" : myCellInfo.askerName) + ":"

    /* show or hide real avartar */
    if (myCellInfo.askerAvatarUrl != nil
      && (!myCellInfo.isAskerAnonymous || !isAnswerOrSnoopSegmentSelected())) {
      myCell.askerImage.sd_setImage(with: URL(string: myCellInfo.askerAvatarUrl!))
    } else {
      myCell.askerImage.cosmeticizeImage(cosmeticHints: myCell.askerName.text)
    }
  }
}

/**
 * Setup responder info, e.g. name and avatar
 */
func setupResponderInfo(_ myCell: ActivityTableViewCell, myCellInfo: ActivityModel) {
  myCell.responderName.text = myCellInfo.responderName
  myCell.responderTitle.text = myCellInfo.responderTitle

  if let responderAvatarUrl = myCellInfo.responderAvatarUrl {
    myCell.responderImage.sd_setImage(with: URL(string: responderAvatarUrl))
  }
  else {
    myCell.responderImage.cosmeticizeImage(cosmeticHints: myCellInfo.responderName)
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

    myCell.actionSheetButton.tag = indexPath.row
    myCell.actionSheetButton.addTarget(self, action: #selector(tappedOnActionSheetButton(_:)), for: .touchUpInside)

    myCell.isUserInteractionEnabled = false

    let qaStat: QaStatModel
    var arrayCount = 0
    let uid = UserDefaults.standard.string(forKey: "uid")
    var filterString = "&limit=10"
    let cellInfo: ActivityModel
    if (selectedIndex == 0) {
      cellInfo = questions[indexPath.row]
      qaStat = questionsQaStats[indexPath.row]
      arrayCount = questions.count
      filterString = "asker=\(uid!)&lastSeenUpdatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }
    else if (selectedIndex == 1){
      cellInfo = answers[indexPath.row]
      qaStat = answersQaStats[indexPath.row]
      arrayCount = answers.count
      filterString = "responder=\(uid!)&lastSeenCreatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }
    else {
      cellInfo = snoops[indexPath.row]
      qaStat = snoopsQaStats[indexPath.row]
      arrayCount = snoops.count
      filterString = "uid=\(uid!)&lastSeenCreatedTime=\(Int64(cellInfo.lastSeenTime))&lastSeenId=\(cellInfo.id)" + filterString
    }

    myCell.rateLabel.text = "$ \(cellInfo.rate)"
    myCell.question.text = cellInfo.question

    setPlaceholderImages(myCell)
    setupFullScreenImageSettings(myCell)
    setupAskerInfo(myCell, myCellInfo: cellInfo);
    setupResponderInfo(myCell, myCellInfo: cellInfo);

    if (cellInfo.status == "PENDING") {
      myCell.coverImage.image = UIImage()
      myCell.coverImage.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
      myCell.coverImage.isUserInteractionEnabled = false
      myCell.durationLabel.isHidden = true
      myCell.expireLabel.isHidden = false
      if (cellInfo.hoursToExpire > 1) {
        myCell.expireLabel.text = "expire in \(cellInfo.hoursToExpire) hrs"
      }
      else {
        myCell.expireLabel.text = "expire in \(cellInfo.hoursToExpire) hr"
      }

      // setup thumb up/down
      myCell.thumbupImage.isUserInteractionEnabled = false
      myCell.thumbdownImage.isUserInteractionEnabled = false
    }
    else if (cellInfo.status == "ANSWERED") {
      if let coverImageUrl = cellInfo.answerCoverUrl {
        myCell.coverImage.sd_setImage(with: URL(string: coverImageUrl))
        myCell.coverImage.isUserInteractionEnabled = true
        let tappedOnCoverImage = UITapGestureRecognizer(target: self, action: #selector(ActivityViewController.tappedOnCoverImage(_:)))
        myCell.coverImage.addGestureRecognizer(tappedOnCoverImage)

        myCell.durationLabel.text = cellInfo.duration.toTimeFormat()
        myCell.durationLabel.isHidden = false
        myCell.expireLabel.isHidden = true
      }
      else {
        myCell.coverImage.isUserInteractionEnabled = false
      }

      // setup thumb up/down
      myCell.thumbupImage.isUserInteractionEnabled = true
      myCell.thumbdownImage.isUserInteractionEnabled = true
      let tappedToThumbup = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedToThumbup(_:)))
      myCell.thumbupImage.addGestureRecognizer(tappedToThumbup)
      let tappedToThumbdown = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedToThumbdown(_:)))
      myCell.thumbdownImage.addGestureRecognizer(tappedToThumbdown)
    }

    // setup qa stats
    setupQaStats(myCell, qaStat: qaStat)
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
  @objc func tappedOnActionSheetButton(_ sender: UIButton!) {
    /* get answer media info */
    let forModel = getQuestionInfo(sender.tag)
    let actionSheet = shareActionSheet.createSheet(forModel: forModel)
    present(actionSheet, animated: true, completion: nil)
  }

  func getQuestionInfo(_ indexPath: IndexPath) -> ActivityModel {
    return getQuestionInfo(indexPath.row)
  }

  func getQuestionInfo(_ row: Int) -> ActivityModel {
    let questionInfo:ActivityModel

    if (selectedIndex == 0) {
      questionInfo = questions[row]
    }
    else if (selectedIndex == 1) {
      questionInfo = answers[row]
    }
    else {
      questionInfo = snoops[row]
    }
    return questionInfo;
  }

  @objc func tappedOnCoverImage(_ sender:UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.activityTableView)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.activityTableView.indexPathForRow(at: tapLocation)!


    let questionInfo = getQuestionInfo(indexPath)
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

  func getUid() -> String {
    return UserDefaults.standard.string(forKey: "uid")!
  }

  func getQaStat(_ tapIndexpath: IndexPath) -> QaStatModel {
    if (self.selectedIndex == 0) {
      return questionsQaStats[tapIndexpath.row]
    } else if (self.selectedIndex == 1) {
      return answersQaStats[tapIndexpath.row]
    } else {
      return snoopsQaStats[tapIndexpath.row]
    }
  }

  func setQaStat(_ tapIndexpath: IndexPath, qaStat: QaStatModel) {
    if (self.selectedIndex == 0) {
      questionsQaStats[tapIndexpath.row] = qaStat
    } else if (self.selectedIndex == 1) {
      answersQaStats[tapIndexpath.row] = qaStat
    } else {
      snoopsQaStats[tapIndexpath.row] = qaStat
    }
  }

  @objc func tappedToThumbup(_ sender:UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.activityTableView)
    let tapIndexpath = self.activityTableView.indexPathForRow(at: tapLocation)!
    let qaStat = getQaStat(tapIndexpath)

    // allow either thumbupped or thumbdowned
    let upped = qaStat.thumbupped.toBool() ? Bool.FALSE_STR : Bool.TRUE_STR
    let downed = upped.toBool() && qaStat.thumbdowned.toBool() ? Bool.FALSE_STR : qaStat.thumbdowned
    tappedToThumb(tapIndexpath, upped: upped, downed: downed)
  }

  @objc func tappedToThumbdown(_ sender:UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.activityTableView)
    let tapIndexpath = self.activityTableView.indexPathForRow(at: tapLocation)!
    let qaStat = getQaStat(tapIndexpath)

    // allow either thumbupped or thumbdowned
    let downed = qaStat.thumbdowned.toBool() ? Bool.FALSE_STR : Bool.TRUE_STR
    let upped = downed.toBool() && qaStat.thumbupped.toBool() ? Bool.FALSE_STR : qaStat.thumbupped
    tappedToThumb(tapIndexpath, upped: upped, downed: downed)
  }

  func tappedToThumb (_ tapIndexpath: IndexPath, upped: String, downed: String) {
    let qaStat = getQaStat(tapIndexpath)
    let myCell = self.activityTableView.cellForRow(at: tapIndexpath) as! ActivityTableViewCell

    thumbProxy.createUserThumb(getUid(), quandaId: qaStat.id, upped: upped, downed: downed) {
      result in

      if (result.isEmpty) { // request succeeds
        // sync QaStat
        let qaStatFilter = "quandaId=\(qaStat.id)&uid=\(self.getUid())"
        self.qaStatProxy.getQaStats(qaStatFilter) {
          qaStatEntries in

          for qaStatEntry in qaStatEntries as! [[String:AnyObject]] {
            self.setQaStat(tapIndexpath, qaStat: QaStatModel(qaStatEntry))
            break
          }

          // update UI
          DispatchQueue.main.async {
            self.setupQaStats(myCell, qaStat: self.getQaStat(tapIndexpath))
          }
        }
      }
    }
  }

  func setupQaStats(_ myCell: ActivityTableViewCell, qaStat: QaStatModel) {
    // setup thumb up
    if qaStat.thumbupped.toBool() {
      myCell.thumbupImage.image = UIImage(named: "thumbup-tapped")
    } else {
      myCell.thumbupImage.image = UIImage(named: "thumbup-normal")
    }
    myCell.thumbups.text = String(qaStat.thumbups)

    // setup thumb down
    if qaStat.thumbdowned.toBool() {
      myCell.thumbdownImage.image = UIImage(named: "thumbdown-tapped")
    } else {
      myCell.thumbdownImage.image = UIImage(named: "thumbdown-normal")
    }
    myCell.thumbdowns.text =  String(qaStat.thumbdowns)

    // setup #snoops
    myCell.numOfSnoops.text = String(qaStat.snoops)
  }
}
