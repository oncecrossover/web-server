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
import Siren

class ViewController: UIViewController {

  var socialGateway: SocialGateway!
  var shareActionSheet: ShareActionSheet!
  lazy var questionModule = Question()
  lazy var userModule = User()
  lazy var generics = Generics()
  lazy var coinModule = Coin()
  lazy var utilityModule = UIUtility()
  lazy var thumbProxy = ThumbProxy()
  lazy var qaStatProxy = QaStatProxy()
  lazy var promoProxy = PromoProxy()

  var refreshControl: UIRefreshControl = UIRefreshControl()
  var fullScreenImageView : FullScreenImageView = FullScreenImageView()
  lazy var permissionView: PermissionView = {
    let view = PermissionView()
    view.setHeader("Allow vInsider to access your photos")
    view.setInstruction("1. Open iPhone Settings \n2. Tap Privacy \n3. Tap Photos \n4. Set vInsider to ON")
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  var paidSnoops: Set<String> = []
  var activeIndexPath: IndexPath?

  var activePlayerView: VideoPlayerView?

  var coinCount = 0

  var customNavigationBar: CustomNavigationView?

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

  lazy var freeCoinsView: FreeCoinsView = {
    let view = FreeCoinsView()
    view.layer.cornerRadius = 6
    view.clipsToBounds = true
    view.claimButton.addTarget(self, action: #selector(claimButtonTapped), for: .touchUpInside)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.promoCodeTextField.addTarget(self, action: #selector(promoCodeTextFieldDidChange(_:)), for: .editingChanged)
    view.promoCodeTextField.delegate = view
    return view
  }()

  lazy var coinView: CoinButtonView = {
    let view = CoinButtonView(frame: CGRect(origin: .zero, size: CGSize(width: 55, height: 20)))
    return view
  }()

  @IBOutlet weak var feedTable: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var qaStats:[QaStatModel] = []
  var tmpQaStats:[QaStatModel] = []
  var feeds:[FeedModel] = []
  var tmpFeeds:[FeedModel] = []

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

    NotificationCenter.default.addObserver(self, selector: #selector(self.addCoins(_:)), name: NSNotification.Name(rawValue: self.notificationName), object: nil)
    socialGateway = SocialGateway(hostingController: self, permissionAlert: self.permissionView)
    shareActionSheet = ShareActionSheet(socialGateway)
  }

  override func viewDidAppear(_ animated: Bool) {
    // Check if we want to display welcome video page
    if (!UserDefaults.standard.bool(forKey: "isUserWelcomed")) {
      let vc = UINavigationController(rootViewController: WelcomeViewController())
      self.present(vc, animated: true, completion: nil)
    }

    // Check if we want to display
    let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    if (!isUserLoggedIn){
      let vc = UINavigationController(rootViewController: LoginViewController())
      self.present(vc, animated: true, completion: nil)
    }
    else {
      guard Siren.shared.isUpdateBackCompatible() == true else {
        return
      }

      coinView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coinButtonTapped)))
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: coinView)

