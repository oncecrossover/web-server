//
//  AnswerViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/6/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class AnswerViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var answerTableView: UITableView!

  @IBOutlet weak var recordbutton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var explanation: UILabel!
  @IBOutlet weak var reminder: UILabel!
  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet weak var redoButton: UIButton!

  var soundRecorder: AVAudioRecorder!
  var soundPlayer: AVAudioPlayer!
  var fileName = "audioFile.m4a"

  var questionModule = Question()

  var question:(id: Int!, avatarImage: NSData!, askerName: String!, status: String!,
  content: String!, rate: Double!, hoursToExpire: Int!)

  var isRecording = false
  var isPlaying = false
  var isSaved = false

  var count = 60

  var timer = NSTimer()

  var utilityModule = UIUtility()

  override func viewDidLoad() {
    super.viewDidLoad()
    answerTableView.rowHeight = UITableViewAutomaticDimension
    answerTableView.estimatedRowHeight = 120
    setSessionPlayAndRecord()
    setupRecorder()
    initView()
    answerTableView.reloadData()

    // Do any additional setup after loading the view.
  }


  func setupRecorder() {
    let recordSettings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC_HE), AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue, AVEncoderBitRateKey: 48000, AVNumberOfChannelsKey : 2, AVSampleRateKey : 44100.0 ] as [String: AnyObject]

    do {
      soundRecorder = try AVAudioRecorder(URL: getFileUrl(), settings: recordSettings)
      soundRecorder.delegate = self
      soundRecorder.meteringEnabled = true
      soundRecorder.prepareToRecord() // creates/overwrites the file at soundFileURL
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }

  func setSessionPlayAndRecord() {
    let session:AVAudioSession = AVAudioSession.sharedInstance()
    do {
      try session.setCategory("AVAudioSessionCategoryPlayAndRecord", withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
    }
    catch let error as NSError {
      print(error.description)
    }
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
    if (isRecording == false) {
      if (redoButton.hidden == true && confirmButton.hidden == true) {
        soundRecorder.record()
        isRecording = true
        sender.setImage(UIImage(named: "stopButton"), forState: .Normal)
        playButton.enabled = false
        reminder.hidden = false
        explanation.text = "Recording... Touch Button To Stop"

        //Setup timer to remind the user
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(AnswerViewController.update), userInfo: nil, repeats: true)
      }
      else {
        if (isPlaying == false) {
          isPlaying = true
          self.preparePlayer(NSData(contentsOfURL: getFileUrl())!)
          self.soundPlayer.play()
          self.recordbutton.setImage(UIImage(named: "stopButton"), forState: .Normal)
          self.redoButton.enabled = false
          self.confirmButton.enabled = false
          self.explanation.text = "Playing... Click Button to Stop"
        }
        else {
          isPlaying = false
          soundPlayer.stop()
          self.recordbutton.setImage(UIImage(named: "play"), forState: .Normal)
          self.redoButton.enabled = true
          self.confirmButton.enabled = true
          self.explanation.text = "Recording Done. Click Button To Play"
        }
      }

    }
    else {
      stopRecording(sender)
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

  @IBAction func play(sender: UIButton) {
    if (isPlaying == false) {
      isPlaying = true
      sender.setImage(UIImage(named: "stop"), forState: .Normal)
      recordbutton.enabled = false
      questionModule.getQuestionAudio(question.id) { audioString in
        if (!audioString.isEmpty) {
          let data = NSData(base64EncodedString: audioString, options: NSDataBase64DecodingOptions(rawValue: 0))!
          dispatch_async(dispatch_get_main_queue()) {
            self.preparePlayer(data)
            self.soundPlayer.play()
          }
        }
      }
    }
    else {
      sender.setImage(UIImage(named: "listen"), forState: .Normal)
      isPlaying = false
      soundPlayer.stop()

      if (!isSaved) {
        self.recordbutton.enabled = true
        explanation.text = "Recording Done. Click Button To Play"
      }
    }
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
}
