//
//  AnswerTableViewCell.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/5/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {

  @IBOutlet weak var askerName: UILabel!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var status: UILabel!

  @IBOutlet weak var question: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    initConfig()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func initConfig(){
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
    profileImage.clipsToBounds = true
    profileImage.layer.borderColor = UIColor.blackColor().CGColor
    profileImage.layer.borderWidth = 1

    question.lineBreakMode = NSLineBreakMode.ByWordWrapping
    question.numberOfLines = 0
    question.sizeToFit()
    question.font = question.font.fontWithSize(13)

    askerName.numberOfLines = 0
    askerName.font = askerName.font.fontWithSize(13)
    askerName.textColor = UIColor.grayColor()
    askerName.lineBreakMode = NSLineBreakMode.ByWordWrapping
    askerName.sizeToFit()

    status.font = status.font.fontWithSize(13)
    status.textColor = UIColor.greenColor()
    
  }

}
