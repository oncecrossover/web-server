//
//  extension.swift
//  Snoop
//
//  Created by Bowen Zhang on 1/11/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Siren
import Photos

extension String {
  func toBool() -> Bool {
    switch self {
    case "TRUE", "True", "true", "YES", "Yes", "yes", "1":
      return true
    case "FALSE", "False", "false", "NO", "No", "no", "0":
      return false
    default:
      return false
    }
  }
}

extension Int {
  func toTimeFormat() -> String {
    let minute = self / 60
    let seconds = self % 60
    return String(format:"%02i:%02i", minute, seconds)
  }
}

extension UIColor {
  public class func defaultColor() -> UIColor {
    return UIColor(red: 51/255, green: 181/255, blue: 159/255, alpha: 1.0)
  }

  public class func disabledColor() -> UIColor {
    return UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0)
  }

  public class func secondaryTextColor() -> UIColor {
    return UIColor(red: 140/255, green: 157/255, blue: 170/255, alpha: 1.0)
  }
}

extension UIView {
  public func addConstraintsWithFormat(_ format: String, views: UIView...) {
    var viewDictionary = [String: UIView]()
    for (index, view) in views.enumerated() {
      let key = "v\(index)"
      view.translatesAutoresizingMaskIntoConstraints = false
      viewDictionary[key] = view
    }

    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewDictionary))
  }
}

extension UIImageView {
  func cosmeticizeImage(cosmeticHints : String?) {
    self.setImageForName(string: cosmeticHints!, backgroundColor: nil, circular: true, textAttributes: nil)
  }
}

extension UIViewController {
  func launchVideoPlayer(_ answerUrl: String, duration: Int) -> VideoPlayerView {
    let videoPlayerView = VideoPlayerView()
    let bounds = UIScreen.main.bounds

    let oldFrame = CGRect(x: 0, y: bounds.size.height, width: bounds.size.width, height: 0)
    videoPlayerView.frame = oldFrame
    let newFrame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
    self.tabBarController?.view.addSubview(videoPlayerView)
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      videoPlayerView.frame = newFrame
      videoPlayerView.setupLoadingControls()
    }, completion: nil)

    let player = AVPlayer(url: URL(string: answerUrl)!)
    videoPlayerView.player = player
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    videoPlayerView.layer.addSublayer(playerLayer)
    playerLayer.frame = videoPlayerView.frame
    videoPlayerView.setupPlayingControls()
    let secondsText = String(format: "%02d", duration % 60)
    let minutesText = String(format: "%02d", duration / 60)
    videoPlayerView.lengthLabel.text = "\(minutesText):\(secondsText)"
    videoPlayerView.setupProgressControls()

    player.play()
    return videoPlayerView
  }

  public func displayConfirmation(_ msg: String) {
    let confirmView = ConfirmView()
    confirmView.translatesAutoresizingMaskIntoConstraints = false
    confirmView.setMessage(msg)
    view.addSubview(confirmView)
    confirmView.widthAnchor.constraint(equalToConstant: 160).isActive = true
    confirmView.heightAnchor.constraint(equalToConstant: 90).isActive = true
    confirmView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    confirmView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    confirmView.alpha = 0
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      confirmView.alpha = 1
    }, completion: nil)
    let time = DispatchTime.now() + Double(2 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        confirmView.alpha = 0
      }) { (result) in
        confirmView.removeFromSuperview()
      }
    }
  }
}

extension Siren {
  private func getCurrentInstalledVersion() -> String? {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }

  private enum VersionError: Int, Error {
    case invalidBundleInfo = 0
    case invalidResponse = 1

    var what: String {
      switch self {
        case .invalidBundleInfo:
          return NSLocalizedString("\(VersionError.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "Invalid bundle info.", comment: "")
        case .invalidResponse:
          return NSLocalizedString("\(VersionError.self)_\(self)", tableName: String(describing: self), bundle: Bundle.main, value: "Invalid response of retrieving app store version.", comment: "")
      }
    }
  }

  private func syncGetAppStoreVersion() throws -> String {
    if let _ = self.currentAppStoreVersion {
      return self.currentAppStoreVersion!
    } else {
      guard let info = Bundle.main.infoDictionary,
        let identifier = info["CFBundleIdentifier"] as? String,
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else {
          throw VersionError.invalidBundleInfo
      }
      let data = try Data(contentsOf: url)
      guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
        throw VersionError.invalidResponse
      }
      if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
        return version
      }
      throw VersionError.invalidResponse
    }
  }

  func isUpdateBackCompatible() -> Bool{
    var result = false

    do {
      result = try isUpdateBackCompatible(syncGetAppStoreVersion())
    } catch VersionError.invalidBundleInfo {
      print(VersionError.invalidBundleInfo.what)
    } catch VersionError.invalidResponse {
      print(VersionError.invalidResponse.what)
    } catch {}

    return result
  }

  private func isUpdateBackCompatible(_ appStoreVersion: String?) -> Bool{
    guard let currentInstalledVersion = getCurrentInstalledVersion() else {
      return false
    }
    guard let currentAppStoreVersion = appStoreVersion else {
        return false
    }

    let oldVersion = (currentInstalledVersion).characters.split {$0 == "."}.map { String($0) }.map {Int($0) ?? 0}
    let newVersion = (currentAppStoreVersion).characters.split {$0 == "."}.map { String($0) }.map {Int($0) ?? 0}

    guard let newVersionFirst = newVersion.first, let oldVersionFirst = oldVersion.first else {
      return true
    }

    if newVersionFirst > oldVersionFirst { // A.b.c.d
      return false
    }

    return true
  }
}


