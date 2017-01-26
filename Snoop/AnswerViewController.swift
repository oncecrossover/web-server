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

  @IBOutlet weak var instructionLabel: UILabel!
  @IBOutlet weak var cameraImage: UIImageView!

  var currentImagePicker: UIImagePickerController?

  var soundRecorder: AVAudioRecorder!
  var soundPlayer: AVAudioPlayer!
  var fileName = "videoFile.m4a"

  var questionModule = Question()

  var cellInfo:ActivityModel!

  var utilityModule = UIUtility()

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self) // app might crash without removing observer
  }
}

// Override functions
extension AnswerViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    answerTableView.rowHeight = UITableViewAutomaticDimension
    answerTableView.estimatedRowHeight = 120
    answerTableView.separatorInset = UIEdgeInsetsZero
    answerTableView.tableFooterView = UIView()

    answerTableView.reloadData()
    if (cellInfo.status == "PENDING") {
      cameraImage.userInteractionEnabled = true
      let tappedOnImage = UITapGestureRecognizer(target: self, action: #selector(AnswerViewController.tappedOnImage(_:)))
      cameraImage.addGestureRecognizer(tappedOnImage)
    }
    else {
      cameraImage.hidden = true
      instructionLabel.hidden = true
    }
  }
}

extension AnswerViewController: UITableViewDataSource, UITableViewDelegate {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath) as! ActivityTableViewCell
    myCell.rateLabel.text = "$ \(cellInfo.rate)"

    myCell.question.text = cellInfo.question

    myCell.responderName.text = cellInfo.responderName

    if (!cellInfo.responderTitle.isEmpty) {
      myCell.responderTitle.text = cellInfo.responderTitle
    }

    if (cellInfo.responderImage!.length > 0) {
      myCell.responderImage.image = UIImage(data: cellInfo.responderImage!)
    }
    else {
      myCell.responderImage.image = UIImage(named: "default")
    }

    if (cellInfo.status == "PENDING") {
      myCell.coverImage.image = UIImage()
      myCell.coverImage.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
    }
    else if (cellInfo.status == "ANSWERED") {
      myCell.coverImage.image = UIImage(data: cellInfo.answerCover!)
      myCell.coverImage.userInteractionEnabled = true
      let tappedToWatch = UITapGestureRecognizer(target: self, action: #selector(AnswerViewController.tappedToWatch(_:)))
      cameraImage.addGestureRecognizer(tappedToWatch)
    }

    myCell.askerName.text = cellInfo.askerName + ":"

    if (cellInfo.askerImage!.length > 0) {
      myCell.askerImage.image = UIImage(data: cellInfo.askerImage!)
    }
    else {
      myCell.askerImage.image = UIImage(named: "default")
    }

    return myCell
  }
}

// Private methods
extension AnswerViewController {
  func getCacheDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) 
    return paths[0]
  }

  func getFileUrl() -> NSURL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.stringByAppendingPathComponent(fileName)
    return NSURL(fileURLWithPath: path)
  }
}

// IB Action
extension AnswerViewController {

  func tappedToWatch(sender: UIGestureRecognizer) {
    let questionId = cellInfo.id
    let activityIndicator = utilityModule.createCustomActivityIndicator(self.view, text: "Loading Answer...")
    questionModule.getQuestionMedia(questionId) { audioString in
      if (!audioString.isEmpty) {
        let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
        dispatch_async(dispatch_get_main_queue()) {
          let dataPath = self.utilityModule.getFileUrl("videoFile.m4a")
          data.writeToURL(dataPath, atomically: false)
          activityIndicator.hideAnimated(true)
          let videoAsset = AVAsset(URL: dataPath)
          let playerItem = AVPlayerItem(asset: videoAsset)

          //Play the video
          let player = AVPlayer(playerItem: playerItem)
          let playerViewController = AVPlayerViewController()
          playerViewController.player = player
          self.presentViewController(playerViewController, animated: true) {
            playerViewController.player?.play()
          }
        }
      }
    }
  }

