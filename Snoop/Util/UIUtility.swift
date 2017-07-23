//
//  UiUtility.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/23/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
import UIKit
class UIUtility {
  func displayAlertMessage(_ userMessage:String, title: String, sender: UIViewController) {

    let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)

    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)

    myAlert.addAction(okAction)

    sender.present(myAlert, animated: true, completion: nil)

  }

  func createCustomActivityIndicator(_ view: UIView, text: String!) -> MBProgressHUD{
    let activityIndicator = MBProgressHUD.showAdded(to: view, animated: true)
    activityIndicator.label.text = text
    activityIndicator.label.textColor = UIColor.black
    //setup the background color of the popup
    activityIndicator.bezelView.color = UIColor.white
    //setup border color
    activityIndicator.bezelView.layer.borderWidth = 1
    activityIndicator.bezelView.layer.borderColor = UIColor.lightGray.cgColor

    //This part is interesting in that we set the interaction to false so users can't interact with other
    //UI element when popup is spinning
    activityIndicator.isUserInteractionEnabled = false
    return activityIndicator
  }

  func addTextToImage(_ drawText: NSString, inImage: UIImage, atPoint: CGPoint, textColor: UIColor, textFont: UIFont) -> UIImage {
    // Setup the image context using the passed image
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)

    // Setup the font attributes that will be later used to dictate how the text should be drawn
    let textFontAttributes = [
      NSFontAttributeName: textFont,
      NSForegroundColorAttributeName: textColor,
    ]

    // Put the image into a rectangle as large as the original image
    inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))

    // Create a point within the space that is as bit as the image
    let rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)

    // Draw the text into an image
    drawText.draw(in: rect, withAttributes: textFontAttributes)

    // Create a new image out of the images we have created
    let newImage = UIGraphicsGetImageFromCurrentImageContext()

    // End the context now that we have the image we need
    UIGraphicsEndImageContext()

    //Pass the image back up to the caller
    return newImage!
  }

  func getCacheDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)

    return paths[0]
  }

  func getFileUrl(_ fileName: String!) -> URL {
    let prefix = getCacheDirectory() as NSString
    let path = prefix.appendingPathComponent(fileName)
    return URL(fileURLWithPath: path)
  }
}
