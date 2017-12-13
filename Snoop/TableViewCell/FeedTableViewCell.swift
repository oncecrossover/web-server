//
//  FeedTableViewCell.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/12/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {


  @IBOutlet weak var askerImage: UIImageView!
  @IBOutlet weak var questionLabel: UILabel!

  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var playImage: UIImageView!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var responderImage: UIImageView!

  @IBOutlet weak var numOfSnoops: UILabel!

  @IBOutlet weak var askerName: UILabel!
  @IBOutlet weak var actionSheetButton: UIButton!

  @IBOutlet weak var freeForHours: UILabel!
  @IBOutlet weak var thumbupImage: CircleImageView!
  @IBOutlet weak var thumbups: UILabel!
  @IBOutlet weak var thumbdownImage: CircleImageView!
  @IBOutlet weak var thumbdowns: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.layoutIfNeeded()
    initConfig()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }


  func initConfig(){
    coverImage.layoutIfNeeded()
    coverImage.layer.cornerRadius = 4
    coverImage.clipsToBounds = true

    questionLabel.font = UIFont.systemFont(ofSize: 13)
    questionLabel.layer.cornerRadius = 4
    questionLabel.clipsToBounds = true

    titleLabel.font = UIFont.systemFont(ofSize: 12)
    titleLabel.textColor = UIColor.secondaryTextColor()
    titleLabel.numberOfLines = 0

    durationLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    durationLabel.layer.cornerRadius = 2
    durationLabel.clipsToBounds = true

    nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
    askerName.font = UIFont.boldSystemFont(ofSize: 14)
    numOfSnoops.font = numOfSnoops.font.withSize(11)

    freeForHours.backgroundColor = UIColor.highlightColor()
  }

}
