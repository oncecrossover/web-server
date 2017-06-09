//
//  AnswerViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/6/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MobileCoreServices

class AnswerViewController: UIViewController {

  @IBOutlet weak var answerTableView: UITableView!

  var currentImagePicker: UIImagePickerController?
  var videoLayer: AVPlayerLayer?

  var fileName = "videoFile.m4a"
  var globalCounter = 0
  var segmentUrls:[URL] = []
  var segmentFilePrefix = "videoFile"

  var player: AVQueuePlayer?

  var questionModule = Question()

  var cellInfo:ActivityModel!

  var utilityModule = UIUtility()

  lazy var permissionView: PermissionView = {
    let view = PermissionView()
    view.setHeader("Allow Snoop to access your camera")
    view.setInstruction("1. Open Iphone settings \n2. Tap privacy \n3. Tap camera \n4. Set Snoop to ON")
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var closeButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: "close"), for: UIControlState())
    button.addTarget(self, action: #selector(stopPlaying), for: .touchUpInside)
    return button
  }()

  let footerCellId = "footerCell"
  deinit {
    NotificationCenter.default.removeObserver(self) // app might crash without removing observer
  }
}

// Override functions
extension AnswerViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    answerTableView.rowHeight = UITableViewAutomaticDimension
    answerTableView.estimatedRowHeight = 120
    answerTableView.separatorStyle = .none
    answerTableView.tableFooterView = UIView()
    answerTableView.register(AnswerTableFooterViewCell.self, forHeaderFooterViewReuseIdentifier: self.footerCellId)

    answerTableView.reloadData()
  }
}

extension AnswerViewController: UITableViewDataSource, UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 200
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.footerCellId) as! AnswerTableFooterViewCell
    footer.cameraView.isUserInteractionEnabled = true
    footer.cameraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnImage)))
    return footer
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityTableViewCell
    myCell.rateLabel.text = "$ \(cellInfo.rate)"

    myCell.question.text = cellInfo.question

    myCell.responderName.text = cellInfo.responderName

    if (!cellInfo.responderTitle.isEmpty) {
      myCell.responderTitle.text = cellInfo.responderTitle
    }

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
      myCell.expireLabel.isHidden = false
      if (cellInfo.hoursToExpire > 1) {
        myCell.expireLabel.text = "expires in \(cellInfo.hoursToExpire) hours"
      }
      else {
        myCell.expireLabel.text = "expires in \(cellInfo.hoursToExpire) hour"
      }
    }

    myCell.askerName.text = cellInfo.askerName + ":"

    return myCell
  }
}

// Private methods
extension AnswerViewController {
  func handleEndOfPlaying() {
    if ((self.player?.items().count)! > 1) {
      self.player?.advanceToNextItem()
    }
    else {
      self.videoLayer?.removeFromSuperlayer()
      self.closeButton.removeFromSuperview()
    }
  }

