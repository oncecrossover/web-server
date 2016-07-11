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
  @IBOutlet weak var listenButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    initConfig()
  }


  func initConfig(){

//    myCell.discoverImageView.userInteractionEnabled = true
//    let tappedOnImage = UITapGestureRecognizer(target: self, action: "tappedOnImage:")
//    myCell.discoverImageView.addGestureRecognizer(tappedOnImage)


    questionText.lineBreakMode = NSLineBreakMode.ByWordWrapping
    questionText.numberOfLines = 0
    questionText.sizeToFit()
    questionText.font = questionText.font.fontWithSize(13)

    titleLabel.numberOfLines = 0
    titleLabel.font = titleLabel.font.fontWithSize(13)
    titleLabel.textColor = UIColor.grayColor()
    titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    titleLabel.sizeToFit()
  }
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
