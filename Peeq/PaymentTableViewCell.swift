//
//  PaymentTableViewCell.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/17/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

  @IBOutlet weak var lastDigit: UILabel!
  @IBOutlet weak var cardCompany: UILabel!
  @IBOutlet weak var bank: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