  func tappedOnImage(sender:UIGestureRecognizer) {
    if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
      let imagePicker = UIImagePickerController()
      currentImagePicker = imagePicker
      imagePicker.delegate = self
      imagePicker.sourceType = .Camera
      imagePicker.allowsEditing = false
      imagePicker.mediaTypes = [kUTTypeMovie as String]
      imagePicker.showsCameraControls = false
      imagePicker.cameraDevice = .Front
      imagePicker.cameraCaptureMode = .Video

      // Initiate custom camera view
      let customCameraView = CustomCameraView(frame: imagePicker.view.frame)
      imagePicker.cameraOverlayView = customCameraView
      customCameraView.delegate = self
      self.presentViewController(imagePicker, animated: true, completion: {
        
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
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {

      // Save the video to the app directory so we can play it later
      let videoData = NSData(contentsOfURL: pickedVideo)
      let dataPath = getFileUrl()
      videoData?.writeToURL(dataPath, atomically: false)
    }
  }
}

// CustomCameraViewDelegate
extension AnswerViewController: CustomCameraViewDelegate {
  func didCancel(overlayView:CustomCameraView) {
    if (overlayView.cancelButton.currentTitle == "cancel") {
      currentImagePicker?.dismissViewControllerAnimated(true,
                                                        completion: nil)
    }
    else {
      overlayView.prepareToRecord()
    }
  }

  func didBack(overlayView: CustomCameraView) {
    let myAlert = UIAlertController(title: "Warning", message: "recorded video will be discarded", preferredStyle: UIAlertControllerStyle.Alert)

    let okAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.Destructive) { action in
      self.currentImagePicker?.dismissViewControllerAnimated(true, completion: nil)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)

    myAlert.addAction(cancelAction)
    myAlert.addAction(okAction)

    self.currentImagePicker?.presentViewController(myAlert, animated: true, completion: nil)
  }

  func didNext(overlayView: CustomCameraView) {
    let fileUrl = getFileUrl()
    let asset = AVURLAsset(URL: fileUrl, options: nil)
    let duration = asset.duration.value / 1000
    if (duration <= 5) {
      let myAlert = UIAlertController(title: "Video Too Short", message: "Answer needs to be at least 5 seconds long", preferredStyle: UIAlertControllerStyle.Alert)

      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil)

      myAlert.addAction(okAction)

      currentImagePicker?.presentViewController(myAlert, animated: true, completion: nil)
    }
    else {
//      let dvc = storyboard?.instantiateViewControllerWithIdentifier("CoverFrameViewController") as! CoverFrameViewController
      let dvc = CoverFrameViewController()
      dvc.quandaId = self.cellInfo.id
      currentImagePicker?.pushViewController(dvc, animated: true)
    }
  }

  func didShoot(overlayView:CustomCameraView) {
    if (overlayView.isRecording == false) {
      if ((overlayView.recordButton.currentImage?.isEqual(UIImage(named: "record")))! == true) {
        //start recording answer
        overlayView.isRecording = true
        currentImagePicker?.startVideoCapture()
        overlayView.startTimer()
        overlayView.recordButton.setImage(UIImage(named: "recording"), forState: .Normal)
        overlayView.cancelButton.hidden = true
      }
      else {
        let dataPath = getFileUrl()
        let videoAsset = AVAsset(URL: dataPath)
        let playerItem = AVPlayerItem(asset: videoAsset)

        //Play the video
        let player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        let videoLayer = AVPlayerLayer(player: player)
        videoLayer.frame = self.view.bounds;
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        currentImagePicker?.cameraOverlayView?.layer.addSublayer(videoLayer)
        player.play()
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
          // block base observer has retain cycle issue, remember to unregister observer in deinit
          videoLayer.removeFromSuperlayer()
        }
      }
    }
    else {
      //stop recording
      currentImagePicker?.stopVideoCapture()
      overlayView.reset()
    }
  }

  func stopRecording(overlayView: CustomCameraView) {
    currentImagePicker?.stopVideoCapture()
    overlayView.reset()
  }
}
