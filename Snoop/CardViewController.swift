//
//  PaymentViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/17/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit
import Stripe

class CardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var cards:[(id: Int!, lastFour: String!, brand: String!, isDefault: Bool!)] = []
  var paymentModule = Payment()

  @IBOutlet weak var cardTableView: UITableView!

  @IBOutlet weak var addCardButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  override func viewDidLoad() {
    super.viewDidLoad()
    addCardButton.enabled = true
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
    activityIndicator.startAnimating()
    cards = []
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    paymentModule.getPayments("uid=" + uid!) { jsonArray in
      for paymentInfo in jsonArray as! [[String:AnyObject]] {
        let lastFour = paymentInfo["last4"] as! String
        let id = paymentInfo["id"] as! Int
        let brand = paymentInfo["brand"]! as! String
        let isDefault = paymentInfo["default"] as! Bool
        self.cards.append((id: id, lastFour: lastFour, brand: brand, isDefault: isDefault))
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.activityIndicator.stopAnimating()
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
//    let myCell = tableView.dequeueReusableCellWithIdentifier("cardCell", forIndexPath: indexPath) as! PaymentTableViewCell
    let myCell = tableView.dequeueReusableCellWithIdentifier("cardCell")!
    let cardInfo = cards[indexPath.row]
//    myCell.lastDigit.text = "**** **** **** " + cardInfo.lastFour
    myCell.textLabel?.text = "ending in " + cardInfo.lastFour + "  \(cardInfo.brand)"

    if (cardInfo.isDefault!) {
      myCell.accessoryType = .Checkmark
    }
    else {
      myCell.accessoryType = .None
    }

    return myCell
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let backItem = UIBarButtonItem()
    backItem.title = "Back"
    navigationItem.backBarButtonItem = backItem
  }




}
