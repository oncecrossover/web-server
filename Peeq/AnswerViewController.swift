//
//  AnswerViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/6/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class AnswerViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

  @IBOutlet weak var scrollView: UILabel!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var askerName: UILabel!
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var questionText: UILabel!
  @IBOutlet weak var recordbutton: UIButton!
  @IBOutlet weak var playButton: UIButton!

  var soundRecorder: AVAudioRecorder!
  var soundPlayer: AVAudioPlayer!
  var fileName = "audioFile.m4a"
  var copyfileName = "copy.m4a"

  var questionModule = Question()

  var question:(id: Int!, avatarUrl: String!, askerName: String!, askerId: String!, status: String!, content: String!)

  override func viewDidLoad() {
    super.viewDidLoad()
    setupRecorder()
    initView()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  func setupRecorder() {
    let recordSettings = [AVFormatIDKey : Int(kAudioFormatAppleLossless), AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue, AVEncoderBitRateKey: 320000, AVNumberOfChannelsKey : 2, AVSampleRateKey : 44100.0 ] as [String: AnyObject]

    do {
      soundRecorder = try AVAudioRecorder(URL: getFileUrl(), settings: recordSettings)
      soundRecorder.delegate = self
      soundRecorder.meteringEnabled = true
      soundRecorder.prepareToRecord() // creates/overwrites the file at soundFileURL
    } catch let error as NSError {
      print(error.localizedDescription)
    }


  }


  func initView() {
    askerName.text = question.askerName
    if !question.avatarUrl.isEmpty {
      profileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: question.avatarUrl)!)!)
    }
    status.text = question.status
    questionText.text = question.content

    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    profileImage.clipsToBounds = true
    profileImage.layer.borderColor = UIColor.blackColor().CGColor
    profileImage.layer.borderWidth = 1

    questionText.lineBreakMode = NSLineBreakMode.ByWordWrapping
    questionText.numberOfLines = 0
    questionText.sizeToFit()
    questionText.font = questionText.font.fontWithSize(15)

    askerName.numberOfLines = 0
    askerName.font = askerName.font.fontWithSize(15)
    askerName.lineBreakMode = NSLineBreakMode.ByWordWrapping
    askerName.sizeToFit()
    
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


  @IBAction func record(sender: UIButton) {
    if sender.titleLabel!.text == "Record" {
      soundRecorder.record()
      sender.setTitle("Stop", forState: .Normal)
      playButton.enabled = false
    }
    else {
      soundRecorder.stop()
      sender.setTitle("Record", forState: .Normal)
    }
  }

  @IBAction func play(sender: UIButton) {
    if sender.titleLabel?.text == "Play" {
      sender.setTitle("Stop", forState: .Normal)
      recordbutton.enabled = false
      preparePlayer()
      soundPlayer.play()
    }
    else {
      sender.setTitle("Play", forState: .Normal)
      soundPlayer.stop()
    }
  }

  func preparePlayer() {
    do {
      soundPlayer = try AVAudioPlayer(contentsOfURL: getFileUrl())
      soundPlayer.delegate = self
      soundPlayer.prepareToPlay()
      soundPlayer.volume = 1.0
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }


  func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
    let responderId = NSUserDefaults.standardUserDefaults().stringForKey("email")
    questionModule.updateQuestion(question.id, askerId: question.askerId, content: question.content,
      responderId: responderId, answerAudio: NSData(contentsOfURL: getFileUrl())) { result in
        dispatch_async(dispatch_get_main_queue()){
          self.playButton.enabled = true
        }
    }
  }


  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    self.recordbutton.enabled = true
    self.playButton.setTitle("Play", forState : .Normal)
  }
}