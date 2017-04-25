//
//  ViewController.swift
//  Peep
//
//  Created by Bowen Zhang on 5/10/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {

  var questionModule = Question()
  var userModule = User()
  var generics = Generics()
  var coinModule = Coin()
  var utilityModule = UIUtility()

  var refreshControl: UIRefreshControl = UIRefreshControl()

  var paidSnoops: Set<Int> = []
  var activeIndexPath: IndexPath?

  var activePlayerView: VideoPlayerView?

  var coinCount = 0
  lazy var coinView: CoinButtonView = {
    let view = CoinButtonView(frame: CGRect(origin: .zero, size: CGSize(width: 55, height: 20)))
    return view
  }()

  lazy var blackView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.5)
    return view
  }()

  lazy var payWithCoinsView: PayWithCoinsView = {
    let view = PayWithCoinsView()
    view.layer.cornerRadius = 6
    view.clipsToBounds = true
    view.cancelButton.addTarget(self, action: #selector(cancelPayButtonTapped), for: .touchUpInside)
    view.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var buyCoinsView: BuyCoinsView = {
    let view = BuyCoinsView()
    view.layer.cornerRadius = 6
    view.clipsToBounds = true
    view.cancelButton.addTarget(self, action: #selector(cancelBuyButtonTapped), for: .touchUpInside)
    view.buyCoinsButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  @IBOutlet weak var feedTable: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var feeds:[FeedsModel] = []
  var tmpFeeds:[FeedsModel] = []

  let notificationName = "coinsAdded"

  deinit {
    NotificationCenter.default.removeObserver(self) // app might crash without removing observer
  }
}

// Override functions
extension ViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    feedTable.rowHeight = UITableViewAutomaticDimension
    feedTable.estimatedRowHeight = 130

    refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), for: .valueChanged)
    feedTable.addSubview(refreshControl)

    let logo = UIImage(named: "logo")
    let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 68, height: 20))
    logoView.contentMode = .scaleAspectFit
    logoView.image = logo
    self.navigationItem.titleView = logoView

    coinView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coinButtonTapped)))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: coinView)

    // We add the left button only to center the logo view in the nav bar.
    // We need a better solution later one
    let leftButton = UIButton()
    leftButton.frame = CGRect(origin: .zero, size: CGSize(width: 55, height: 20))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)

    NotificationCenter.default.addObserver(self, selector: #selector(self.addCoins(_:)), name: NSNotification.Name(rawValue: self.notificationName), object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    let isUserSignedUp = UserDefaults.standard.bool(forKey: "isUserSignedUp")
    if (!isUserSignedUp) {
      let vc = UINavigationController(rootViewController: WelcomeViewController())
      self.present(vc, animated: true, completion: nil)
    }

    let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    if (!isUserLoggedIn){
      let vc = UINavigationController(rootViewController: LoginViewController())
      self.present(vc, animated: true, completion: nil)
    }
    else {
      if (feeds.count == 0){
        loadData()
        loadCoinCount()
      }
      else {
        if (UserDefaults.standard.object(forKey: "shouldLoadHome") == nil ||
          UserDefaults.standard.bool(forKey: "shouldLoadHome") == true) {
          UserDefaults.standard.set(false, forKey: "shouldLoadHome")
          UserDefaults.standard.synchronize()
          loadData()
          loadCoinCount()
        }
      }
    }
  }
}

// Private function
extension ViewController {

  func loadCoinCount() {
    coinModule.getCoinsCount() { result in
      let coinCount = result["amount"] as! Int
      self.coinCount = coinCount
      DispatchQueue.main.async {
        self.loadCoinCount(coinCount)
      }
    }
  }

  func loadCoinCount(_ count: Int) {
    self.coinView.setCount(count)
  }

  func addCoins(_ notification: Notification) {
    if let uid = notification.userInfo?["uid"] as? String {
      let currentUid = UserDefaults.standard.string(forKey: "uid")!
      // Check if these two are the same user if app relaunches or user signs out.
      if (currentUid == uid) {
        if let amount = notification.userInfo?["amount"] as? Int {
          self.coinCount += amount
          loadCoinCount(coinCount)
        }
      }
    }
  }

  func refresh(_ sender:AnyObject) {
    loadData()
  }

  func loadData(){
    let uid = UserDefaults.standard.integer(forKey: "uid")
    let url = "uid=" + "\(uid)"
    tmpFeeds = []
    self.paidSnoops = []
    loadData(url)
  }