extension AppDelegate: SirenDelegate
{
  func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
    print(#function, alertType)
  }

  func sirenUserDidCancel() {
    print(#function)
  }

  func sirenUserDidSkipVersion() {
    print(#function)
  }

  func sirenUserDidLaunchAppStore() {
    print(#function)
  }

  func sirenDidFailVersionCheck(error: NSError) {
    print(#function, error)
  }

  func sirenLatestVersionInstalled() {
    print(#function, "Latest version of app is installed")
  }

  /* This delegate method is only hit when alertType is initialized to .none */
  func sirenDidDetectNewVersionWithoutAlert(message: String) {
    print(#function, "\(message)")
  }
}

public extension PHPhotoLibrary {

  typealias PhotoAsset = PHAsset
  typealias PhotoAlbum = PHAssetCollection

  /**
   * Saves video to a customized album.
   */
  static func saveVideo(videoFileUrl: URL, albumName: String, completion: @escaping (PHFetchResult<PHAsset>?)->()) {
    if let album = self.findAlbum(albumName: albumName) {
      saveVideo(videoFileUrl: videoFileUrl, album: album, completion: completion)
      return
    }
    createAlbum(albumName: albumName) {
      album in

      if let album = album {
        self.saveVideo(videoFileUrl: videoFileUrl, album: album, completion: completion)
      }
      else {
        completion(nil)
      }
    }
  }

  /**
   * Saves video to a customized album.
   */
  private static func saveVideo(videoFileUrl: URL, album: PhotoAlbum, completion: @escaping (PHFetchResult<PHAsset>?)->()) {

    var placeholder: PHObjectPlaceholder?

    PHPhotoLibrary.shared().performChanges({

      // Request creating an asset from the video
      let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoFileUrl)
      // Request editing the album
      guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
        completion(nil)
        return
      }

      // Get a placeholder for the new asset and add it to the album editing request
      guard let videoPlaceholder = createAssetRequest!.placeholderForCreatedAsset else {
        completion(nil)
        return
      }

      placeholder = videoPlaceholder

      albumChangeRequest.addAssets([videoPlaceholder] as NSArray)
    }, completionHandler: {
      success, error in

      guard let placeholder = placeholder else {
        completion(nil)
        return
      }

      if success {
        completion(PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options:nil))
      }
      else {
        print(error!)
        completion(nil)
      }
    })
  }

  /**
   * Locates the album with a given name.
   */
  private static func findAlbum(albumName: String) -> PhotoAlbum? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
    let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
    if let photoAlbum = fetchResult.firstObject {
      return photoAlbum
    } else {
      return nil
    }
  }

  /**
   * Creates a customized album where media are stored.
   */
  private static func createAlbum(albumName: String, completion: @escaping (PhotoAlbum?)->()) {
    var albumPlaceholder: PHObjectPlaceholder?
    PHPhotoLibrary.shared().performChanges({
      // Request creating an album with parameter name
      let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
      // Get a placeholder for the new album
      albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
    }, completionHandler: {
      success, error in

      guard let placeholder = albumPlaceholder else {
        completion(nil)
        return
      }

      let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
      guard let album = fetchResult.firstObject else {
        completion(nil)
        return
      }

      if success {
        completion(album)
      }
      else {
        print(error!)
        completion(nil)
      }
    })
  }
}

extension UIActivityType {
  @available(iOS 7.0, *)
  public static let postToInstagram: UIActivityType = {
    return UIActivityType.init(rawValue: "com.burbn.instagram.shareextension")
  }()
}

extension UIActivityViewController {
  func getExcludedActivityTypes() -> [UIActivityType]? {
    return [
      UIActivityType.postToWeibo,
      UIActivityType.mail,
      UIActivityType.print,
      UIActivityType.copyToPasteboard,
      UIActivityType.assignToContact,
      UIActivityType.saveToCameraRoll,
      UIActivityType.addToReadingList,
      UIActivityType.postToFlickr,
      UIActivityType.postToVimeo,
      UIActivityType.postToTencentWeibo,
      UIActivityType.airDrop,
      UIActivityType.openInIBooks,
      UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
      UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
      UIActivityType(rawValue: "com.apple.iCloudDrive.ShareExtension"),
      UIActivityType(rawValue: "com.apple.mobileslideshow.StreamShareService"),
      UIActivityType.postToInstagram
    ]
  }
}
