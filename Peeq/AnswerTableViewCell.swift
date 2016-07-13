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
    question.font = question.font.fontWithSize(13)

    askerName.font = askerName.font.fontWithSize(13)
    askerName.textColor = UIColor.grayColor()

    status.font = status.font.fontWithSize(13)
    status.textColor = UIColor.greenColor()
    
  }

}