  func getCacheDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    return paths[0]
  }

  func getFileUrl() -> URL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.appendingPathComponent(fileName)
    return URL(fileURLWithPath: path)
  }

  func getSegmentFileUrl() -> URL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.appendingPathComponent(self.getSegmentFileName())
    return URL(fileURLWithPath: path)
  }

  func getSegmentFileUrl(_ index: Int) -> URL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.appendingPathComponent(self.getSegmentFileName(index))
    return URL(fileURLWithPath: path)
  }
  func getSegmentFileName() -> String {
    return self.segmentFilePrefix + "\(self.globalCounter).m4a"
  }

  func getSegmentFileName(_ index: Int) -> String {
    return self.segmentFilePrefix + "\(index).m4a"
  }

  func handleAudioInteruption(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
      let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
      let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeRawValue) else {
        return
    }

    switch interruptionType {
    case .began:
      if let cameraView = self.currentImagePicker?.cameraOverlayView as? CustomCameraView {
        self.stopRecording(cameraView)
        cameraView.disableCameraControls()
      }
    case .ended:
      if let cameraView = self.currentImagePicker?.cameraOverlayView as? CustomCameraView {
        cameraView.enableCameraControls()
      }
    }
  }
  func mergeVideos() {
    let activityIndicator = utilityModule.createCustomActivityIndicator((self.currentImagePicker?.view)!, text: "Merging videos...")
    var totalTime = kCMTimeZero
    let composition = AVMutableComposition()
    var layerInstructions:[AVVideoCompositionLayerInstruction] = []
    for url in segmentUrls {
      let videoAsset = AVAsset(url: url)
      let videoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
      let audioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
      let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]

      do {

        try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                       of: videoAssetTrack, at: totalTime)
        try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                       of: videoAsset.tracks(withMediaType: AVMediaTypeAudio)[0], at: totalTime)
      } catch let error as NSError {
        print("error: \(error)")
      }
      totalTime = CMTimeAdd(totalTime, videoAsset.duration)
      // Set up instructions
      let videoInstruction = videoCompositionInstructionForTrack(track: videoTrack, assetTrack: videoAssetTrack)
      if (url != segmentUrls.last) {
        videoInstruction.setOpacity(0.0, at: totalTime)
      }
      layerInstructions.append(videoInstruction)
    }

    // Set up main composition
    let mainInstruction = AVMutableVideoCompositionInstruction()
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalTime)
    mainInstruction.layerInstructions = layerInstructions
    let mainComposition = AVMutableVideoComposition()
    mainComposition.instructions = [mainInstruction]
    mainComposition.frameDuration = CMTimeMake(1, 30)
    mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

    let outputUrl = getFileUrl()
    try? FileManager.default.removeItem(at: outputUrl)
    let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality)!
    exporter.outputURL = outputUrl
    exporter.outputFileType = AVFileTypeMPEG4 //.m4a format
    exporter.videoComposition = mainComposition
    exporter.exportAsynchronously{
      switch exporter.status{
      case AVAssetExportSessionStatus.failed,
           AVAssetExportSessionStatus.cancelled:
        let myAlert = UIAlertController(title: "Merge Failed", message: "An error occurs during merging. Please try later", preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil)

        myAlert.addAction(okAction)

        self.currentImagePicker?.present(myAlert, animated: true, completion: nil)
        break
      default:
        DispatchQueue.main.async {
          activityIndicator.hide(animated: true)
          let asset = AVURLAsset(url: outputUrl, options: nil)
          let duration = asset.duration.value / 1000
          if (duration <= 5) {
            let myAlert = UIAlertController(title: "Video Too Short", message: "Answer needs to be at least 5 seconds long", preferredStyle: UIAlertControllerStyle.alert)

            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil)

            myAlert.addAction(okAction)

            self.currentImagePicker?.present(myAlert, animated: true, completion: nil)
          }
          else {
            let dvc = CoverFrameViewController()
            dvc.quandaId = self.cellInfo.id
            self.currentImagePicker?.pushViewController(dvc, animated: true)
          }
        }
      }
    }
  }

  func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
    var assetOrientation = UIImageOrientation.up
    var isPortrait = false
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
      assetOrientation = .right
      isPortrait = true
    } else if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
      assetOrientation = .left
      isPortrait = true
    } else if (transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
      assetOrientation = .up
    } else if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
      assetOrientation = .down
    }
    return (assetOrientation, isPortrait)
  }

  func videoCompositionInstructionForTrack(track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
    let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)

    let transform = assetTrack.preferredTransform
    let assetInfo = orientationFromTransform(transform: transform)

    var scaleXToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
    var scaleYToFitRatio = UIScreen.main.bounds.height / assetTrack.naturalSize.height
    if assetInfo.isPortrait {
      scaleXToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
      scaleYToFitRatio = UIScreen.main.bounds.height / assetTrack.naturalSize.width
      let scaleFactor = CGAffineTransform(scaleX: scaleXToFitRatio, y: scaleYToFitRatio)
      instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                               at: kCMTimeZero)
    }
    else {
      let scaleFactor = CGAffineTransform(scaleX: scaleXToFitRatio, y: scaleYToFitRatio)
      var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
      if assetInfo.orientation == .down {
        let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        let windowBounds = UIScreen.main.bounds
        let yFix = assetTrack.naturalSize.height + windowBounds.height
        let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
        concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
      }
      instruction.setTransform(concat, at: kCMTimeZero)
    }
    return instruction
  }
}

// IB Action
extension AnswerViewController {

  func tappedToWatch(_ sender: UIGestureRecognizer) {
    let questionId = cellInfo.id
    let activityIndicator = utilityModule.createCustomActivityIndicator(self.view, text: "Loading Answer...")
    questionModule.getQuestionMedia(questionId) { audioString in
      if (!audioString.isEmpty) {
        let data = Data(base64Encoded: audioString, options: NSData.Base64DecodingOptions(rawValue: 0))!
        DispatchQueue.main.async {
          let dataPath = self.utilityModule.getFileUrl("videoFile.m4a")
          try? data.write(to: dataPath, options: [])
          activityIndicator.hide(animated: true)
          let videoAsset = AVAsset(url: dataPath)
          let playerItem = AVPlayerItem(asset: videoAsset)

          //Play the video
          let player = AVPlayer(playerItem: playerItem)
          let playerViewController = AVPlayerViewController()
          playerViewController.player = player
          self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
          }
        }
      }
    }
  }

  func tappedOnImage() {
    // Check if user granted camera access
    if (AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.denied) {
      if let window = UIApplication.shared.keyWindow {
        window.addSubview(permissionView)
        window.addConstraintsWithFormat("H:|[v0]|", views: permissionView)
        window.addConstraintsWithFormat("V:|[v0]|", views: permissionView)
        permissionView.alpha = 0
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
          self.permissionView.alpha = 1
        }, completion: nil)
        return
      }
    }

    // Check if user granted microphone access
    if (AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.denied) {
      if let window = UIApplication.shared.keyWindow {
        window.addSubview(permissionView)
        window.addConstraintsWithFormat("H:|[v0]|", views: permissionView)
        window.addConstraintsWithFormat("V:|[v0]|", views: permissionView)
        permissionView.alpha = 0
        permissionView.setHeader("Allow Snoop to access your microphone")
        permissionView.setInstruction("1. Open Iphone settings \n2. Tap privacy \n3. Tap microphone \n4. Set Snoop to ON")
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
          self.permissionView.alpha = 1
        }, completion: nil)
        return
      }
    }

    if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
      let imagePicker = UIImagePickerController()
      currentImagePicker = imagePicker
      imagePicker.delegate = self
      imagePicker.sourceType = .camera
      imagePicker.allowsEditing = false
      imagePicker.mediaTypes = [kUTTypeMovie as String]
      imagePicker.showsCameraControls = false
      imagePicker.cameraDevice = .rear
      imagePicker.cameraCaptureMode = .video

      // Initiate custom camera view
      let customCameraView = CustomCameraView(frame: imagePicker.view.frame)
      imagePicker.cameraOverlayView = customCameraView
      customCameraView.delegate = self
      self.present(imagePicker, animated: true, completion: {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleEndOfPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        // Add audioSessionInteruption Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAudioInteruption(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
      })
    }
    else {
      utilityModule.displayAlertMessage("Camera is not available on your device", title: "Alert", sender: self)
    }
  }
}

