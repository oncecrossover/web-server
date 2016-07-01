//
//  DiscoverTableViewCell.swift
//  Peeq
//
//  Created by Bowen Zhang on 6/29/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {

  @IBOutlet weak var discoverImageView: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var about: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}