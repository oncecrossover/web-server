//
//  questionTableViewCell.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

  @IBOutlet weak var questionText: UITextView!

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var profileImage: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
