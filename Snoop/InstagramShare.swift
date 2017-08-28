//
//  InstagramShare.swift
//  Snoop
//
//  Created by Bingo Zhou on 8/27/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
import Photos

class InstagramShare {
  /* temp local file where download puts data */
  let tmpVideoFileName: String = "com.snoop.tmp.video.mp4"
  /* customized album being created to ease cleaning media */
  let instagramShareAlbumName: String = "Snoop Instagram Share"
  let utility = UIUtility()
  var hostingController: UIViewController
  var permissionAlert: PermissionView

  func post(contentsOf: String?) {

    /* test if the instagram can be opened */
    guard let url = URL(string: "instagram://app"), UIApplication.shared.canOpenURL(url) else {
      self.utility.displayAlertMessage("Please install Instagram and try again.", title: "Share Failed", sender: hostingController)
      return
    }

    /* dispatch actions upon permissions */
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
      self.downloadAndShareVideo(from: contentsOf)
    case .denied, .restricted :
      CellAccessUtil().popupAllowPhotosAccess(self.permissionAlert)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization() {
        status in

        /* activityIndicator (i.e. MBProgressHUD) needs to be run in main thread,
         * otherwise, this callback from modal permission alert will crash app. */
        DispatchQueue.main.sync {
          switch status {
          case .authorized:
            self.downloadAndShareVideo(from: contentsOf)
          case .denied, .restricted:
            CellAccessUtil().popupAllowPhotosAccess(self.permissionAlert)
          case .notDetermined: break
          }
        }
      }
    }
  }

  init(hostingController: UIViewController, permissionAlert: PermissionView) {
    self.hostingController = hostingController
    self.permissionAlert = permissionAlert
  }

  private func downloadAndShareVideo(from: String?) {
    if let urlString = from, let answerUrl = URL(string: urlString) {
      self.downloadAndShareVideo(from: answerUrl)
    }
  }

  private func downloadAndShareVideo(from: URL) {
    let activityIndicator = self.utility.createCustomActivityIndicator(hostingController.view, text: "Saving Video to Photo Library...")
    DownloadData(from: from) {
      data, response, error in

      DispatchQueue.main.async {
        guard let _ = data, error == nil else {
          /* relase UI lock when there's download error */
          activityIndicator.hide(animated: true)
          self.utility.displayAlertMessage("An error occurs while downloading video, please try again", title: "Download Failed", sender: self.hostingController)
          return
        }

        let fileUrl = self.utility.getFileUrl(self.tmpVideoFileName)
        /* save media to local temp file to create PHAsset */
        self.SaveToLocalFile(data: data, tmpFileUrl: fileUrl)
        /* relase UI lock after download and saving are done */
        activityIndicator.hide(animated: true)
        /* save to photo library by creating PHAsset */
        self.saveToPhotoLibrary(videoFileUrl: fileUrl) {
          localIdentifier in

          /* open app with media id for posting */
          self.openInstagram(withLocalIdentifier: localIdentifier) {
            success in

            do {
              /* delete temp video in cache */
              try FileManager.default.removeItem(at: fileUrl)
            } catch let error as NSError {
              print(error)
            }
          }
        }
      }
    }
  }

  private func DownloadData(from: URL, completion: @escaping ((Data?, URLResponse?, Error? ) -> Void)) {
    URLSession.shared.dataTask(with: from) {
      (data, response, error) in

      completion(data, response, error)
      }.resume()
  }

  private func SaveToLocalFile(data: Data?, tmpFileUrl: URL) {
    /* overwrite the file by default */
    try? data?.write(to: tmpFileUrl, options: [])
  }

  private func saveToPhotoLibrary(videoFileUrl: URL?, completion: @escaping (String?)->()) {
    guard let _ = videoFileUrl else {
      completion(nil)
      return
    }

    PHPhotoLibrary.saveVideo(videoFileUrl: videoFileUrl!, albumName: instagramShareAlbumName) {
      phAssets in

      guard let _ = phAssets, let _ = phAssets?.firstObject else {
        /* popup failure */
        self.utility.displayAlertMessage("An error occurs while saving video to photo library, please try again", title: "Saving Video Failed", sender: self.hostingController)
        completion(nil)
        return
      }

      completion(phAssets!.firstObject!.localIdentifier)
    }
  }

  private func openInstagram(withLocalIdentifier: String?, completion: @escaping (Bool)->()) {
    guard let _ = withLocalIdentifier else {
      completion(false)
      return
    }

    /* open the app with media id */
    let instagramMediaUrlString = "instagram://library?LocalIdentifier=\(withLocalIdentifier!)"
    guard let instagramMediaUrl = URL(string: instagramMediaUrlString) else {
      completion(false)
      return
    }
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(instagramMediaUrl, options: [:], completionHandler: completion)
    } else {
      UIApplication.shared.openURL(instagramMediaUrl)
      completion(true)
    }
  }
}
