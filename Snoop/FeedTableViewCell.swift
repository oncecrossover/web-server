//
//  FeedTableViewCell.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/12/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {


  @IBOutlet weak var questionLabel: UILabel!

  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var snoopImage: UIImageView!
  @IBOutlet weak var profileImage: UIImageView!

  @IBOutlet weak var numOfSnoops: UILabel!


  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }


  func initConfig(){

    questionLabel.font = questionLabel.font.fontWithSize(13)

    titleLabel.font = titleLabel.font.fontWithSize(13)
    titleLabel.textColor = UIColor.grayColor()
  }

}
