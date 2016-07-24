//
//  PaymentViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/17/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var cards:[(id: Int!, lastFour: String!)] = []
  var paymentModule = Payment()

  @IBOutlet weak var cardTableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  func loadData(){
    cards = []
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    paymentModule.getPayments("uid=" + uid!) { jsonArray in
      for paymentInfo in jsonArray as! [[String:AnyObject]] {
        let lastFour = paymentInfo["lastFour"] as! String
        let id = paymentInfo["id"] as! Int
        self.cards.append((id: id, lastFour: lastFour))
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.cardTableView.reloadData()
      }
    }
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == .Delete) {
      let id = cards[indexPath.row].id
      cards.removeAtIndex(indexPath.row)
      paymentModule.deletePayment(id) {result in
        if (result.isEmpty) {
          dispatch_async(dispatch_get_main_queue()) {
            self.cardTableView.reloadData()
          }
        }
      }
    }
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cards.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let myCell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath) as! PaymentTableViewCell
    let cardInfo = cards[indexPath.row]
    myCell.lastDigit.text = "**** **** **** " + cardInfo.lastFour
    return myCell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
  }




}