      // We add the left button only to center the logo view in the nav bar.
      // We need a better solution later one
      let leftButton = UIButton()
      leftButton.frame = CGRect(origin: .zero, size: CGSize(width: 55, height: 20))
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)

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

      if (UserDefaults.standard.bool(forKey: "shouldGiftUser")) {
        displayFreeCoinsView()
        UserDefaults.standard.set(false, forKey: "shouldGiftUser")
        UserDefaults.standard.synchronize()
      }

      NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
        // block base observer has retain cycle issue, remember to unregister observer in deinit
        self.activePlayerView?.reset()
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
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

  @objc func addCoins(_ notification: Notification) {
    if let uid = notification.userInfo?["uid"] as? String {
      let currentUid = UserDefaults.standard.string(forKey: "uid")
      // Check if these two are the same user if app relaunches or user signs out.
      if (currentUid == uid) {
        if let amount = notification.userInfo?["amount"] as? Int {
          self.coinCount += amount
          loadCoinCount(coinCount)
        }
      }
    }
  }

  @objc func refresh(_ sender:AnyObject) {
    loadCoinCount()
    loadData()
  }

  func loadData(){
    let uid = UserDefaults.standard.string(forKey: "uid")
    let url = "uid=" + "\(uid!)"
    tmpFeeds = []
    tmpQaStats = []
    self.paidSnoops = []
    loadData(url)
  }

  func loadData(_ url: String!) {
    // load feeds data
    feedTable.isUserInteractionEnabled = false
    activityIndicator.startAnimating()
    let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    let feedQueryUrl = URL(string: generics.HTTPHOST + "newsfeeds?" + encodedUrl!)
    var qaStatFilter = ""
    generics.getFilteredObjects(feedQueryUrl!) { jsonEntries in
      for jsonEntry in jsonEntries as! [[String:AnyObject]] {
        let questionId = jsonEntry["id"] as! String
        self.tmpFeeds.append(FeedModel(jsonEntry))
        qaStatFilter += "quandaId=\(questionId)&"
      }
      self.feeds = self.tmpFeeds

      // load qa stats data
      qaStatFilter += "uid=\(self.getUid())"
      self.qaStatProxy.getQaStats(qaStatFilter) {
        qaStatEntries in

        for qaStatEntry in qaStatEntries as! [[String:AnyObject]] {
          self.tmpQaStats.append(QaStatModel(qaStatEntry))
        }
        self.qaStats = self.tmpQaStats

        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          // reload table only if there is additonal data or when we are loading the first batch
          if (jsonEntries.count > 0 || !String(describing: feedQueryUrl).contains("lastSeenId")) {
            self.feedTable.reloadData()
          }
          self.feedTable.isUserInteractionEnabled = true
          self.refreshControl.endRefreshing()
        }
      }
    }
  }

  func setupQaStats(_ myCell: FeedTableViewCell, qaStat: QaStatModel) {
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

  func setupFullScreenImageSettings(_ myCell: FeedTableViewCell) {
    let tap = UITapGestureRecognizer(target: fullScreenImageView, action: #selector(fullScreenImageView.imageTapped))
    myCell.askerImage.isUserInteractionEnabled = true;
    myCell.askerImage.addGestureRecognizer(tap)
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

  /**
   * Setup asker info, e.g. name and avatar
   */
  func setupAskerInfo(_ myCell: FeedTableViewCell, myFeedInfo: FeedModel) {
    /* show or hide real name */
    myCell.askerName.text = myFeedInfo.isAskerAnonymous ? "Anonymous" : myFeedInfo.askerName;

    /* show or hide real avartar */
    if (myFeedInfo.askerAvatarUrl != nil && !myFeedInfo.isAskerAnonymous) {
      myCell.askerImage.sd_setImage(with: URL(string: myFeedInfo.askerAvatarUrl!));
    } else {
      myCell.askerImage.cosmeticizeImage(cosmeticHints: myCell.askerName.text)
    }
  }

  /**
   * Setup responder info, e.g. name and avatar
   */
  func setupResponderInfo(_ myCell: FeedTableViewCell, myFeedInfo: FeedModel) {
    myCell.nameLabel.text = myFeedInfo.responderName
    myCell.titleLabel.text = myFeedInfo.responderTitle.isEmpty ? "" : myFeedInfo.responderTitle;

    if let responderAvatarUrl = myFeedInfo.responderAvatarUrl {
      myCell.responderImage.sd_setImage(with: URL(string: responderAvatarUrl))
    } else {
      myCell.responderImage.cosmeticizeImage(cosmeticHints: myFeedInfo.responderName)
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedTableViewCell
    let feedInfo = feeds[indexPath.row]
    let qaStat = qaStats[indexPath.row]
    myCell.isUserInteractionEnabled = false

    // setup action sheet
    myCell.actionSheetButton.tag = indexPath.row
    myCell.actionSheetButton.addTarget(self, action: #selector(tappedOnActionSheetButton(_:)), for: .touchUpInside)

    // setup question and #snoops
    myCell.questionLabel.text = feedInfo.question

    // setup play/lock buttoon
    if(self.isQuandaFreeOrUnlocked(feedInfo)) {
      myCell.playImage.image = UIImage(named: "play")
    }
    else {
      myCell.playImage.image = UIImage(named: "lock")
    }

    // setup various images
    setPlaceholderImages(myCell)
    setupFullScreenImageSettings(myCell)

    if (feedInfo.status == "PENDING") {
      // setup UI status for PENDING
      myCell.coverImage.image = UIImage()
      myCell.coverImage.isUserInteractionEnabled = false
      myCell.thumbupImage.isUserInteractionEnabled = false
      myCell.thumbdownImage.isUserInteractionEnabled = false
      myCell.freeForHours.isHidden = true
    }
    else { // ANSWERED
      // setup UI status for ANSWERED
      if let coverUrl = feedInfo.coverUrl {
        myCell.coverImage.sd_setImage(with: URL(string: coverUrl))
      }
      myCell.coverImage.isUserInteractionEnabled = true
      myCell.thumbupImage.isUserInteractionEnabled = true
      myCell.thumbdownImage.isUserInteractionEnabled = true

      // setup duration
      myCell.durationLabel.text = feedInfo.duration.toTimeFormat()
      myCell.durationLabel.isHidden = false

      // setup various actions
      let tappedToWatch = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedToWatch(_:)))
      myCell.coverImage.addGestureRecognizer(tappedToWatch)
      let tappedToThumbup = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedToThumbup(_:)))
      myCell.thumbupImage.addGestureRecognizer(tappedToThumbup)
      let tappedToThumbdown = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedToThumbdown(_:)))
      myCell.thumbdownImage.addGestureRecognizer(tappedToThumbdown)

      // setup limited free
      if(feedInfo.freeForHours > 1) {
        myCell.freeForHours.text = "free for \(feedInfo.freeForHours) hrs"
      } else {
        myCell.freeForHours.text = "free for \(feedInfo.freeForHours) hr"
      }
      myCell.freeForHours.isHidden = isLimitedFree(feedInfo) ? false : true
    }

    // setup asker/responder info
    setupAskerInfo(myCell, myFeedInfo: feedInfo);
    setupResponderInfo(myCell, myFeedInfo: feedInfo);

    // setup avatar tap action
    myCell.responderImage.isUserInteractionEnabled = true
    let tappedOnProfile = UITapGestureRecognizer(target: self, action: #selector(ViewController.tappedOnProfile(_:)))
    myCell.responderImage.addGestureRecognizer(tappedOnProfile)

    myCell.isUserInteractionEnabled = true

    // load more data
    if (indexPath.row == feeds.count - 1) {
      let lastSeenId = feeds[indexPath.row].id
      let updatedTime = Int64(feeds[indexPath.row].updatedTime)
      let uid = UserDefaults.standard.string(forKey: "uid")
      let url = "uid=" + "\(uid!)" + "&lastSeenUpdatedTime=\(updatedTime)&lastSeenId=\(lastSeenId)&limit=5"
      loadData(url)
    }

    // setup qa stats
    setupQaStats(myCell, qaStat: qaStat)
    return myCell
  }
}

