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
    self.layoutIfNeeded()
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

    questionLabel.font = UIFont.systemFontOfSize(13)

    titleLabel.font = UIFont.systemFontOfSize(12)
    titleLabel.textColor = UIColor(red: 140/255, green: 157/255, blue: 170/255, alpha: 1.0)
    titleLabel.numberOfLines = 0
    playImage.image = UIImage(named: "play")

    durationLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    durationLabel.layer.cornerRadius = 2
    durationLabel.clipsToBounds = true

    nameLabel.font = UIFont.systemFontOfSize(13)
    numOfSnoops.font = numOfSnoops.font.fontWithSize(11)
    numOfSnoops.textColor = UIColor.defaultColor()
  }

}
