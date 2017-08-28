//
//  ActivityTableViewCell.swift
//  Snoop
//
//  Created by Bowen Zhang on 12/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

  @IBOutlet weak var responderTitle: UILabel!
  @IBOutlet weak var askerImage: UIImageView!
  @IBOutlet weak var askerName: UILabel!
  @IBOutlet weak var question: UILabel!
  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var playImage: UIImageView!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var rateLabel: UILabel!
  @IBOutlet weak var responderImage: UIImageView!
  @IBOutlet weak var responderName: UILabel!
  @IBOutlet weak var expireLabel: UILabel!
  @IBOutlet weak var actionSheetButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
    self.layoutIfNeeded()

    coverImage.layer.cornerRadius = 4
    coverImage.clipsToBounds = true

    playImage.image = UIImage(named: "play")

    rateLabel.backgroundColor = UIColor(red: 255/255, green: 183/255, blue: 78/255, alpha: 0.8)
    rateLabel.layer.cornerRadius = 2
    rateLabel.clipsToBounds = true

    durationLabel.isHidden = true
    durationLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    durationLabel.layer.cornerRadius = 2
    durationLabel.clipsToBounds = true

    question.font = UIFont.systemFont(ofSize: 13)

    responderName.font = UIFont.boldSystemFont(ofSize: 14)
    responderTitle.textColor = UIColor(red: 140/255, green: 157/255, blue: 170/255, alpha: 1.0)

    askerName.font = UIFont.boldSystemFont(ofSize: 14)

    expireLabel.font = UIFont.systemFont(ofSize: 12)
    expireLabel.textColor = UIColor.defaultColor()
    expireLabel.textAlignment = .center
  }
}
