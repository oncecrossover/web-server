//
//  Answer.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/22/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
class Answer: Generics, URLSessionTaskDelegate {

  var customWindow: UIWindow?
  var progressView: ProgressView

  let notificationName = "answerRefresh"
  override init() {
    progressView = ProgressView()
    progressView.translatesAutoresizingMaskIntoConstraints = false
    super.init()
  }

  func submitAnswer(_ id: String, answerVideo: Data, coverPhoto: Data, duration: Int) {
    let url = self.HTTPHOST + "quandas"
    let myUrl = URL(string: url + "/" + "\(id)")!
    let videoString = answerVideo.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    let photoString = coverPhoto.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    let jsonData: [String: AnyObject] = ["answerMedia" : videoString as AnyObject, "answerCover" : photoString as AnyObject, "status" : "ANSWERED" as AnyObject, "duration" : duration as AnyObject]
    let request = NSMutableURLRequest(url:myUrl)
    request.httpMethod = "PUT"

    do {
      request.httpBody =  try JSONSerialization.data(withJSONObject: jsonData, options: [])
    }
    catch {
      print("error=\(error)")
    }
    let session = self.getURLSession(self)

    if let window = UIApplication.shared.keyWindow {
      customWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: window.frame.width, height: UIApplication.shared.statusBarFrame.height))
      customWindow?.addSubview(progressView)
      customWindow?.addConstraintsWithFormat("H:|[v0]|", views: progressView)
      customWindow?.addConstraintsWithFormat("V:|[v0]|", views: progressView)
      progressView.label.text = "Uploading... 0%"
      customWindow?.windowLevel = UIWindowLevelStatusBar
      customWindow?.isHidden = false
    }

    let task = session.dataTask(with: request as URLRequest) {
      data, response, error in
      if (error != nil)
      {
        return
      }

      let httpResponse = response as! HTTPURLResponse
      if (httpResponse.statusCode == 400) {
        //let responseData = String(data: data!, encoding: String.Encoding.utf8)!
        //completion(responseData)
      }
      else {
        DispatchQueue.main.async {
          self.progressView.showSuccess()
        }

        let time = DispatchTime.now() + Double(1 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
          UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.progressView.alpha = 0
          }) {(result) in
            self.progressView.removeFromSuperview()
            self.customWindow?.isHidden = true
            self.customWindow = nil
            NotificationCenter.default.post(name: Notification.Name(rawValue: self.notificationName), object: nil)
          }
        }
        //completion("")
      }

    }
    task.resume()
    session.finishTasksAndInvalidate()
  }

  /*override func urlSession(_ session: URLSession,  didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)  {
    super.urlSession(session, didReceive: challenge, completionHandler: completionHandler)
  }*/

  func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    let progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
    let percentage = Int(progress * 100)
    progressView.label.text = "Uploading... \(percentage)%"
  }
}
