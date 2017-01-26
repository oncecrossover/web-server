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

  let fileName = "videoFile.m4a"
  var coverFrames:[UIImage] = []
  var quandaId:Int?
  var questionModule = Question()
  var utilityModule = UIUtility()
  var duration = 0

  let cellId = "coverFrameCell"

  let coverImage : UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var submitButton: UIButton = {
    let button = UIButton()
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.setTitle("Submit", forState: .Normal)
    button.backgroundColor = UIColor.defaultColor()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(submitButtonTapped), forControlEvents: .TouchUpInside)
    return button
  }()

  lazy var coverFrameCollection: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.scrollDirection = .Horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    collectionView.registerClass(CoverFrameCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
}

// MARK: - Overriding

extension CoverFrameViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.whiteColor()
    initView()
    setupNavbar()

    do {
      let fileUrl = getFileUrl()
      let asset = AVURLAsset(URL: fileUrl, options: nil)
      let imgGenerator = AVAssetImageGenerator(asset: asset)
      imgGenerator.appliesPreferredTrackTransform = true
      let durationFromAsset = CMTimeGetSeconds(asset.duration)
      duration = Int(durationFromAsset)
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
      let indexPath = NSIndexPath(forItem: 0, inSection: 0)
      coverFrameCollection.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
      coverImage.image = coverFrames[0]
    }
  }


}

// MARK: - Private

private extension CoverFrameViewController {

  func initView() {
    self.view.addSubview(coverImage)
    self.view.addSubview(coverFrameCollection)
    self.view.addSubview(submitButton)
    //set all horizontal constraints
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: [], metrics: nil, views: ["v0" : coverImage]))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: [], metrics: nil, views: ["v0" : coverFrameCollection]))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: [], metrics: nil, views: ["v0" : submitButton]))

    //set vertical constraints
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v0]-0-[v1(100)]-0-[v2(40)]|", options: [], metrics: nil, views: ["v0" : coverImage, "v1" : coverFrameCollection, "v2" : submitButton]))
  }
  func setupNavbar() {
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

// MARK: - IBAction

extension CoverFrameViewController {

  func back(sender: AnyObject) {
    self.navigationController?.popViewControllerAnimated(false)
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
    questionModule.submitAnswer(quandaId, answerVideo: videoData, coverPhoto: photoData, duration: self.duration) { result in
      let presentingViewController = self.presentingViewController as? UITabBarController
      let navigationController = presentingViewController?.viewControllers?[2] as? UINavigationController
      navigationController?.popViewControllerAnimated(true)
      let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
      dispatch_after(time, dispatch_get_main_queue()){
        activityIndicator.hideAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
      }
    }
  }

}
// MARK: - UICollectionViewDelegateFlowLayout
extension CoverFrameViewController :  UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(50, 100)
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

    return cell
  }
}

// MARK: - UICollectionViewDelegate

extension CoverFrameViewController: UICollectionViewDelegate {

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    coverImage.image = coverFrames[indexPath.row]
  }
}
