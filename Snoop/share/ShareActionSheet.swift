//
//  ShareActionSheet.swift
//  Snoop
//
//  Created by Bingo Zhou on 9/1/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
import TwitterKit
import TwitterVideoUploader
import STTwitter
import RxSwift

class ShareActionSheet {
  let utility = UIUtility()
  let  disposeBag = DisposeBag()
  lazy var userReportHTTP = UserReport()
  private var socialGateway: SocialGateway

  init(_ socialGateway: SocialGateway) {
    self.socialGateway = socialGateway
  }

  func createSheet(forModel: ActivityModel) -> UIAlertController {
    let readyToView = forModel.status == "ANSWERED"
    let enableReport = shouldEnableReport(readyToView, responderId: forModel.responderId);
    return createSheet(quandaId: forModel.id, question: forModel.question,
                       answerUrl: forModel.answerUrl, readyToView: readyToView,
                       enableReport: enableReport)
  }

  func createSheet(forModel: FeedsModel, readyToView: Bool) -> UIAlertController {
    let enableReport = shouldEnableReport(readyToView, responderId: forModel.responderId);
    return createSheet(quandaId: forModel.id, question: forModel.question,
                       answerUrl: forModel.answerUrl, readyToView: readyToView,
                       enableReport: enableReport);
  }

  /* enable report action iif readyToView && responder is not current login user her/himself. */
  private func shouldEnableReport(_ readyToView: Bool, responderId: String?) -> Bool {
    let uid = UserDefaults.standard.string(forKey: "uid")
    return readyToView && uid != responderId
  }

  private func createSheet(quandaId: String, question: String, answerUrl: String?, readyToView: Bool, enableReport: Bool) -> UIAlertController {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

    /* action: Copy Question */
    let copyQuestionAction = createCopyQuestionAction(question)
    actionSheet.addAction(copyQuestionAction)

    /* actions: Share to Instagram / More */
    if (readyToView) {
      /* action: Share to Twitter */
      let twitterAction = createTwitterAction(quandaId, question, answerUrl)
      actionSheet.addAction(twitterAction)

      /* action: Share to Instagram */
      let instagramAction = createInstagramAction(quandaId, answerUrl)
      actionSheet.addAction(instagramAction)

      if (enableReport) {
        /* action: Report */
        let reportAction = createReportAction(quandaId)
        actionSheet.addAction(reportAction)
      }

      /* action: More */
      let moreAction = createMoreAction(quandaId, answerUrl)
      actionSheet.addAction(moreAction)
    }

    /* action: Close */
    let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) {
      action in
    }
    actionSheet.addAction(dismissAction)

    return actionSheet
  }

  private func createInstagramAction(_ quandaId: String, _ answerUrl: String?) -> UIAlertAction {
    return UIAlertAction(title: "Share to Instagram", style: UIAlertActionStyle.default) {
      action in
      self.socialGateway.postToIntagram(contentsOf: answerUrl, resourceId: quandaId);
    }
  }

  private func createCopyQuestionAction(_ question: String) -> UIAlertAction {
    return UIAlertAction(title: "Copy Question", style: UIAlertActionStyle.default) {
      action in
      UIPasteboard.general.string = question
    }
  }

  private func createReportAction(_ quandaId: String) -> UIAlertAction {
    return UIAlertAction(title: "Report", style: UIAlertActionStyle.default) {
      action in

      let uid = UserDefaults.standard.string(forKey: "uid")
      self.userReportHTTP.createReport(uid!, quandaId: quandaId) {
        result in

        if (result.isEmpty) {
          /* report succeeds */
          self.socialGateway.hostingController.displayConfirmation("Report Succeeded!")
        } else {
          /* report fails */
          self.socialGateway.hostingController.displayConfirmation("Report Failed!")
        }
      }
    }
  }

  private func createTwitterAction(_ quandaId: String, _ question: String, _ answerUrl: String?) -> UIAlertAction {
    return UIAlertAction(title: "Share to Twitter", style: UIAlertActionStyle.default) {
      action in

      self.socialGateway.retrieveMedia(from: answerUrl, resourceId: quandaId) {
        fileUrl in

        guard let _ = fileUrl else {
          return
        }

        self.socialGateway.hostingController.displayConfirmation("Video will be posted.")
        let api = STTwitterAPI(oAuthConsumerKey: "II4Ihx8XqrKydVO1bEcXL2l8p",
                               consumerSecret:  "swOZIBmANuhq8Ja3Y7vgrKLUOaTMQeswGL2j3KJEM88uHSFKkh",
                               oauthToken: UserDefaults.standard.string(forKey: "accessToken"),
                               oauthTokenSecret: UserDefaults.standard.string(forKey: "accessTokenSecret"))
        api?.setTimeoutInSeconds(86400)
        api?.postStatusesUpdate(with: fileUrl!, message: question).subscribe(
          onNext: { (_) in
            print("next")
        }, onError: { (error) in
          self.utility.displayAlertMessage(error.localizedDescription, title: "Twitter Share Failed", sender: self.socialGateway.hostingController)
        }, onCompleted: {
          self.socialGateway.hostingController.displayConfirmation("Twitter Share Succeeded!")
        }, onDisposed: {
          print("dispose")
        }).disposed(by: self.disposeBag)
      }
    }
  }

  private func createMoreAction(_ quandaId: String, _ answerUrl: String?) -> UIAlertAction {
    return UIAlertAction(title: "More", style: UIAlertActionStyle.default) {
      action in

      self.socialGateway.retrieveMedia(from: answerUrl, resourceId: quandaId) {
        fileUrl in

        guard let _ = fileUrl else {
          return
        }

        let activityViewController = UIActivityViewController(activityItems: [fileUrl!], applicationActivities: nil)
        // activityViewController.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
        activityViewController.excludedActivityTypes = activityViewController.getExcludedActivityTypes()
        activityViewController.completionWithItemsHandler = {
          activityType, success, items, error in

          do {
            /* delete temp media in cache */
            try FileManager.default.removeItem(at: fileUrl!)
          } catch let error as NSError {
            print(error)
          }
        }
        self.socialGateway.hostingController.present(activityViewController, animated: true, completion: nil)
      }
    }
  }
}
