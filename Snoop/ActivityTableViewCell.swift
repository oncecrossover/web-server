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
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layoutIfNeeded()

    coverImage.layer.cornerRadius = 2
    coverImage.clipsToBounds = true

    playImage.image = UIImage(named: "play")

    rateLabel.backgroundColor = UIColor(red: 255/255, green: 183/255, blue: 78/255, alpha: 1.0)

    durationLabel.hidden = true
    durationLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

    question.font = UIFont.boldSystemFontOfSize(14)
  }

}
