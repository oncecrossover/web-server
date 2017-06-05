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
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.setTitle("Submit", for: UIControlState())
    button.backgroundColor = UIColor.defaultColor()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    return button
  }()

  lazy var coverFrameCollection: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    collectionView.register(CoverFrameCollectionViewCell.self, forCellWithReuseIdentifier: self.cellId)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
}

// MARK: - Overriding

extension CoverFrameViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    initView()
    setupNavbar()

    do {
      let fileUrl = getFileUrl()
      let asset = AVURLAsset(url: fileUrl, options: nil)
      let imgGenerator = AVAssetImageGenerator(asset: asset)
      imgGenerator.appliesPreferredTrackTransform = true
      let durationFromAsset = CMTimeGetSeconds(asset.duration)
      duration = Int(durationFromAsset)
      for i in stride(from: 0, to: duration, by: 5) {
        let image = try imgGenerator.copyCGImage(at: CMTimeMake(Int64(i), 1), actualTime: nil)
        coverFrames.append(UIImage(cgImage: image))
      }
    }
    catch let error as NSError
    {
      print("Image generation failed with error \(error)")
    }

    if (coverFrames.count > 0) {
      let indexPath = IndexPath(item: 0, section: 0)
      coverFrameCollection.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
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
    view.addConstraintsWithFormat("H:|[v0]|", views: coverImage)
    view.addConstraintsWithFormat("H:|[v0]|", views: coverFrameCollection)
    view.addConstraintsWithFormat("H:|[v0]|", views: submitButton)

    //set vertical constraints
    view.addConstraintsWithFormat("V:|[v0]-0-[v1(100)]-0-[v2(40)]|", views: coverImage, coverFrameCollection, submitButton)
  }
  func setupNavbar() {
    // Creating left bar
    let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0,
      width: UIScreen.main.bounds.size.width, height: 60));
    navbar.setBackgroundImage(UIImage(), for: .default)
    navbar.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    navbar.titleTextAttributes = [ NSForegroundColorAttributeName:UIColor.white]
    self.view.addSubview(navbar)

    let navItem = UINavigationItem(title: "Pick a Cover")
    let navBarbutton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: self, action: #selector(CoverFrameViewController.back(_:)))
    navBarbutton.tintColor = UIColor.white
    navItem.leftBarButtonItem = navBarbutton

    navbar.items = [navItem]
  }

  func getFileUrl() -> URL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.appendingPathComponent(fileName)
    return URL(fileURLWithPath: path)
  }

  func getCacheDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    return paths[0]
  }
}

// MARK: - IBAction

extension CoverFrameViewController {

  func back(_ sender: AnyObject) {
    _ = self.navigationController?.popViewController(animated: false)
  }

  @IBAction func submitButtonTapped(_ sender: AnyObject) {
    let videoData = try? Data(contentsOf: getFileUrl())
    var compressionRatio = 1.0
    let photoSize = UIImageJPEGRepresentation(coverImage.image!, 1)!
    if (photoSize.count > 1000000) {
      compressionRatio = 0.005
    }
    else if (photoSize.count > 500000) {
      compressionRatio = 0.01
    }
    else if (photoSize.count > 100000){
      compressionRatio = 0.05
    }
    else if (photoSize.count > 10000) {
      compressionRatio = 0.2
    }

    let photoData = UIImageJPEGRepresentation(coverImage.image!, CGFloat(compressionRatio))
    let activityIndicator = utilityModule.createCustomActivityIndicator(self.view, text: "Submitting Answer...")
    let time = DispatchTime.now() + Double(2 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      Answer().submitAnswer(self.quandaId!, answerVideo: videoData!, coverPhoto: photoData!, duration: self.duration)
      let presentingViewController = self.presentingViewController as? UITabBarController
      let navigationController = presentingViewController?.viewControllers?[2] as? UINavigationController
      _ = navigationController?.popViewController(animated: true)
      activityIndicator.hide(animated: true)
      self.dismiss(animated: true, completion: nil)
    }
  }

}
// MARK: - UICollectionViewDelegateFlowLayout
extension CoverFrameViewController :  UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 50, height: 100)
  }
}

// MARK: - UICollectionViewDataSource

extension CoverFrameViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return coverFrames.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CoverFrameCollectionViewCell
    cell.coverImage.image = coverFrames[indexPath.row]

    return cell
  }
}

// MARK: - UICollectionViewDelegate

extension CoverFrameViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    coverImage.image = coverFrames[indexPath.row]
  }
}