// Segue action
extension ViewController {

  func isLimitedFree(_ feedInfo: FeedModel) -> Bool {
    return feedInfo.rate > 0 && feedInfo.freeForHours > 0
  }

  func processTransaction(_ amount: Int) {
    let uid = UserDefaults.standard.string(forKey: "uid")
    let quandaId = self.feeds[self.activeIndexPath!.row].id
    let quandaData: [String:AnyObject] = ["id": quandaId as AnyObject]
    let jsonData: [String:AnyObject] = ["uid": uid as AnyObject, "type": "SNOOPED" as AnyObject, "quanda": quandaData as AnyObject]
    self.generics.createObject(self.generics.HTTPHOST + "qatransactions", jsonData: jsonData) { result in
      if (result.isEmpty) {
        DispatchQueue.main.async {
          self.paidSnoops.insert(quandaId)
          self.feedTable.reloadRows(at: [self.activeIndexPath!], with: .none)
          UserDefaults.standard.set(true, forKey: "shouldLoadSnoops")
          UserDefaults.standard.synchronize()
          NotificationCenter.default.post(name: Notification.Name(rawValue: self.notificationName), object: nil, userInfo: ["uid": uid!, "amount" : -amount])
        }
      }
      else {
        DispatchQueue.main.async {
          self.utilityModule.displayAlertMessage("there is an error processing your payment. Please try later", title: "Error", sender: self)
        }
      }
    }
  }

