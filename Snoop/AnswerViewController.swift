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

class AnswerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource, CustomOverlayDelegate {

  @IBOutlet weak var answerTableView: UITableView!

  @IBOutlet weak var recordbutton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var explanation: UILabel!
  @IBOutlet weak var reminder: UILabel!
  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet weak var redoButton: UIButton!

  var currentImagePicker: UIImagePickerController?
  var utility = UIUtility()

  var soundRecorder: AVAudioRecorder!
  var soundPlayer: AVAudioPlayer!
  var fileName = "videoFile.m4a"

  var questionModule = Question()

  var question:(id: Int!, avatarImage: NSData!, askerName: String!, status: String!,
  content: String!, rate: Double!, hoursToExpire: Int!)

  var isRecording = false
  var isPlaying = false
  var isSaved = false

  var count = 60

  var timer = NSTimer()

  var utilityModule = UIUtility()

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self) // app might crash without removing observer
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    answerTableView.rowHeight = UITableViewAutomaticDimension
    answerTableView.estimatedRowHeight = 120
    initView()
    answerTableView.reloadData()

    // Do any additional setup after loading the view.
  }

  func initView() {
    reminder.hidden = true
    confirmButton.hidden = true
    recordbutton.setImage(UIImage(named: "speak"), forState: .Normal)
    playButton.setImage(UIImage(named: "listen"), forState: .Normal)
    redoButton.setImage(UIImage(named: "redo"), forState: .Normal)
    redoButton.hidden = true

    if (question.status == "PENDING") {
      explanation.text = "Touch button to start recording up to 60 sec"
      playButton.hidden = true
      isSaved = false
    }
    else {
      explanation.hidden = true
      recordbutton.enabled = false
      playButton.hidden = false
      isSaved = true
    }
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("answerCell", forIndexPath: indexPath) as! AnswerTableViewCell
    myCell.askerName.text = question.askerName
    myCell.status.text = question.status

    if (question.status == "ANSWERED") {
      myCell.status.textColor = UIColor(red: 0.125, green: 0.55, blue: 0.17, alpha: 1.0)
    }
    else {
      myCell.status.textColor = UIColor.orangeColor()
    }

    myCell.question.text = question.content
    myCell.rateLabel.text = "$\(question.rate)"

    myCell.expiration.text = "expires in \(question.hoursToExpire) hrs"
    if (question.hoursToExpire == 1) {
      myCell.expiration.text = "expires in 1 hr"
    }

    if (question.avatarImage.length > 0) {
      myCell.profileImage.image = UIImage(data: question.avatarImage)
    }

    return myCell
  }

  func getCacheDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) 
    return paths[0]
  }

  func getFileUrl() -> NSURL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.stringByAppendingPathComponent(fileName)
    return NSURL(fileURLWithPath: path)
  }

  func update() {
    if(count > 0) {
      count-=1
      reminder.text = String(count)
    }
    else {
      stopRecording(recordbutton)
    }
  }

  @IBAction func record(sender: UIButton) {
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

      //customView stuff
      let customViewController = CustomOverlayViewController(
        nibName:"CustomOverlayViewController",
        bundle: nil
      )
      let customView:CustomOverlayView = customViewController.view as! CustomOverlayView
      customView.frame = imagePicker.view.frame
      customView.delegate = self
      imagePicker.cameraOverlayView = customView
      self.presentViewController(imagePicker, animated: true, completion: {
        
      })
    }
    else {
      utility.displayAlertMessage("Camera is not available on your device", title: "Alert", sender: self)
    }
  }


  //Finished recording video
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {

      // Save the video to the app directory so we can play it later
      let videoData = NSData(contentsOfURL: pickedVideo)
      let dataPath = getFileUrl()
      videoData?.writeToURL(dataPath, atomically: false)
    }
  }


  func didCancel(overlayView:CustomOverlayView) {
    if (overlayView.cancelButton.currentTitle == "cancel") {
      currentImagePicker?.dismissViewControllerAnimated(true,
                                                        completion: nil)
    }
    else {
      overlayView.isRecording = true
      currentImagePicker?.startVideoCapture()
      overlayView.shootButton.setImage(UIImage(named: "recording"), forState: .Normal)
      overlayView.cancelButton.hidden = true
    }
  }

  func didBack(overlayView: CustomOverlayView) {
    let myAlert = UIAlertController(title: "Warning", message: "recorded video will be discarded", preferredStyle: UIAlertControllerStyle.Alert)

    let okAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.Destructive) { action in
      self.currentImagePicker?.dismissViewControllerAnimated(true, completion: nil)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)

    myAlert.addAction(cancelAction)
    myAlert.addAction(okAction)

    self.currentImagePicker?.presentViewController(myAlert, animated: true, completion: nil)
  }

  func didNext(overlayView: CustomOverlayView) {
    let dvc = storyboard?.instantiateViewControllerWithIdentifier("CoverFrameViewController") as! CoverFrameViewController
    dvc.quandaId = self.question.id
    //currentImagePicker?.dismissViewControllerAnimated(true, completion: nil)
    currentImagePicker?.pushViewController(dvc, animated: true)
    //self.navigationController?.pushViewController(dvc, animated: true)
  }

  func didShoot(overlayView:CustomOverlayView) {
    if (overlayView.isRecording == false) {
      if ((overlayView.shootButton.currentImage?.isEqual(UIImage(named: "record")))! == true) {
        //start recording answer
        overlayView.isRecording = true
        currentImagePicker?.startVideoCapture()
        overlayView.shootButton.setImage(UIImage(named: "recording"), forState: .Normal)
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
      overlayView.isRecording = false
      currentImagePicker?.stopVideoCapture()
      overlayView.cancelButton.hidden = false
      overlayView.cancelButton.setTitle("retake", forState: .Normal)
      overlayView.shootButton.setImage(UIImage(named: "triangle"), forState: .Normal)
      overlayView.backButton.hidden = false
      overlayView.nextButton.hidden = false
    }
  }

  @IBAction func play(sender: UIButton) {
    questionModule.getQuestionAudio(question.id) { audioString in
      if (!audioString.isEmpty) {
        let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
        dispatch_async(dispatch_get_main_queue()) {
          let dataPath = self.getFileUrl()
          data.writeToURL(dataPath, atomically: false)
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

  func stopRecording(sender: UIButton) {
    soundRecorder.stop()
    isRecording = false
    sender.setImage(UIImage(named: "play"), forState: .Normal)
    reminder.hidden = true
    reminder.text = String(60)
    confirmButton.hidden = false
    explanation.text = "Recording Done. Click Button To Play"
    redoButton.hidden = false

    timer.invalidate()
    count = 60
  }


  @IBAction func confirmButtonTapped(sender: AnyObject) {
    let activityIndicator = utilityModule.createCustomActivityIndicator(self.view, text: "Submitting Answer...")
    questionModule.updateQuestion(question.id, answerAudio: NSData(contentsOfURL: getFileUrl())) { result in
        dispatch_async(dispatch_get_main_queue()){
          self.playButton.enabled = true
          self.playButton.hidden = false
          self.isSaved = true
          self.confirmButton.hidden = true
          self.redoButton.hidden = true

          // After the answer is submitted, the user can no longer re-record his answer
          self.recordbutton.hidden = true
          self.explanation.hidden = true
          activityIndicator.hideAnimated(true)

          // Refresh the status of the question to "ANSWERED"
          self.question.status = "ANSWERED"
          self.answerTableView.reloadData()
        }
    }
  }

  @IBAction func redoButtonTapped(sender: AnyObject) {
    initView()
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

/*
  func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
    self.redoButton.hidden = false
    self.confirmButton.hidden = false
  }


  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    isPlaying = false
    playButton.setImage(UIImage(named: "listen"), forState: .Normal)

    // If the answer is not submitted, we need to enable re-recording
    if (!isSaved) {
      self.recordbutton.enabled = true
      self.redoButton.enabled = true
      self.confirmButton.enabled = true
      self.recordbutton.setImage(UIImage(named: "play"), forState: .Normal)
      self.explanation.text = "Recording Done. Click Button To Play"
    }
  }
 */
}
