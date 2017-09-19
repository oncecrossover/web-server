//
//  ShareActionSheet.swift
//  Snoop
//
//  Created by Bingo Zhou on 9/1/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation

class ShareActionSheet {
  lazy var reportModel = Report()
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
    let copyQuestionAction = UIAlertAction(title: "Copy Question", style: UIAlertActionStyle.default) {
      action in
      UIPasteboard.general.string = question
    }
    actionSheet.addAction(copyQuestionAction)

    /* actions: Share to Instagram / More */
    if (readyToView) {
      /* action: Share to Instagram */
      let instagramAction = UIAlertAction(title: "Share to Instagram", style: UIAlertActionStyle.default) {
        action in
        self.socialGateway.postToIntagram(contentsOf: answerUrl, resourceId: quandaId);
      }
      actionSheet.addAction(instagramAction)

      if (enableReport) {
        /* action: Report */
        let reportAction = UIAlertAction(title: "Report", style: UIAlertActionStyle.default) {
          action in

          let uid = UserDefaults.standard.string(forKey: "uid")
          self.reportModel.createReport(uid!, quandaId: quandaId) {
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
        actionSheet.addAction(reportAction)
      }

      /* action: More */
      let moreAction = UIAlertAction(title: "More", style: UIAlertActionStyle.default) {
        action in

        self.socialGateway.retrieveMedia(from: answerUrl, resourceId: quandaId) {
          fileUrl in

          guard let _ = fileUrl else {
            return
          }

          let activityViewController = UIActivityViewController(activityItems: [fileUrl!], applicationActivities: nil)
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
      actionSheet.addAction(moreAction)
    }

    /* action: Close */
    let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) {
      action in
    }
    actionSheet.addAction(dismissAction)

    return actionSheet
  }
}
