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

  override func awakeFromNib() {
    name.font = UIFont.systemFont(ofSize: 14)
    name.textColor = UIColor(white: 0, alpha: 0.7)
    title.font = UIFont.systemFont(ofSize: 12)
    title.textColor = UIColor.secondaryTextColor()

    name.numberOfLines = 1
    title.numberOfLines = 1
  }

}
