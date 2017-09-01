//
//  ShareActionSheet.swift
//  Snoop
//
//  Created by Bingo Zhou on 9/1/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation

class ShareActionSheet {
  private var socialGateway: SocialGateway

  init(_ socialGateway: SocialGateway) {
    self.socialGateway = socialGateway
  }

  func createSheet(forModel: ActivityModel) -> UIAlertController {
    let includeShareActions = forModel.status == "ANSWERED"
    return createSheet(quandaId: forModel.id, question: forModel.question, answerUrl: forModel.answerUrl!, includeShareActions: includeShareActions)
  }

  func createSheet(forModel: FeedsModel, includeShareActions: Bool) -> UIAlertController {
    return createSheet(quandaId: forModel.id, question: forModel.question, answerUrl: forModel.answerUrl, includeShareActions: includeShareActions)
  }

  private func createSheet(quandaId: String, question: String, answerUrl: String, includeShareActions: Bool) -> UIAlertController {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

    /* action: Copy Question */
    let copyQuestionAction = UIAlertAction(title: "Copy Question", style: UIAlertActionStyle.default) {
      action in
      UIPasteboard.general.string = question
    }
    actionSheet.addAction(copyQuestionAction)

    /* actions: Share to Instagram / More */
    if (includeShareActions) {
      /* action: Share to Instagram */
      let instagramAction = UIAlertAction(title: "Share to Instagram", style: UIAlertActionStyle.default) {
        action in
        self.socialGateway.postToIntagram(contentsOf: answerUrl, resourceId: quandaId);
      }
      actionSheet.addAction(instagramAction)

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
