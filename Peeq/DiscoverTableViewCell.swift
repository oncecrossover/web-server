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
    about.font = about.font.fontWithSize(14)
    name.font = name.font.fontWithSize(14)
    title.font = title.font.fontWithSize(14)
  }

}
