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

  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var playImage: UIImageView!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var profileImage: UIImageView!

  @IBOutlet weak var numOfSnoops: UILabel!


  override func awakeFromNib() {
    super.awakeFromNib()
    initConfig()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }


  func initConfig(){
    coverImage.layoutIfNeeded()
    coverImage.layer.cornerRadius = 4
    coverImage.clipsToBounds = true

    questionLabel.font = questionLabel.font.fontWithSize(13)

    titleLabel.font = titleLabel.font.fontWithSize(10)
    titleLabel.textColor = UIColor.grayColor()
    titleLabel.numberOfLines = 0
    playImage.image = UIImage(named: "play")
    durationLabel.hidden = true

    nameLabel.font = nameLabel.font.fontWithSize(14)
    numOfSnoops.font = numOfSnoops.font.fontWithSize(11)
  }

}
