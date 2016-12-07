//
//  CoverFrameViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 12/15/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class CoverFrameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var coverFrameCollection: UICollectionView!
  var fileName = "videoFile.m4a"
  var coverFrames:[UIImage] = []
  var quandaId:Int?
  override func viewDidLoad() {
    super.viewDidLoad()

    do {
      let fileUrl = getFileUrl()
      let asset = AVURLAsset(URL: fileUrl, options: nil)
      let imgGenerator = AVAssetImageGenerator(asset: asset)
      imgGenerator.appliesPreferredTrackTransform = true
      let durationInSeconds = asset.duration.value / 1000
      let duration = Int(durationInSeconds)
      for i in 0.stride(to: duration, by: 5) {
        let image = try imgGenerator.copyCGImageAtTime(CMTimeMake(Int64(i), 1), actualTime: nil)
        coverFrames.append(UIImage(CGImage: image))
      }
    }
    catch let error as NSError
    {
      print("Image generation failed with error \(error)")
    }

    if (coverFrames.count > 0) {
      coverImage.image = coverFrames[0]
    }
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return coverFrames.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("coverFrameCell", forIndexPath: indexPath) as! CoverFrameCollectionViewCell
    cell.coverImage.image = coverFrames[indexPath.row]
    return cell
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    coverImage.image = coverFrames[indexPath.row]
  }

  @IBAction func backButtonTapped(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func submitButtonTapped(sender: AnyObject) {
  }

  func getFileUrl() -> NSURL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.stringByAppendingPathComponent(fileName)
    return NSURL(fileURLWithPath: path)
  }

  func getCacheDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    return paths[0]
  }
}