// UIImageviewController delegate
extension AnswerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {


  //Finished recording video
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedVideo:URL = (info[UIImagePickerControllerMediaURL] as? URL) {

      // Save the video to the app directory so we can play it later
      let videoData = try? Data(contentsOf: pickedVideo)
      let dataPath = getSegmentFileUrl()
      self.segmentUrls.append(dataPath)
      self.globalCounter += 1
      try? videoData?.write(to: dataPath, options: [])
    }
  }
}

// CustomCameraViewDelegate
extension AnswerViewController: CustomCameraViewDelegate {
  func didDelete(_ overlayView: CustomCameraView) {
    let myAlert = UIAlertController(title: "Warning", message: "highlighted segment will be discarded", preferredStyle: UIAlertControllerStyle.alert)

    let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { action in
      self.segmentUrls.removeLast()
      self.globalCounter -= 1

      DispatchQueue.main.async {
        overlayView.deleteSegment()
      }
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { action in
      DispatchQueue.main.async {
        overlayView.cancelDeleteSegment()
      }
    }

    myAlert.addAction(cancelAction)
    myAlert.addAction(okAction)

    self.currentImagePicker?.present(myAlert, animated: true, completion: nil)
  }

  func didBack(_ overlayView: CustomCameraView) {
    let myAlert = UIAlertController(title: "Warning", message: "recorded video will be discarded", preferredStyle: UIAlertControllerStyle.alert)

    let okAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive) { action in
      NotificationCenter.default.removeObserver(self) // app might crash without removing observer
      self.globalCounter = 0
      self.segmentUrls = []
      self.currentImagePicker?.dismiss(animated: true, completion: nil)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)

    myAlert.addAction(cancelAction)
    myAlert.addAction(okAction)

    self.currentImagePicker?.present(myAlert, animated: true, completion: nil)
  }

  func didNext(_ overlayView: CustomCameraView) {
    mergeVideos()
  }

  func didSwitch(_ overlayView: CustomCameraView) {
    if (self.currentImagePicker?.cameraDevice == .front) {
      self.currentImagePicker?.cameraDevice = .rear
    }
    else {
      self.currentImagePicker?.cameraDevice = .front
    }
  }

  func didShoot(_ overlayView:CustomCameraView) {
    if (overlayView.isRecording == false) {
      //start recording answer
      currentImagePicker?.startVideoCapture()
      overlayView.hideCameraControls()
    }
    else {
      //stop recording
      currentImagePicker?.stopVideoCapture()
      overlayView.showCameraControls()
    }
  }

  func didPlay(_ overlayView: CustomCameraView) {
    var playerItems: [AVPlayerItem] = []
    for url in self.segmentUrls {
      let videoAsset = AVAsset(url: url)
      let playerItem = AVPlayerItem(asset: videoAsset)
      playerItems.append(playerItem)
    }

    //Play the video
    player = AVQueuePlayer(items: playerItems)
    player?.actionAtItemEnd = AVPlayerActionAtItemEnd.none
    videoLayer = AVPlayerLayer(player: player)
    videoLayer?.frame = self.view.bounds
    videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    currentImagePicker?.cameraOverlayView?.layer.addSublayer(videoLayer!)

    // Add close button
    currentImagePicker?.cameraOverlayView?.addSubview(closeButton)
    closeButton.topAnchor.constraint(equalTo: (currentImagePicker?.cameraOverlayView?.topAnchor)!, constant: 20).isActive = true
    closeButton.leadingAnchor.constraint(equalTo: (currentImagePicker?.cameraOverlayView?.leadingAnchor)!).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    player?.play()
  }

  func stopRecording(_ overlayView: CustomCameraView) {
    currentImagePicker?.stopVideoCapture()
    overlayView.showCameraControls()
  }

  func stopPlaying() {
    self.videoLayer?.player?.pause()
    self.closeButton.removeFromSuperview()
    self.videoLayer?.removeFromSuperlayer()
  }
}
