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
  func displayAlertMessage(userMessage:String, title: String, sender: UIViewController) {

    let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)

    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

    myAlert.addAction(okAction)

    sender.presentViewController(myAlert, animated: true, completion: nil)

  }

  func createCustomActivityIndicator(view: UIView, text: String!) -> MBProgressHUD{
    let activityIndicator = MBProgressHUD.showHUDAddedTo(view, animated: true)
    activityIndicator.label.text = text
    activityIndicator.label.textColor = UIColor.blackColor()
    //setup the background color of the popup
    activityIndicator.bezelView.color = UIColor.whiteColor()
    //setup border color
    activityIndicator.bezelView.layer.borderWidth = 1
    activityIndicator.bezelView.layer.borderColor = UIColor.lightGrayColor().CGColor

    //This part is interesting in that we set the interaction to false so users can't interact with other
    //UI element when popup is spinning
    activityIndicator.userInteractionEnabled = false
    return activityIndicator
  }

  func addTextToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint, textColor: UIColor, textFont: UIFont) -> UIImage {
    // Setup the image context using the passed image
    let scale = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)

    // Setup the font attributes that will be later used to dictate how the text should be drawn
    let textFontAttributes = [
      NSFontAttributeName: textFont,
      NSForegroundColorAttributeName: textColor,
    ]

    // Put the image into a rectangle as large as the original image
    inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))

    // Create a point within the space that is as bit as the image
    let rect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)

    // Draw the text into an image
    drawText.drawInRect(rect, withAttributes: textFontAttributes)

    // Create a new image out of the images we have created
    let newImage = UIGraphicsGetImageFromCurrentImageContext()

    // End the context now that we have the image we need
    UIGraphicsEndImageContext()

    //Pass the image back up to the caller
    return newImage
  }
}
