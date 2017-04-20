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
    }

    myCell.askerName.text = cellInfo.askerName + ":"

    return myCell
  }
}

// Private methods
extension AnswerViewController {
  func getCacheDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    return paths[0]
  }

  func getFileUrl() -> URL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.appendingPathComponent(fileName)
    return URL(fileURLWithPath: path)
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
      imagePicker.cameraDevice = .front
      imagePicker.cameraCaptureMode = .video

      // Initiate custom camera view
      let customCameraView = CustomCameraView(frame: imagePicker.view.frame)
      imagePicker.cameraOverlayView = customCameraView
      customCameraView.delegate = self
      self.present(imagePicker, animated: true, completion: {
        
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
      let dataPath = getFileUrl()
      try? videoData?.write(to: dataPath, options: [])
    }
  }
}

// CustomCameraViewDelegate
extension AnswerViewController: CustomCameraViewDelegate {
  func didCancel(_ overlayView:CustomCameraView) {
    if (overlayView.cancelButton.currentTitle == "cancel") {
      currentImagePicker?.dismiss(animated: true,
                                                        completion: nil)
    }
    else {
      overlayView.prepareToRecord()
    }
  }

  func didBack(_ overlayView: CustomCameraView) {
    let myAlert = UIAlertController(title: "Warning", message: "recorded video will be discarded", preferredStyle: UIAlertControllerStyle.alert)

    let okAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.destructive) { action in
      self.currentImagePicker?.dismiss(animated: true, completion: nil)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)

    myAlert.addAction(cancelAction)
    myAlert.addAction(okAction)

    self.currentImagePicker?.present(myAlert, animated: true, completion: nil)
  }

  func didNext(_ overlayView: CustomCameraView) {
    let fileUrl = getFileUrl()
    let asset = AVURLAsset(url: fileUrl, options: nil)
    let duration = asset.duration.value / 1000
    if (duration <= 5) {
      let myAlert = UIAlertController(title: "Video Too Short", message: "Answer needs to be at least 5 seconds long", preferredStyle: UIAlertControllerStyle.alert)

      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil)

      myAlert.addAction(okAction)

      currentImagePicker?.present(myAlert, animated: true, completion: nil)
    }
    else {
      let dvc = CoverFrameViewController()
      dvc.quandaId = self.cellInfo.id
      currentImagePicker?.pushViewController(dvc, animated: true)
    }
  }

  func didShoot(_ overlayView:CustomCameraView) {
    if (overlayView.isRecording == false) {
      if ((overlayView.recordButton.currentImage?.isEqual(UIImage(named: "record")))! == true) {
        //start recording answer
        overlayView.isRecording = true
        currentImagePicker?.startVideoCapture()
        overlayView.startTimer()
        overlayView.recordButton.setImage(UIImage(named: "recording"), for: UIControlState())
        overlayView.cancelButton.isHidden = true
      }
      else {
        let dataPath = getFileUrl()
        let videoAsset = AVAsset(url: dataPath)
        let playerItem = AVPlayerItem(asset: videoAsset)

        //Play the video
        let player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        videoLayer = AVPlayerLayer(player: player)
        videoLayer?.frame = self.view.bounds;
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        currentImagePicker?.cameraOverlayView?.layer.addSublayer(videoLayer!)

        // Add close button
        currentImagePicker?.cameraOverlayView?.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: (currentImagePicker?.cameraOverlayView?.topAnchor)!, constant: 20).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: (currentImagePicker?.cameraOverlayView?.leadingAnchor)!).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        player.play()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
          // block base observer has retain cycle issue, remember to unregister observer in deinit
          self.videoLayer?.removeFromSuperlayer()
          self.closeButton.removeFromSuperview()
        }
      }
    }
    else {
      //stop recording
      currentImagePicker?.stopVideoCapture()
      overlayView.reset()
    }
  }

  func stopRecording(_ overlayView: CustomCameraView) {
    currentImagePicker?.stopVideoCapture()
    overlayView.reset()
  }

  func stopPlaying() {
    self.videoLayer?.player?.pause()
    self.closeButton.removeFromSuperview()
    self.videoLayer?.removeFromSuperlayer()
  }
}