  func loadData(_ url: String!) {
    feedTable.isUserInteractionEnabled = false
    activityIndicator.startAnimating()
    let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    let myUrl = URL(string: generics.HTTPHOST + "newsfeeds?" + encodedUrl!)
    generics.getFilteredObjects(myUrl!) { jsonArray in
      for feedInfo in jsonArray as! [[String:AnyObject]] {
        let questionId = feedInfo["id"] as! Int
        let question = feedInfo["question"] as! String
        let responderId = feedInfo["responderId"] as! Int
        let numberOfSnoops = feedInfo["snoops"] as! Int
        let name = feedInfo["responderName"] as! String
        let updatedTime = feedInfo["updatedTime"] as! Double

        var title = ""
        if (feedInfo["responderTitle"] != nil) {
          title = feedInfo["responderTitle"] as! String
        }

        let responderAvatarUrl = feedInfo["responderAvatarUrl"] as? String
        let askerAvatarUrl = feedInfo["askerAvatarUrl"] as? String
        let coverUrl = feedInfo["answerCoverUrl"] as? String
        let answerUrl = feedInfo["answerUrl"] as? String

        let duration = feedInfo["duration"] as! Int
        let rate = feedInfo["rate"] as! Int
        self.tmpFeeds.append(FeedsModel(_name: name, _title: title, _id: questionId, _question: question, _status: "ANSWERED", _responderId: responderId, _snoops: numberOfSnoops, _updatedTime: updatedTime,  _duration: duration, _responderAvatarUrl: responderAvatarUrl, _askerAvatarUrl: askerAvatarUrl, _coverUrl: coverUrl, _answerUrl: answerUrl!, _rate: rate))
      }

      self.feeds = self.tmpFeeds
      DispatchQueue.main.async {
        self.activityIndicator.stopAnimating()
        // reload table only if there is additonal data or when we are loading the first batch
        if (jsonArray.count > 0 || !String(describing: myUrl).contains("lastSeenId")) {
          self.feedTable.reloadData()
        }
        self.feedTable.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()
      }
    }
  }

  func setPlaceholderImages(_ myCell: FeedTableViewCell) {
    myCell.askerImage.isUserInteractionEnabled = false
    myCell.coverImage.isUserInteractionEnabled = false
    myCell.responderImage.isUserInteractionEnabled = false
    myCell.askerImage.image = UIImage(named: "default")
    myCell.responderImage.image = UIImage(named: "deafult")
    myCell.coverImage.image = UIImage()
  }
}

// Delegate methods
extension ViewController : UITableViewDataSource, UITableViewDelegate {

  func numberOfSections(in tableView: UITableView) -> Int {
    let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.feedTable.bounds.size.width,
      height: self.feedTable.bounds.size.height))
    self.feedTable.backgroundView = nil
    self.feedTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine

    if (feeds.count == 0) {
      noDataLabel.text = "You have no news feeds yet."
    }
    else {
      return 1
    }

    noDataLabel.textColor = UIColor.gray
    noDataLabel.textAlignment = NSTextAlignment.center
    self.feedTable.separatorStyle = UITableViewCellSeparatorStyle.none
    self.feedTable.backgroundView = noDataLabel

    return 0
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return feeds.count
  }


  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedTableViewCell
    myCell.isUserInteractionEnabled = false

    let feedInfo = feeds[indexPath.row]
    myCell.nameLabel.text = feedInfo.name


    myCell.questionLabel.text = feedInfo.question
    myCell.numOfSnoops.text = String(feedInfo.snoops)

    if (feedInfo.title.isEmpty) {
      myCell.titleLabel.text = ""
    }
    else {
      myCell.titleLabel.text = feedInfo.title
    }

    // setup rate label
    if (self.paidSnoops.contains(feedInfo.id)) {
      myCell.lockImage.image = UIImage(named: "unlocked")
    }
    else {
      if (feedInfo.rate > 0) {
        myCell.lockImage.image = UIImage(named: "lock")
      }
      else {
        myCell.lockImage.image = UIImage(named: "unlocked")
      }
    }

    setPlaceholderImages(myCell)
    if (feedInfo.status == "PENDING") {
      myCell.coverImage.isUserInteractionEnabled = false
      myCell.coverImage.image = UIImage()
    }
    else {
      if let coverUrl = feedInfo.coverUrl {
        myCell.coverImage.sd_setImage(with: URL(string: coverUrl))
      }
      myCell.coverImage.isUserInteractionEnabled = true
      myCell.durationLabel.text = "00:\(feedInfo.duration)"
      myCell.durationLabel.isHidden = false

      if (self.paidSnoops.contains(feedInfo.id)) {
        let tappedToWatch = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedToWatch(_:)))
        myCell.coverImage.addGestureRecognizer(tappedToWatch)
      }
      else {
        let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedOnImage(_:)))
        myCell.coverImage.addGestureRecognizer(tappedOnImage)
      }
    }

    // set profile image
    if let responderAvatarUrl = feedInfo.responderAvatarUrl {
      myCell.responderImage.sd_setImage(with: URL(string: responderAvatarUrl))
    }

    if let askerAvatarUrl = feedInfo.askerAvatarUrl {
      myCell.askerImage.sd_setImage(with: URL(string: askerAvatarUrl))
    }

    myCell.responderImage.isUserInteractionEnabled = true
    let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedOnProfile(_:)))
    myCell.responderImage.addGestureRecognizer(tappedOnImage)

    myCell.isUserInteractionEnabled = true

    if (indexPath.row == feeds.count - 1) {
      let lastSeenId = feeds[indexPath.row].id
      let updatedTime = Int64(feeds[indexPath.row].updatedTime)
      let uid = UserDefaults.standard.integer(forKey: "uid")
      let url = "uid=" + "\(uid)" + "&lastSeenUpdatedTime=\(updatedTime)&lastSeenId=\(lastSeenId)&limit=5"
      loadData(url)
    }

    return myCell
  }
}

