//
//  questionTableViewCell.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {


  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var questionText: UILabel!
  @IBOutlet weak var listenImage: UIImageView!
  @IBOutlet weak var rateLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    initConfig()
  }


  func initConfig(){

//    myCell.discoverImageView.userInteractionEnabled = true
//    let tappedOnImage = UITapGestureRecognizer(target: self, action: "tappedOnImage:")
//    myCell.discoverImageView.addGestureRecognizer(tappedOnImage)

    questionText.font = questionText.font.fontWithSize(16.5)

    titleLabel.font = titleLabel.font.fontWithSize(14.5)
    titleLabel.textColor = UIColor.grayColor()
    rateLabel.font = rateLabel.font.fontWithSize(12)
  }
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
