//
//  CoverFrameViewController.swift
//  Snoop
//
//  Created by Bowen Zhang on 12/15/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import AVFoundation

class CoverFrameViewController: UIViewController {

  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var coverFrameCollection: UICollectionView! {
    didSet {

      if let flowLayout = coverFrameCollection.collectionViewLayout as? UICollectionViewFlowLayout {
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
      }
    }
  }
  var fileName = "videoFile.m4a"
  var coverFrames:[UIImage] = []
  var quandaId:Int?
  var selectedRow: Int = 0
  var questionModule = Question()
  var utilityModule = UIUtility()
}

// MARK: - Overriding

extension CoverFrameViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    // Creating left bar
    let navbar = UINavigationBar(frame: CGRectMake(0, 0,
      UIScreen.mainScreen().bounds.size.width, 60));
    navbar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navbar.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    navbar.titleTextAttributes = [ NSForegroundColorAttributeName:UIColor.whiteColor()]
    self.view.addSubview(navbar)

    let navItem = UINavigationItem(title: "Pick a Cover")
    let navBarbutton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Done, target: self, action: #selector(CoverFrameViewController.back(_:)))
    navBarbutton.tintColor = UIColor.whiteColor()
    navItem.leftBarButtonItem = navBarbutton

    navbar.items = [navItem]

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


}

// MARK: - IBAction

extension CoverFrameViewController {

  func back(sender: AnyObject) {
    let myAlert = UIAlertController(title: "Warning", message: "recorded video will be discarded", preferredStyle: UIAlertControllerStyle.Alert)

    let okAction = UIAlertAction(title: "Back", style: UIAlertActionStyle.Destructive) { action in
      self.dismissViewControllerAnimated(true, completion: nil)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)

    myAlert.addAction(cancelAction)
    myAlert.addAction(okAction)

    self.presentViewController(myAlert, animated: true, completion: nil)
  }

  @IBAction func submitButtonTapped(sender: AnyObject) {
    let videoData = NSData(contentsOfURL: getFileUrl())
    var compressionRatio = 1.0
    let photoSize = UIImageJPEGRepresentation(coverImage.image!, 1)
    if (photoSize?.length > 1000000) {
      compressionRatio = 0.005
    }
    else if (photoSize?.length > 500000) {
      compressionRatio = 0.01
    }
    else if (photoSize?.length > 100000){
      compressionRatio = 0.05
    }
    else if (photoSize?.length > 10000) {
      compressionRatio = 0.2
    }

    let photoData = UIImageJPEGRepresentation(coverImage.image!, CGFloat(compressionRatio))
    let activityIndicator = utilityModule.createCustomActivityIndicator(self.view, text: "Submitting Answer...")
    questionModule.submitAnswer(quandaId, answerVideo: videoData, coverPhoto: photoData) { result in
      activityIndicator.hideAnimated(true)
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }

}

// MARK: - Private

private extension CoverFrameViewController {

  func highlight(cell: UICollectionViewCell) {
    cell.layer.borderColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0).CGColor
    cell.layer.borderWidth = 2
  }

  func dehighlight(cell: UICollectionViewCell) {
    cell.layer.borderColor = UIColor.clearColor().CGColor
    cell.layer.borderWidth = 0
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

// MARK: - UICollectionViewDataSource

extension CoverFrameViewController: UICollectionViewDataSource {

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return coverFrames.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("coverFrameCell", forIndexPath: indexPath) as! CoverFrameCollectionViewCell
    cell.coverImage.image = coverFrames[indexPath.row]
    if indexPath.row == selectedRow {
      highlight(cell)
    } else {
      dehighlight(cell)
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegate

extension CoverFrameViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    coverImage.image = coverFrames[indexPath.row]
    if let previousCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0)) {
      dehighlight(previousCell)
    }
    if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
      highlight(cell)
    }
    selectedRow = indexPath.row

  }
}
