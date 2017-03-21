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
  @IBOutlet weak var rateLabel: UILabel!
  @IBOutlet weak var expiration: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    initConfig()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func initConfig(){
    question.font = question.font.withSize(16.5)

    askerName.font = askerName.font.withSize(14.5)
    askerName.textColor = UIColor.gray

    status.font = status.font.withSize(14)
    rateLabel.font = rateLabel.font.withSize(12)
    expiration.font = expiration.font.withSize(13)
  }

}
