//
//  PaymentViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/17/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

  var cards:[(bank: String!, cardCompany: String!, digits: String!)] = [("Bank Of America", "Visa", "0000")]

  @IBOutlet weak var cardTableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == .Delete) {
      cards.removeAtIndex(indexPath.row)
      cardTableView.reloadData()
    }
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cards.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath) as! PaymentTableViewCell
    let cardInfo = cards[indexPath.row]
    myCell.bank.text = cardInfo.bank
    myCell.cardCompany.text = cardInfo.cardCompany
    myCell.lastDigit.text = cardInfo.digits
    return myCell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
  }




}
