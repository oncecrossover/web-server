//
//  ActivityViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var activityTableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!


  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.navigationItem.title = "Activity"
  }

  func loadData() {

  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCellWithIdentifier("questionCell", forIndexPath: indexPath) as! QuestionTableViewCell
  }
  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

}