  func displayFreeCoinsView() {
    if let window = UIApplication.shared.keyWindow {
      window.addSubview(blackView)
      blackView.frame = window.frame

      window.addSubview(freeCoinsView)
      freeCoinsView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
      freeCoinsView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
      freeCoinsView.widthAnchor.constraint(equalToConstant: 260).isActive = true
      freeCoinsView.heightAnchor.constraint(equalToConstant: 176).isActive = true
      blackView.alpha = 0
      freeCoinsView.alpha = 0
      UIView.animate(withDuration: 0.5, animations: {
        self.blackView.alpha = 1
        self.freeCoinsView.alpha = 1
      })
    }

  }
  @objc func claimButtonTapped() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.freeCoinsView.alpha = 0
    }) {(_) in
      let uid = UserDefaults.standard.string(forKey: "uid")
      let freeCoins = Int(self.freeCoinsView.numberLabel.text!)

      // get promoId
      let promoCode = self.freeCoinsView.promoCodeTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
      let filterString = "code='\(promoCode)'"
      self.promoProxy.getPromo(filterString) {
        jsonArray in

        // promoId exists
        if let array = jsonArray as? [[String:AnyObject]], array.count > 0 {
          for entry in array {
            let model = PromoModel(entry)
            self.addCoins(uid: uid!, count: freeCoins!, promoId: model.id)
            break
          }
        } else { // promoId not exist
          self.addCoins(uid: uid!, count: freeCoins!, promoId: nil)
        }
      }
    }
  }

  func addCoins(uid: String, count: Int, promoId: String?) {
    self.coinModule.addCoins(uid, count: count, promoId: promoId) { result in
      if (result.isEmpty) {
        DispatchQueue.main.async {
          NotificationCenter.default.post(name: Notification.Name(rawValue: self.notificationName),
                                          object: nil, userInfo: ["uid": uid, "amount" : count])
        }
      }
    }
  }

  @objc func coinButtonTapped() {
    let vc = CoinsViewController()
    vc.numOfCoins = self.coinCount
    vc.homeViewController = self
    self.present(vc, animated: true, completion: nil)
  }

  @objc func confirmButtonTapped() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
    }) { (result) in
      self.processTransaction(4)
      self.playVideo()
    }
  }

  @objc func buyButtonTapped() {
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.buyCoinsView.alpha = 0
    }) { (result) in
      DispatchQueue.main.async {
        self.coinButtonTapped()
      }
    }
  }

  @objc func cancelPayButtonTapped() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.payWithCoinsView.alpha = 0
      }, completion: nil)
  }

  @objc func cancelBuyButtonTapped() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackView.alpha = 0
      self.buyCoinsView.alpha = 0
      }, completion: nil)
  }

  @objc func tappedOnProfile(_ sender:UIGestureRecognizer) {
    self.feedTable.isUserInteractionEnabled = false
    let tapLocation = sender.location(in: self.feedTable)
    let indexPath = self.feedTable.indexPathForRow(at: tapLocation)!
    let responderId = self.feeds[indexPath.row].responderId
    self.userModule.getProfile(responderId) {name, title, about, avatarUrl, rate, _ in
      let discoverModel = DiscoverModel(_name: name, _title: title, _uid: responderId, _about: about, _rate: rate, _updatedTime: 0, _avatarUrl: avatarUrl)
      DispatchQueue.main.async {
        self.feedTable.isUserInteractionEnabled = true
        self.performSegue(withIdentifier: "homeToAsk", sender: discoverModel)
      }
    }
  }

  @objc func tappedOnActionSheetButton(_ sender: UIButton!) {
    /* get answer media info */
    let forModel = feeds[sender.tag]
    let actionSheet = shareActionSheet.createSheet(forModel: forModel, readyToView: isQuandaFreeOrUnlocked(forModel))
    present(actionSheet, animated: true, completion: nil)
  }

  func isQuandaFreeOrUnlocked(_ questionInfo: FeedModel) -> Bool {
    return self.paidSnoops.contains(questionInfo.id) || questionInfo.rate == 0 || questionInfo.freeForHours > 0
  }

  func getUid() -> String {
    return UserDefaults.standard.string(forKey: "uid")!
  }

  @objc func tappedToThumbup(_ sender:UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.feedTable)
    let tapIndexpath = self.feedTable.indexPathForRow(at: tapLocation)!
    let qaStat = qaStats[tapIndexpath.row]

    // allow either thumbupped or thumbdowned
    let upped = qaStat.thumbupped.toBool() ? Bool.FALSE_STR : Bool.TRUE_STR
    let downed = upped.toBool() && qaStat.thumbdowned.toBool() ? Bool.FALSE_STR : qaStat.thumbdowned
    tappedToThumb(tapIndexpath, upped: upped, downed: downed)
  }

  @objc func tappedToThumbdown(_ sender:UIGestureRecognizer) {
    let tapLocation = sender.location(in: self.feedTable)
    let tapIndexpath = self.feedTable.indexPathForRow(at: tapLocation)!
    let qaStat = qaStats[tapIndexpath.row]

    // allow either thumbupped or thumbdowned
    let downed = qaStat.thumbdowned.toBool() ? Bool.FALSE_STR : Bool.TRUE_STR
    let upped = downed.toBool() && qaStat.thumbupped.toBool() ? Bool.FALSE_STR : qaStat.thumbupped
    tappedToThumb(tapIndexpath, upped: upped, downed: downed)
  }

  func tappedToThumb (_ tapIndexpath: IndexPath, upped: String, downed: String) {
    let qaStat = qaStats[tapIndexpath.row]
    let myCell = self.feedTable.cellForRow(at: tapIndexpath) as! FeedTableViewCell

    thumbProxy.createUserThumb(getUid(), quandaId: qaStat.id, upped: upped, downed: downed) {
      result in

      if (result.isEmpty) { // request succeeds
        // sync QaStat
        let qaStatFilter = "quandaId=\(qaStat.id)&uid=\(self.getUid())"
        self.qaStatProxy.getQaStats(qaStatFilter) {
          qaStatEntries in

          for qaStatEntry in qaStatEntries as! [[String:AnyObject]] {
            self.qaStats[tapIndexpath.row] = QaStatModel(qaStatEntry)
            break
          }

          // update UI
          DispatchQueue.main.async {
            self.setupQaStats(myCell, qaStat: self.qaStats[tapIndexpath.row])
          }
        }
      }
    }
  }

  @objc func tappedToWatch(_ sender:UIGestureRecognizer) {
    //using the tapLocation, we retrieve the corresponding indexPath
    let tapLocation = sender.location(in: self.feedTable)
    let indexPath = self.feedTable.indexPathForRow(at: tapLocation)!

    let questionInfo = feeds[indexPath.row]
    self.activeIndexPath = indexPath
    if (isQuandaFreeOrUnlocked(questionInfo)) {
      if (!self.paidSnoops.contains(questionInfo.id)) {
        processTransaction(0)
      }
      playVideo()
    }
    else {
      if let window = UIApplication.shared.keyWindow {
        window.addSubview(blackView)
        blackView.frame = window.frame
        var frameToAdd: UIView!
        if (self.coinCount < 4 && questionInfo.rate > 0) {
          buyCoinsView.setNote("4 coins to unlock an answer")
          frameToAdd = buyCoinsView
        }
        else {
          payWithCoinsView.setCount(4)
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
  }

  func playVideo() {
    let questionInfo = feeds[self.activeIndexPath!.row]
    let answerUrl = questionInfo.answerUrl
    let duration = questionInfo.duration
    self.activePlayerView = self.launchVideoPlayer(answerUrl, duration: duration)
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

  @objc func promoCodeTextFieldDidChange(_ textField: UITextField) {
    let promoCode = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
    let filterString = "code='\(promoCode)'"

    promoProxy.getPromo(filterString) {
      jsonArray in

      // promo exists
      if let array = jsonArray as? [[String:AnyObject]], array.count > 0 {
        for entry in array {
          let model = PromoModel(entry)
          DispatchQueue.main.async {
            self.freeCoinsView.numberLabel.text = String(self.freeCoinsView.defaultFreeNumCoins + model.amount)
            self.freeCoinsView.promoCodeCheckImageView.image = UIImage(named: "promo-enabled")
          }
          break
        }
      } else { // promo not exist
        DispatchQueue.main.async {
          self.freeCoinsView.numberLabel.text = String(self.freeCoinsView.defaultFreeNumCoins)
          self.freeCoinsView.promoCodeCheckImageView.image = UIImage(named: "promo-disabled")
        }
      }
    }
  }
}