// Segue action
extension ViewController {

  func coinButtonTapped() {
    let vc = CoinsViewController()
    vc.numOfCoins = self.coinCount
    vc.homeViewController = self
    self.present(vc, animated: true, completion: nil)
  }

  func confirmButtonTapped() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
    }) { (result) in
      let uid = UserDefaults.standard.integer(forKey: "uid")
      let quandaId = self.feeds[self.activeIndexPath!.row].id
      let quandaData: [String:AnyObject] = ["id": quandaId as AnyObject]
      let jsonData: [String:AnyObject] = ["uid": uid as AnyObject, "type": "SNOOPED" as AnyObject, "quanda": quandaData as AnyObject]
      self.generics.createObject(self.generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
        if (result.isEmpty) {
          DispatchQueue.main.async {
            self.paidSnoops.insert(quandaId)
            self.feedTable.reloadRows(at: [self.activeIndexPath!], with: .none)
          }
        }
        else {
          DispatchQueue.main.async {
            self.utilityModule.displayAlertMessage("there is an error processing your payment. Please try later", title: "Error", sender: self)
          }
        }
      }
    }
  }

  func buyButtonTapped() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.buyCoinsView.alpha = 0
    }) { (result) in
      DispatchQueue.main.async {
        self.coinButtonTapped()
      }
    }
  }

  func cancelPayButtonTapped() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
      }, completion: nil)
  }

  func cancelBuyButtonTapped() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.buyCoinsView.alpha = 0
      }, completion: nil)
  }

  func tappedOnProfile(_ sender:UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.feedTable)
    let indexPath = self.feedTable.indexPathForRow(at: tapLocation)!
    let responderId = self.feeds[indexPath.row].responderId
    self.userModule.getProfile(responderId) {name, title, about, avatarUrl, rate, _ in
      let discoverModel = DiscoverModel(_name: name, _title: title, _uid: responderId, _about: about, _rate: rate, _updatedTime: 0, _avatarUrl: avatarUrl)
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: "homeToAsk", sender: discoverModel)
      }
    }
  }

  func tappedToWatch(_ sender:UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.feedTable)

    //using the tapLocation, we retrieve the corresponding indexPath
    let indexPath = self.feedTable.indexPathForRow(at: tapLocation)!

    let questionInfo = feeds[indexPath.row]
    let answerUrl = questionInfo.answerUrl
    let duration = questionInfo.duration

    self.activePlayerView = self.launchVideoPlayer(answerUrl, duration: duration)
    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
      // block base observer has retain cycle issue, remember to unregister observer in deinit
      self.activePlayerView?.reset()
    }
  }

  func tappedOnImage(_ sender: UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.feedTable)
    let indexPath = self.feedTable.indexPathForRow(at: tapLocation)!
    let feed = feeds[indexPath.row]
    self.activeIndexPath = indexPath
    if let window = UIApplication.shared.keyWindow {
      window.addSubview(blackView)
      blackView.frame = window.frame
      var frameToAdd: UIView!
      if (self.coinCount < 8 && feed.rate > 0) {
        buyCoinsView.setNote("8 coins to unlock an answer")
        frameToAdd = buyCoinsView
      }
      else if (feed.rate == 0) {
        payWithCoinsView.setCount(0)
        frameToAdd = payWithCoinsView
      }
      else {
        payWithCoinsView.setCount(8)
        frameToAdd = payWithCoinsView
      }

      window.addSubview(frameToAdd)
      frameToAdd.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
      frameToAdd.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
      frameToAdd.widthAnchor.constraint(equalToConstant: 260).isActive = true
      frameToAdd.heightAnchor.constraint(equalToConstant: 176).isActive = true
      blackView.alpha = 0
      frameToAdd.alpha = 0
      UIView.animate(withDuration: 0.5, animations: {
        self.blackView.alpha = 1
        frameToAdd.alpha = 1
      })
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "homeToAsk") {
      let dvc = segue.destination as! AskViewController
      let profileInfo = sender as! DiscoverModel
      dvc.profileInfo = profileInfo
    }
  }

  @IBAction func unwindSegueToHome(_ segue: UIStoryboardSegue) {
  }
}


